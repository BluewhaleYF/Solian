import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/core/theme.dart';
import 'package:island/data/message.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Pinned messages of the open room, as a floating card above the timeline.
///
/// The strip is not a band across the screen: it insets from the timeline's
/// edges and paints an [ExploreCard] surface, matching the floating rows of the
/// discovery pages. Its header collapses the strip, and the collapsed card
/// still carries the count and the expand affordance.
class PinnedMessagesBar extends StatefulWidget {
  final List<SnChatMessagePin> pins;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final void Function(SnChatMessagePin pin) onTapPin;
  final VoidCallback onViewAll;
  final Future<LocalChatMessage?> Function(String messageId) fetchMessageById;

  const PinnedMessagesBar({
    super.key,
    required this.pins,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.onTapPin,
    required this.onViewAll,
    required this.fetchMessageById,
  });

  @override
  State<PinnedMessagesBar> createState() => PinnedMessagesBarState();
}

class PinnedMessagesBarState extends State<PinnedMessagesBar> {
  late final PageController _pageController;
  int _currentPage = 0;
  final Map<String, LocalChatMessage> _fetchedMessages = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchAllMessages();
  }

  @override
  void didUpdateWidget(PinnedMessagesBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pins != widget.pins) {
      _fetchAllMessages();
    }
  }

  Future<void> _fetchAllMessages() async {
    for (final pin in widget.pins) {
      if (_fetchedMessages.containsKey(pin.messageId)) continue;
      final message = await widget.fetchMessageById(pin.messageId);
      if (mounted && message != null) {
        setState(() => _fetchedMessages[pin.messageId] = message);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pins.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SolSpace.md,
        SolSpace.md,
        SolSpace.md,
        SolSpace.sm,
      ),
      child: ExploreCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: widget.onToggleCollapse,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SolSpace.md,
                  vertical: SolSpace.xs + 2,
                ),
                child: Row(
                  children: [
                    Icon(
                      Symbols.push_pin,
                      size: 15,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: SolSpace.sm),
                    Expanded(
                      child: Text(
                        '${widget.pins.length} pinned message${widget.pins.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (widget.pins.length > 1) ...[
                      _buildPageIndicator(context),
                      const SizedBox(width: SolSpace.xs),
                    ],
                    if (widget.pins.length > 1)
                      IconButton(
                        icon: const Icon(Symbols.list, size: 16),
                        onPressed: widget.onViewAll,
                        tooltip: 'viewAll'.tr(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    Icon(
                      widget.isCollapsed
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            if (!widget.isCollapsed)
              SizedBox(
                height: 42,
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: widget.pins.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final pin = widget.pins[index];
                    final message = _fetchedMessages[pin.messageId];
                    final sender = message?.sender;
                    final content = message?.content ?? '';
                    final createdAt = message?.createdAt;

                    final timestamp = createdAt != null
                        ? (DateTime.now().difference(createdAt).inDays > 365
                              ? DateFormat(
                                  'yyyy/MM/dd HH:mm',
                                ).format(createdAt.toLocal())
                              : DateTime.now().difference(createdAt).inDays > 0
                              ? DateFormat(
                                  'MM/dd HH:mm',
                                ).format(createdAt.toLocal())
                              : DateFormat('HH:mm').format(createdAt.toLocal()))
                        : '';

                    return InkWell(
                      onTap: () => widget.onTapPin(pin),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SolSpace.md,
                          vertical: SolSpace.xs,
                        ),
                        child: message == null
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                  const SizedBox(width: SolSpace.sm),
                                  Text(
                                    'Loading...',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withOpacity(0.5),
                                        ),
                                  ),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (sender != null)
                                    ProfilePictureWidget(
                                      file: sender.account.profile.picture,
                                      fallbackName: sender.account.nick,
                                      radius: 14,
                                    ),
                                  const SizedBox(width: SolSpace.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            if (sender != null)
                                              Flexible(
                                                child: AccountName(
                                                  account: sender.account,
                                                  textOverride:
                                                      sender.nick?.isNotEmpty ==
                                                          true
                                                      ? sender.nick
                                                      : sender.account.nick,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                  hideVerificationMark: true,
                                                  hideOverlay: true,
                                                ),
                                              ),
                                            if (timestamp.isNotEmpty) ...[
                                              const SizedBox(width: 6),
                                              Text(
                                                timestamp,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant
                                                          .withOpacity(0.5),
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 1),
                                        _buildContentPreview(
                                          context,
                                          content,
                                          message.attachments,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.pins.length.clamp(0, 5), (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: isActive ? 12 : 5,
          height: 5,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2.5),
          ),
        );
      }),
    );
  }

  Widget _buildContentPreview(
    BuildContext context,
    String content,
    List<Map<String, dynamic>> attachments,
  ) {
    if (content.isNotEmpty) {
      return Text(
        content,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    if (attachments.isNotEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.attach_file,
            size: 14,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
          const SizedBox(width: 4),
          Text(
            'hasAttachments'.plural(attachments.length),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withOpacity(0.6),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
