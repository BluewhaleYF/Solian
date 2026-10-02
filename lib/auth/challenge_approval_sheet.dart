import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/auth/widgets/auth_consent.dart';
import 'package:island/core/network.dart';
import 'package:island/core/network/api_error.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/wallets/pin_status.dart';
import 'package:local_auth/local_auth.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pinput/pinput.dart';
import 'package:relative_time/relative_time.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Shared secure-storage key for a locally-cached PIN. The same key is used by
/// the payment overlay so a PIN entered once on this device also unlocks
/// cross-device login approvals via biometric.
const String _pinStorageKey = 'app_pin_code';
final _secureStorage = FlutterSecureStorage(
  aOptions: AndroidOptions(),
);

/// PIN length enforced by the server.
const int _pinLength = 6;

class ChallengeApprovalSheet extends HookConsumerWidget {
  final SnAuthChallenge challenge;
  final VoidCallback? onResolved;

  const ChallengeApprovalSheet({
    super.key,
    required this.challenge,
    this.onResolved,
  });

  static Future<void> show(
    BuildContext context,
    SnAuthChallenge challenge, {
    VoidCallback? onResolved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) =>
          ChallengeApprovalSheet(challenge: challenge, onResolved: onResolved),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBusy = useState(false);
    final remaining = useState<int?>(null);
    final isMobile = MediaQuery.sizeOf(context).width < 700;

    // PIN status drives whether a PIN / biometric gate is shown. Mirrors the
    // payment overlay: no gate when validation is not required.
    final requiresPin = useState(false);
    final hasStoredPin = useState(false);
    final hasBiometric = useState(false);
    final isInitializing = useState(true);
    final isPinMode = useState(true);

    final pinController = useTextEditingController();

    // Guards the sheet against double-resolution when a poll tick races the
    // local approve/decline path.
    final resolved = useState(false);

    // Surfaced inline rather than only as a transient snackbar, so the user can
    // see why an attempt failed while they retype the PIN.
    final authError = useState<String?>(null);

    // Drives the Approve button's enabled state in PIN mode.
    final pinInput = useState('');
    final pinIsComplete = pinInput.value.length == _pinLength;

    useEffect(() {
      Future(() async {
        try {
          final pinStatus = await fetchWalletPinStatus(ref);
          final requires = pinStatus.validationRequired;
          if (!requires) {
            isInitializing.value = false;
            return;
          }
          requiresPin.value = true;
          final la = LocalAuthentication();
          final supported =
              await la.isDeviceSupported() && await la.canCheckBiometrics;
          hasBiometric.value = supported;
          final stored = await _secureStorage.read(key: _pinStorageKey);
          hasStoredPin.value = stored != null && stored.isNotEmpty;
          isPinMode.value = !(hasStoredPin.value && hasBiometric.value);
        } catch (_) {
          isPinMode.value = true;
        } finally {
          isInitializing.value = false;
        }
      });
      return null;
    }, const []);

    useEffect(() {
      if (challenge.expiredAt == null) return null;
      final expiry = challenge.expiredAt!;
      void updateRemaining() {
        final diff = expiry.difference(DateTime.now());
        remaining.value = diff.inSeconds > 0 ? diff.inSeconds : 0;
      }

      updateRemaining();
      final timer = Timer.periodic(const Duration(seconds: 1), (_) {
        updateRemaining();
      });
      return timer.cancel;
    }, [challenge.expiredAt]);

    // Poll the challenge so a resolution performed on another client (e.g. a
    // second trusted device or a web session) closes this sheet instead of
    // leaving it open until expiry. Mirrors the Device A polling in
    // LoginContent; failures are transient and retried on the next tick.
    useEffect(() {
      if (resolved.value) return null;

      Future<void> pollChallenge() async {
        if (resolved.value) return;
        final seconds = remaining.value;
        if (seconds != null && seconds <= 0) return; // expired; countdown handles it
        try {
          final client = ref.read(solarNetworkClientProvider);
          final resp = await client.dio.get(
            '/stargate/auth/challenge/${challenge.id}',
          );
          if (resolved.value) return;
          final updated = SnAuthChallenge.fromJson(resp.data);
          if (updated.approvedAt != null) {
            resolved.value = true;
            if (!context.mounted) return;
            showSnackBar('challengeApproved'.tr());
            Navigator.pop(context);
            onResolved?.call();
            return;
          }
          if (updated.declinedAt != null) {
            resolved.value = true;
            if (!context.mounted) return;
            showSnackBar('challengeDeclinedError'.tr());
            Navigator.pop(context);
            onResolved?.call();
            return;
          }
          if (updated.deletedAt != null) {
            // Removed server-side; nothing left to decide.
            resolved.value = true;
            if (!context.mounted) return;
            Navigator.pop(context);
            onResolved?.call();
          }
        } on DioException catch (err) {
          if (err.response?.statusCode == 404 && !resolved.value) {
            // Challenge no longer exists; treat as resolved.
            resolved.value = true;
            if (!context.mounted) return;
            Navigator.pop(context);
            onResolved?.call();
          }
        } catch (_) {
          // Best-effort poll; the next tick retries.
        }
      }

      pollChallenge();
      final timer = Timer.periodic(
        const Duration(seconds: 2),
        (_) => pollChallenge(),
      );
      return timer.cancel;
    }, [challenge.id, resolved.value]);

    final expired = remaining.value != null && remaining.value! <= 0;

    // A PIN is required before approving/declining when the account enforces it.
    void clearStoredPin() {
      _secureStorage.delete(key: _pinStorageKey);
      hasStoredPin.value = false;
      isPinMode.value = true;
    }

    // Core network approve + local PIN caching + success teardown. Callers
    // own the isBusy flag so the biometric path can reuse this without a
    // deadlock from a nested busy check.
    Future<void> approveWithCode(String? pin) async {
      final client = ref.read(solarNetworkClientProvider);
      await client.auth.approveChallenge(
        challengeId: challenge.id,
        pinCode: pin,
      );
      if (requiresPin.value &&
          hasBiometric.value &&
          !hasStoredPin.value &&
          pin != null) {
        await _secureStorage.write(key: _pinStorageKey, value: pin);
        hasStoredPin.value = true;
      }
      if (!context.mounted) return;
      resolved.value = true;
      showSnackBar(
        'challengeApprovedByYou'.tr(
          args: [challenge.deviceName ?? 'unknownDevice'.tr()],
        ),
      );
      Navigator.pop(context);
      onResolved?.call();
    }

    Future<void> submitPin(String pin) async {
      if (isBusy.value || pin.length != _pinLength) return;
      isBusy.value = true;
      authError.value = null;
      try {
        await approveWithCode(pin);
      } catch (err) {
        authError.value = _authErrorMessage(err, clearStoredPin);
      } finally {
        isBusy.value = false;
      }
    }

    // No PIN is enforced: approve directly with no credential.
    Future<void> approveDirect() async {
      if (isBusy.value) return;
      isBusy.value = true;
      authError.value = null;
      try {
        await approveWithCode(null);
      } catch (err) {
        authError.value = _authErrorMessage(err, clearStoredPin);
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> approveWithBiometric() async {
      if (isBusy.value) return;
      isBusy.value = true;
      authError.value = null;
      try {
        final la = LocalAuthentication();
        final ok = await la.authenticate(
          localizedReason: 'challengeBiometricReason'.tr(),
          biometricOnly: true,
        );
        if (!ok) {
          isPinMode.value = true;
          authError.value = 'biometricAuthFailed'.tr();
          return;
        }
        final stored = await _secureStorage.read(key: _pinStorageKey);
        if (stored == null || stored.isEmpty) {
          isPinMode.value = true;
          authError.value = 'noStoredPin'.tr();
          return;
        }
        await approveWithCode(stored);
      } catch (err) {
        isPinMode.value = true;
        authError.value = _biometricError(err);
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> performDecline() async {
      if (isBusy.value) return;
      isBusy.value = true;
      authError.value = null;
      try {
        final client = ref.read(solarNetworkClientProvider);
        await client.auth.declineChallenge(
          challengeId: challenge.id,
          pinCode: requiresPin.value && pinIsComplete
              ? pinController.text
              : null,
        );
        if (!context.mounted) return;
        resolved.value = true;
        showSnackBar(
          'challengeDeclinedByYou'.tr(
            args: [challenge.deviceName ?? 'unknownDevice'.tr()],
          ),
        );
        Navigator.pop(context);
        onResolved?.call();
      } catch (err) {
        authError.value = _authErrorMessage(err, clearStoredPin);
      } finally {
        isBusy.value = false;
      }
    }

    Future<void> onApprovePressed() async {
      if (isBusy.value) return;
      if (!requiresPin.value) {
        await approveDirect();
        return;
      }
      if (isPinMode.value) {
        // The button is disabled until the PIN is complete; this is a guard for
        // the keyboard-submit path racing a rebuild.
        if (!pinIsComplete) return;
        await submitPin(pinController.text);
        return;
      }
      await approveWithBiometric();
    }

    /// Whether the Approve button can act right now. In PIN mode it stays
    /// disabled until all digits are entered, instead of silently no-oping.
    final canApprove =
        !isBusy.value &&
        (!requiresPin.value || !isPinMode.value || pinIsComplete);

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final account = ref.watch(userInfoProvider).value;
    final deviceName = challenge.deviceName ?? 'unknownDevice'.tr();

    final location = [
      challenge.city,
      challenge.country,
    ].whereType<String>().where((s) => s.isNotEmpty).join(', ');

    return SheetScaffold(
      titleText: 'challengePendingTitle'.tr(),
      heightFactor: isMobile ? 0.95 : 0.82,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Identity card: the requesting device.
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                authPlatformIcon(challenge.platform),
                                size: 24,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    deviceName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const Gap(2),
                                  Text(
                                    authPlatformName(challenge.platform),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Verification ledger: facts, label-left / value-right.
                      Container(
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Column(
                          children: [
                            AuthFactRow(
                              label: 'challengeIpAddress'.tr(),
                              value: challenge.ipAddress,
                            ),
                            AuthFactRow(
                              label: 'challengeLocation'.tr(),
                              value: location.isNotEmpty
                                  ? location
                                  : 'unknown'.tr(),
                            ),
                            AuthFactRow(
                              label: 'challengeRequested'.tr(),
                              value: RelativeTime(
                                context,
                              ).format(challenge.createdAt),
                            ),
                            if (remaining.value != null)
                              AuthFactRow(
                                label: 'challengeExpiresIn'.tr(),
                                value: 'challengeSeconds'.tr(
                                  args: ['${remaining.value}'],
                                ),
                                valueColor: remaining.value! < 60 && !expired
                                    ? scheme.error
                                    : null,
                              ),
                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: scheme.outlineVariant,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Symbols.verified,
                                    size: 16,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'challengeTrustedHint'.tr(),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Who the approval is attributed to.
                      if (account != null) ...[
                        const SizedBox(height: 12),
                        AuthAuthorityCard(
                          label: 'authConsentApprovingAs'.tr(),
                          accountName: account.nick.isNotEmpty
                              ? account.nick
                              : account.name,
                          accountHandle: account.name,
                          picture: account.profile.picture,
                        ),
                      ],
                      const SizedBox(height: 24),

                      // PIN / biometric gate, only when the account enforces it.
                      if (expired)
                        SizedBox.shrink()
                      else if (isInitializing.value)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (requiresPin.value) ...[
                        if (isPinMode.value)
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'challengeEnterPin'.tr(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const Gap(20),
                                // Six fixed-width fields overflow a narrow
                                // phone, so derive the field size from the
                                // space actually available.
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    const gap = 6.0;
                                    final width =
                                        ((constraints.maxWidth -
                                                    gap * (_pinLength - 1)) /
                                                _pinLength)
                                            .clamp(34.0, 52.0);
                                    return Pinput(
                                      length: _pinLength,
                                      obscureText: true,
                                      keyboardType: TextInputType.number,
                                      controller: pinController,
                                      separatorBuilder: (_) =>
                                          const SizedBox(width: gap),
                                      defaultPinTheme: _pinTheme(
                                        theme,
                                        scheme,
                                        width: width,
                                      ),
                                      focusedPinTheme: _pinTheme(
                                        theme,
                                        scheme,
                                        width: width,
                                        focused: true,
                                      ),
                                      submittedPinTheme: _pinTheme(
                                        theme,
                                        scheme,
                                        width: width,
                                        submitted: true,
                                      ),
                                      onChanged: (value) {
                                        pinInput.value = value;
                                        if (authError.value != null) {
                                          authError.value = null;
                                        }
                                      },
                                      onSubmitted: submitPin,
                                    );
                                  },
                                ),
                                if (hasStoredPin.value && hasBiometric.value)
                                  TextButton(
                                    onPressed: isBusy.value
                                        ? null
                                        : approveWithBiometric,
                                    child: Text('useBiometricInstead'.tr()),
                                  ),
                              ],
                            ),
                          )
                        else
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Symbols.fingerprint,
                                  size: 48,
                                  color: scheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'challengeBiometricPrompt'.tr(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                FilledButton.tonalIcon(
                                  onPressed: approveWithBiometric,
                                  icon: const Icon(Symbols.fingerprint),
                                  label: Text('authenticateNow'.tr()),
                                ),
                                TextButton(
                                  onPressed: () => isPinMode.value = true,
                                  child: Text('usePinInstead'.tr()),
                                ),
                              ],
                            ),
                          ),
                      ] else
                        SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (authError.value != null) ...[
                AuthInlineError(message: authError.value),
                const SizedBox(height: 12),
              ],
              if (expired)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Symbols.timer_off, color: scheme.onErrorContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'challengeExpired'.tr(),
                          style: TextStyle(color: scheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isBusy.value ? null : performDecline,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: scheme.onSurface,
                          side: BorderSide(color: scheme.outlineVariant),
                        ),
                        child: isBusy.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('challengeDecline'.tr()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: canApprove ? onApprovePressed : null,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isBusy.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('challengeApprove'.tr()),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Resolves an approve/decline failure into inline copy.
///
/// Returns null when the failure was already surfaced another way (a biometric
/// [PlatformException], whose caller builds its own message, or an unexpected
/// error handed to [showErrorAlert]).
String? _authErrorMessage(Object err, void Function() clearStoredPin) {
  if (err is PlatformException) return null;

  if (err is DioException) {
    final statusCode = err.response?.statusCode;
    // AUTH_SESSION_NOT_TRUSTED: only trusted sessions can approve/decline.
    if (statusCode == 403) {
      final apiError = ApiError.tryParse(err);
      if (apiError?.code == 'AUTH_SESSION_NOT_TRUSTED') {
        return 'challengeNotTrustedMessage'.tr();
      }
    }
    // Invalid PIN / missing credentials surface as 401/403.
    if (statusCode == 403 || statusCode == 401) {
      clearStoredPin();
      return 'invalidPin'.tr();
    }
  }

  showErrorAlert(err);
  return null;
}

String _biometricError(Object err) {
  if (err is PlatformException) {
    return switch (err.code) {
      'NotAvailable' => 'biometricNotAvailable'.tr(),
      'NotEnrolled' => 'biometricNotEnrolled'.tr(),
      'LockedOut' || 'PermanentlyLockedOut' => 'biometricLockedOut'.tr(),
      _ => 'biometricAuthFailed'.tr(),
    };
  }
  return 'biometricAuthFailed'.tr();
}

PinTheme _pinTheme(
  ThemeData theme,
  ColorScheme scheme, {
  required double width,
  bool focused = false,
  bool submitted = false,
}) {
  return PinTheme(
    width: width,
    height: (width * 1.15).clamp(44.0, 60.0),
    textStyle: theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: focused
          ? Border.all(color: scheme.primary, width: 2)
          : submitted
          ? Border.all(color: scheme.outlineVariant)
          : Border.all(color: scheme.outline),
    ),
  );
}
