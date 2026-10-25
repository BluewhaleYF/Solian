import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/chat_member_list_tile.dart';
import 'package:island/core/theme.dart';
import 'package:island/shared/widgets/empty_state.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Bottom sheet listing members who can be invited to the current call.
///
/// Mirrors the member-list sheet in [chat_detail_screen] (a search field over
/// a plain list); the trailing call button pops the sheet with the selected
/// member.
class CallInviteSheet extends HookConsumerWidget {
  final List<SnChatMember> candidates;

  const CallInviteSheet({super.key, required this.candidates});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final query = useListenable(searchController).text.trim().toLowerCase();

    final filtered = query.isEmpty
        ? candidates
        : candidates.where((member) {
            final account = member.account;
            return account.nick.toLowerCase().contains(query) ||
                account.name.toLowerCase().contains(query);
          }).toList();

    return SheetScaffold(
      titleText: 'inviteToCall'.tr(),
      heightFactor: 0.72,
      // Still searchable while the list is empty: a query that matches nobody
      // must stay editable instead of being replaced by a placeholder.
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SolSpace.lg,
              SolSpace.xs,
              SolSpace.lg,
              SolSpace.md,
            ),
            child: SearchBar(
              controller: searchController,
              hintText: 'Search member account',
              leading: const Icon(Symbols.search),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: SolSpace.lg),
              ),
              trailing: [
                if (searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Symbols.close),
                    tooltip: 'close'.tr(),
                    onPressed: searchController.clear,
                  ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? EmptyState(
                    icon: Symbols.search_off,
                    title: 'noResultsFound'.tr(),
                    compact: true,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: SolSpace.lg),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final member = filtered[index];
                      return ChatMemberListTile(
                        member: member,
                        enableProfileCard: false,
                        trailing: IconButton.filledTonal(
                          icon: const Icon(Symbols.call),
                          tooltip: 'inviteToCall'.tr(),
                          onPressed: () => Navigator.pop(context, member),
                        ),
                        onTap: () => Navigator.pop(context, member),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
