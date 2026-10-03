import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:island/core/network/domain_trust.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/content/trust_rail_card.dart';
import 'package:island/shared/widgets/hold_to_confirm_button.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

enum DomainTrustAction { openLink, loadImage }

enum DomainTrustDecision { proceed, cancelled }

Future<DomainTrustDecision> showDomainTrustSheet(
  BuildContext context, {
  required Uri uri,
  required DomainTrustResult result,
  required DomainTrustAction action,
}) async {
  final decision = await showModalBottomSheet<DomainTrustDecision>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    builder: (context) =>
        DomainTrustSheet(uri: uri, result: result, action: action),
  );
  return decision ?? DomainTrustDecision.cancelled;
}

/// The anti-fraud prompt shown before leaving the app for a domain the
/// service did not verify, or before loading an image from a blocked one.
///
/// The prompt has one job: say what will happen, show where it goes, show why
/// it was flagged, and let the user back out. Nothing here is decorative —
/// the verdict lives in the header icon, the rail and the accent, so the
/// destination itself can be presented plainly.
class DomainTrustSheet extends StatelessWidget {
  final Uri uri;
  final DomainTrustResult result;
  final DomainTrustAction action;

  const DomainTrustSheet({
    super.key,
    required this.uri,
    required this.result,
    required this.action,
  });

  /// `SheetScaffold` renders exactly the height it is given — the content goes
  /// into an `Expanded` slot, so it cannot hug its child — while this prompt
  /// has to stay short instead of taking the default 80% of the screen.
  ///
  /// The height is therefore summed from the blocks below: the wrapping ones
  /// (description, destination, block reason) are measured with a
  /// [TextPainter] in the style, width and text scale their widgets get, and
  /// the fixed ones are constants. A warning that the actions have slipped
  /// below the fold is worse than a few pixels of air, so the sum keeps a
  /// margin of one line.
  ///
  /// `SheetScaffold`'s own header is 28dp of padding around the close
  /// button's 48dp tap target, and does not scale with the content.
  static const _headerBlock = 76.0;
  static const _gapBeforeDestination = 16.0;
  static const _gapBeforeReason = 12.0;
  static const _gapBeforeActions = 20.0;
  static const _reasonPadding = 24.0;
  static const _reasonIconWidth = 26.0;
  static const _reasonIconHeight = 18.0;
  static const _sheetPadding = 40.0;
  static const _bottomBlock = 24.0;

  /// One row of buttons at the 48dp tap target, with the margin a label in a
  /// bigger text scale would eat.
  static const _actionsBlock = 56.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isBlocked = result.trustLevel == DomainTrustLevel.blocked;
    final accent = isBlocked ? scheme.error : scheme.primary;

    final description = _descriptionKey.tr();
    final descriptionStyle = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurface,
      height: 1.45,
    );
    final hostStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final urlStyle = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final reasonText = result.blockReason == null
        ? null
        : '${'domainTrustReason'.tr()}: ${result.blockReason}';
    final reasonColor = isBlocked
        ? scheme.onErrorContainer
        : scheme.onSurfaceVariant;
    final reasonStyle = theme.textTheme.bodySmall?.copyWith(
      color: reasonColor,
      height: 1.4,
    );

    // `useSafeArea` keeps the sheet's top clear but leaves its bottom edge to
    // the content, so the home indicator is accounted for here as well.
    final contentWidth = MediaQuery.of(context).size.width - _sheetPadding;
    final cardInnerWidth =
        contentWidth -
        TrustRailCard.railWidth -
        TrustRailCard.defaultPadding.horizontal;
    final destinationBlock =
        TrustRailCard.defaultPadding.vertical +
        2 +
        _textHeight(context, uri.host, hostStyle, cardInnerWidth, maxLines: 1) +
        _textHeight(
          context,
          uri.toString(),
          urlStyle,
          cardInnerWidth,
          maxLines: 2,
        );
    final height =
        _headerBlock +
        _bottomBlock +
        _actionsBlock +
        _gapBeforeActions +
        destinationBlock +
        _gapBeforeDestination +
        _textHeight(context, description, descriptionStyle, contentWidth) +
        (reasonText == null
            ? 0
            : _gapBeforeReason +
                  _reasonPadding +
                  math.max(
                    _reasonIconHeight,
                    _textHeight(
                      context,
                      reasonText,
                      reasonStyle,
                      contentWidth - _reasonIconWidth - _reasonPadding,
                    ),
                  )) +
        MediaQuery.of(context).padding.bottom;

    return SheetScaffold(
      titleText: 'domainTrustTitle'.tr(),
      leading: Icon(
        isBlocked ? Symbols.gpp_bad : Symbols.gpp_maybe,
        color: accent,
        size: 26,
      ),
      height: height,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          _sheetPadding / 2,
          0,
          _sheetPadding / 2,
          _bottomBlock,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(description, style: descriptionStyle),
            const Gap(_gapBeforeDestination),
            TrustRailCard(
              accent: accent,
              background: scheme.surfaceContainerHigh,
              border: isBlocked
                  ? scheme.error.withOpacity(0.35)
                  : scheme.outlineVariant,
              padding: TrustRailCard.defaultPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    uri.host,
                    style: hostStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(2),
                  Text(
                    uri.toString(),
                    style: urlStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (reasonText != null) ...[
              const Gap(_gapBeforeReason),
              Container(
                padding: const EdgeInsets.all(_reasonPadding / 2),
                decoration: BoxDecoration(
                  color: isBlocked
                      ? scheme.errorContainer
                      : scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Symbols.report,
                      size: _reasonIconHeight,
                      color: reasonColor,
                    ),
                    const Gap(8),
                    Expanded(child: Text(reasonText, style: reasonStyle)),
                  ],
                ),
              ),
            ],
            const Gap(_gapBeforeActions),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: uri.toString()));
                      showSnackBar('copyToClipboard'.tr());
                    },
                    icon: const Icon(Symbols.content_copy, size: 18),
                    label: Text(
                      'domainTrustCopyLink'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: isBlocked
                      ? HoldToConfirmButton(
                          label: _ctaKey.tr(),
                          icon: _actionIcon,
                          onConfirmed: () => Navigator.pop(
                            context,
                            DomainTrustDecision.proceed,
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: () => Navigator.pop(
                            context,
                            DomainTrustDecision.proceed,
                          ),
                          icon: Icon(_actionIcon, size: 18),
                          label: Text(
                            _ctaKey.tr(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _textHeight(
    BuildContext context,
    String text,
    TextStyle? style,
    double width, {
    int? maxLines,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: maxLines,
    )..layout(maxWidth: width);
    return painter.height;
  }

  IconData get _actionIcon => action == DomainTrustAction.openLink
      ? Symbols.open_in_new
      : Symbols.image;

  String get _descriptionKey {
    if (result.trustLevel == DomainTrustLevel.blocked) {
      return action == DomainTrustAction.openLink
          ? 'domainUntrustOpenLinkDescription'
          : 'domainUntrustLoadImageDescription';
    }
    return action == DomainTrustAction.openLink
        ? 'domainTrustOpenLinkDescription'
        : 'domainTrustLoadImageDescription';
  }

  String get _ctaKey {
    if (result.trustLevel == DomainTrustLevel.blocked) {
      return action == DomainTrustAction.openLink
          ? 'domainTrustLongPressOpen'
          : 'domainTrustLongPressLoadImage';
    }
    return action == DomainTrustAction.openLink
        ? 'domainTrustOpenAnyway'
        : 'domainTrustLoadImage';
  }
}
