import 'package:easy_localization/easy_localization.dart';
import 'package:gap/gap.dart';
import 'package:island/core/network/domain_trust.dart';
import 'package:island/shared/widgets/content/trust_rail_card.dart';
import 'package:island/shared/widgets/hold_to_confirm_button.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

/// Stands in for an image whose host the anti-fraud service would not vouch
/// for, in the middle of whatever the image was embedded in.
///
/// Nothing has failed here — the image is waiting on a decision — so the card
/// reads as the blocked image itself rather than as an error, and carries the
/// same rail and icons as the prompt sheet so both ask the same question in
/// the same voice.
class BlockedImagePlaceholder extends StatelessWidget {
  final Uri uri;
  final DomainTrustResult result;
  final VoidCallback onProceed;

  const BlockedImagePlaceholder({
    super.key,
    required this.uri,
    required this.result,
    required this.onProceed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isBlocked = result.trustLevel == DomainTrustLevel.blocked;
    final accent = isBlocked ? scheme.error : scheme.primary;

    return TrustRailCard(
      accent: accent,
      background: isBlocked
          ? scheme.errorContainer.withOpacity(0.35)
          : scheme.surfaceContainerHigh,
      border: isBlocked
          ? scheme.error.withOpacity(0.35)
          : scheme.outlineVariant,
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isBlocked ? Symbols.gpp_bad : Symbols.gpp_maybe,
                size: 20,
                color: accent,
              ),
              const Gap(8),
              Expanded(
                child: Text(
                  'domainTrustTitle'.tr(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            isBlocked
                ? 'domainUntrustLoadImageDescription'.tr()
                : 'domainTrustLoadImageDescription'.tr(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          if (result.blockReason != null) ...[
            const Gap(10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${'domainTrustReason'.tr()}: ${result.blockReason}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const Gap(12),
          // Everything above explains the decision; everything below is the
          // destination and the one way to act on it.
          Divider(height: 1, color: scheme.outlineVariant),
          const Gap(10),
          Row(
            children: [
              Expanded(
                child: Text(
                  uri.host,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Gap(8),
              isBlocked
                  ? HoldToConfirmButton(
                      dense: true,
                      label: 'domainTrustLongPressLoadImage'.tr(),
                      icon: Symbols.image,
                      onConfirmed: onProceed,
                    )
                  : TextButton.icon(
                      onPressed: onProceed,
                      icon: const Icon(Symbols.image, size: 16),
                      label: Text(
                        'domainTrustLoadImage'.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: scheme.primary,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
