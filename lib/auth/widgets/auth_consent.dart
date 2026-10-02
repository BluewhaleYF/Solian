import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/auth/web_auth/web_auth_app_info.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:material_ui/material_ui.dart';

/// Shared building blocks for every consent surface in the app: the OAuth
/// authorize screen, the QR login approval sheet, the login-challenge sheet and
/// the device-code approval sheet.
///
/// They mirror the web consent pages (`auth/authorize` and `auth/device`) so a
/// user reviewing a request sees the same evidence — who is asking, who they
/// are approving as, and exactly which permissions are granted — no matter
/// which entry point they arrived through.

// ---------------------------------------------------------------------------
// Platform
// ---------------------------------------------------------------------------

/// Client platform codes used by Stargate (`model.ClientPlatform`).
const int kAuthPlatformWeb = 1;
const int kAuthPlatformIos = 2;
const int kAuthPlatformAndroid = 3;
const int kAuthPlatformMacos = 4;
const int kAuthPlatformWindows = 5;
const int kAuthPlatformLinux = 6;

IconData authPlatformIcon(int? platform) {
  return switch (platform) {
    kAuthPlatformIos => Symbols.phone_iphone,
    kAuthPlatformAndroid => Symbols.phone_android,
    kAuthPlatformMacos ||
    kAuthPlatformWindows ||
    kAuthPlatformLinux => Symbols.computer,
    kAuthPlatformWeb => Symbols.language,
    _ => Symbols.devices,
  };
}

String authPlatformName(int? platform) {
  return switch (platform) {
    kAuthPlatformIos => 'platformIos'.tr(),
    kAuthPlatformAndroid => 'platformAndroid'.tr(),
    kAuthPlatformMacos => 'platformMacos'.tr(),
    kAuthPlatformWindows => 'platformWindows'.tr(),
    kAuthPlatformLinux => 'platformLinux'.tr(),
    kAuthPlatformWeb => 'platformWeb'.tr(),
    _ => 'platformUnknown'.tr(),
  };
}

// ---------------------------------------------------------------------------
// Scopes
// ---------------------------------------------------------------------------

/// Maps an OAuth scope token to its localization key. Unknown scopes are
/// returned unchanged so callers can render the raw token instead of inventing
/// a description for a permission they do not understand.
String authScopeLabelKey(String scope) {
  switch (scope) {
    case 'account.connections':
      return 'authorizeScopeAccountConnections';
    case 'posts.create':
      return 'authorizeScopePostsCreate';
    case 'posts.react':
      return 'authorizeScopePostsReact';
    case 'posts.create.blog':
      return 'authorizeScopePostsCreateBlog';
    case 'notifications.push':
      return 'authorizeScopeNotificationsPush';
    case 'openid':
      return 'authorizeScopeOpenId';
    case 'profile':
      return 'authorizeScopeProfile';
    case 'email':
      return 'authorizeScopeEmail';
    case 'offline_access':
      return 'authorizeScopeOfflineAccess';
    case '*':
      return 'authorizeScopeAll';
    default:
      return scope;
  }
}

/// The requested-permission list.
///
/// Wildcard access is called out in the error color, matching the web warning
/// triangle; every other scope gets a quiet check.
class AuthScopeList extends StatelessWidget {
  final List<String> scopes;

  /// Tighter spacing for sheets that already carry several blocks.
  final bool dense;

  const AuthScopeList({super.key, required this.scopes, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (scopes.isEmpty) {
      return Text(
        'authorizeAppNoScopes'.tr(),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final scope in scopes)
          Padding(
            padding: EdgeInsets.only(bottom: dense ? 10 : 12),
            child: _AuthScopeRow(scope: scope),
          ),
      ],
    );
  }
}

class _AuthScopeRow extends StatelessWidget {
  final String scope;

  const _AuthScopeRow({required this.scope});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isFullAccess = scope == '*';
    final labelKey = authScopeLabelKey(scope);
    final isKnown = labelKey != scope;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            isFullAccess ? Symbols.warning : Symbols.check_circle,
            size: 16,
            color: isFullAccess ? scheme.error : scheme.onSurfaceVariant,
          ),
        ),
        const Gap(10),
        Expanded(
          child: isKnown
              ? Text(
                  labelKey.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                    color: isFullAccess ? scheme.error : null,
                  ),
                )
              : Text(
                  scope,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    color: scheme.onSurfaceVariant,
                  ),
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// App identity
// ---------------------------------------------------------------------------

/// The requesting application: icon, name, "wants access to your account", and
/// who publishes it.
class AuthRequestingAppCard extends StatelessWidget {
  final String appName;
  final IDisplayableCloudFile? picture;
  final String? description;
  final String? homeUri;
  final SnVerificationMark? verification;
  final String? publisherName;
  final IDisplayableCloudFile? publisherPicture;
  final SnVerificationMark? publisherVerification;

  /// Rendered under the app name where the sheet is not about an app request,
  /// e.g. the platform of the device that started a login.
  final Widget? subtitle;

  /// Shown when there is no icon to render.
  final IconData fallbackIcon;

  final double iconSize;

  const AuthRequestingAppCard({
    super.key,
    required this.appName,
    this.picture,
    this.description,
    this.homeUri,
    this.verification,
    this.publisherName,
    this.publisherPicture,
    this.publisherVerification,
    this.subtitle,
    this.fallbackIcon = Symbols.extension,
    this.iconSize = 52,
  });

  /// Builds the card from the sparse payload the auth endpoints return,
  /// enriched by the public app profile (`/develop/apps/{slug}`) when one could
  /// be resolved. Mirrors `device.vue`, which falls back to the app profile for
  /// the icon and to the developer record for the publisher.
  factory AuthRequestingAppCard.fromClient({
    required String clientName,
    IDisplayableCloudFile? clientPicture,
    String? clientDescription,
    String? clientHomeUri,
    WebAuthAppInfo? profile,
    Widget? subtitle,
    IconData fallbackIcon = Symbols.extension,
    double iconSize = 52,
  }) {
    final publisher = profile?.project.developer.publisher;
    final publisherNick = publisher?.nick.trim() ?? '';
    final publisherName = publisherNick.isNotEmpty
        ? publisherNick
        : publisher?.name;
    final profileName = profile?.name.trim() ?? '';
    final profileDescription = profile?.description.trim() ?? '';

    return AuthRequestingAppCard(
      appName: profileName.isNotEmpty ? profile!.name : clientName,
      picture: profile?.picture ?? clientPicture,
      description: profileDescription.isNotEmpty
          ? profile!.description
          : clientDescription,
      homeUri: _profileHomePage(profile) ?? clientHomeUri,
      verification: profile?.verification,
      publisherName: publisherName,
      publisherPicture: publisher?.picture,
      publisherVerification: publisher?.verification,
      subtitle: subtitle,
      fallbackIcon: fallbackIcon,
      iconSize: iconSize,
    );
  }

  /// The Develop API serializes with `SnakeCaseLower`; older payloads used
  /// camelCase. Accept either.
  static String? _profileHomePage(WebAuthAppInfo? profile) {
    if (profile == null) return null;
    final value = profile.links['home_page'] ?? profile.links['homePage'];
    return value?.trim().isEmpty == true ? null : value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: iconSize,
          height: iconSize,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: picture != null
                  ? CloudImageWidget(file: picture, fit: BoxFit.cover)
                  : Icon(
                      fallbackIcon,
                      size: iconSize * 0.5,
                      color: scheme.onSurfaceVariant,
                    ),
            ),
          ),
        ),
        const Gap(14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      appName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (verification != null) ...[
                    const Gap(4),
                    VerificationMark(mark: verification!),
                  ],
                ],
              ),
              const Gap(2),
              subtitle ??
                  Text(
                    'authorizeAppWantsAccess'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              AppOwnerInfo(
                publisherName: publisherName,
                publisherPicture: publisherPicture,
                publisherVerification: publisherVerification,
                homeUri: homeUri,
              ),
              if (description != null && description!.trim().isNotEmpty) ...[
                const Gap(10),
                Text(
                  description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// "by `<developer>` `<verification mark>` `<home page>`" — the provenance line
/// from the web consent pages. Renders nothing when there is no evidence.
class AppOwnerInfo extends StatelessWidget {
  final String? publisherName;
  final IDisplayableCloudFile? publisherPicture;
  final SnVerificationMark? publisherVerification;
  final String? homeUri;

  const AppOwnerInfo({
    super.key,
    this.publisherName,
    this.publisherPicture,
    this.publisherVerification,
    this.homeUri,
  });

  /// Host of [uri], falling back to the raw string for values that do not parse
  /// as an absolute URL.
  static String hostLabel(String uri) {
    final parsed = Uri.tryParse(uri);
    if (parsed == null || parsed.host.isEmpty) return uri;
    return parsed.host;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasPublisher =
        publisherName != null && publisherName!.trim().isNotEmpty;
    final hasHome = homeUri != null && homeUri!.trim().isNotEmpty;
    if (!hasPublisher && publisherVerification == null && !hasHome) {
      return const SizedBox.shrink();
    }

    final rowStyle = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (hasPublisher || publisherVerification != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasPublisher) ...[
                  Text('authConsentBy'.tr(), style: rowStyle),
                  const Gap(4),
                  ProfilePictureWidget(
                    file: publisherPicture,
                    radius: 8,
                    fallbackName: publisherName,
                    fallbackIcon: Symbols.person,
                  ),
                  const Gap(4),
                  Text(
                    publisherName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
                if (publisherVerification != null) ...[
                  const Gap(4),
                  VerificationMark(mark: publisherVerification!),
                ],
              ],
            ),
          if (hasHome)
            Text(
              hostLabel(homeUri!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}

/// "You are approving as `<account>`" — the accountability line from the web
/// consent rail.
class AuthAuthorityCard extends StatelessWidget {
  final String label;
  final String accountName;
  final String? accountHandle;
  final IDisplayableCloudFile? picture;

  const AuthAuthorityCard({
    super.key,
    required this.label,
    required this.accountName,
    this.accountHandle,
    this.picture,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          ProfilePictureWidget(file: picture, radius: 18, fallbackName: accountName),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const Gap(2),
                Text(
                  accountHandle == null || accountHandle!.isEmpty
                      ? accountName
                      : '$accountName · @${accountHandle!}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// User code
// ---------------------------------------------------------------------------

/// The device-flow user code, set large and monospaced so it can be compared
/// character by character against the requesting device.
class AuthUserCodeCard extends StatelessWidget {
  final String userCode;

  /// When true the code is copied on tap.
  final bool copyOnTap;

  const AuthUserCodeCard({
    super.key,
    required this.userCode,
    this.copyOnTap = true,
  });

  void _copy() {
    Clipboard.setData(ClipboardData(text: userCode));
    showSnackBar('copied'.tr());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(14);

    final content = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: radius,
      ),
      child: Column(
        children: [
          Text(
            'accountQrDeviceAuthUserCode'.tr(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const Gap(6),
          Text(
            userCode,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );

    // The card carries its own Material so the ink response has a surface to
    // paint on wherever it is used, rather than relying on an ambient one.
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: radius,
      child: copyOnTap
          ? InkWell(
              borderRadius: radius,
              onTap: _copy,
              child: content,
            )
          : content,
    );
  }
}

// ---------------------------------------------------------------------------
// Ledger rows
// ---------------------------------------------------------------------------

/// One label/value fact. Used for the request ledger (IP, location, expiry)
/// and for the compact detail rows in the QR sheets.
class AuthFactRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String? value;
  final Color? valueColor;
  final bool dense;

  const AuthFactRow({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (dense) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: scheme.onSurfaceVariant),
              const Gap(12),
            ],
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value!,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? scheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Ledger row: the label keeps its intrinsic width so long values (an IP,
    // a location) get the remainder instead of forcing a 50/50 split.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: scheme.onSurfaceVariant),
            const Gap(12),
          ],
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              value!,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Errors and end states
// ---------------------------------------------------------------------------

/// Non-blocking inline error, matching the web consent pages which keep the
/// decision buttons reachable while showing what went wrong.
class AuthInlineError extends StatelessWidget {
  final String? message;

  const AuthInlineError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Symbols.error, size: 18, color: scheme.onErrorContainer),
          const Gap(10),
          Expanded(
            child: Text(
              message!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onErrorContainer,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// How a consent request ended.
enum AuthConsentOutcome { approved, declined, expired }

String _outcomeTitle(AuthConsentOutcome outcome) {
  return switch (outcome) {
    AuthConsentOutcome.approved => 'authConsentDeviceAuthorized'.tr(),
    AuthConsentOutcome.declined => 'authConsentRequestDenied'.tr(),
    AuthConsentOutcome.expired => 'authConsentCodeExpired'.tr(),
  };
}

String _outcomeHint(AuthConsentOutcome outcome) {
  return switch (outcome) {
    AuthConsentOutcome.approved => 'authConsentDeviceAuthorizedHint'.tr(),
    AuthConsentOutcome.declined => 'authConsentRequestDeniedHint'.tr(),
    AuthConsentOutcome.expired => 'authConsentCodeExpiredHint'.tr(),
  };
}

/// The terminal screen shown once a request can no longer be decided, so the
/// sheet never leaves a dead-looking Approve button behind.
class AuthResolvedPanel extends StatelessWidget {
  final AuthConsentOutcome outcome;

  /// Appended to the hint when the decision was made from another client.
  final String? remoteNote;
  final VoidCallback? onClose;
  final String? closeLabel;

  const AuthResolvedPanel({
    super.key,
    required this.outcome,
    this.remoteNote,
    this.onClose,
    this.closeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final approved = outcome == AuthConsentOutcome.approved;
    final accent = approved ? scheme.primary : scheme.error;
    final container = approved
        ? scheme.primaryContainer
        : scheme.errorContainer;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: container, shape: BoxShape.circle),
            child: Icon(
              switch (outcome) {
                AuthConsentOutcome.approved => Symbols.check_circle,
                AuthConsentOutcome.declined => Symbols.cancel,
                AuthConsentOutcome.expired => Symbols.timer_off,
              },
              size: 36,
              color: accent,
            ),
          ),
        ),
        const Gap(20),
        Text(
          _outcomeTitle(outcome),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Gap(8),
        Text(
          _outcomeHint(outcome),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        if (remoteNote != null && remoteNote!.trim().isNotEmpty) ...[
          const Gap(12),
          Text(
            remoteNote!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
        const Gap(24),
        FilledButton(
          onPressed: onClose ?? () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          child: Text(closeLabel ?? 'done'.tr()),
        ),
      ],
    );
  }
}
