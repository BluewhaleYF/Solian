import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stands in for `friendsOverviewProvider`: an autoDispose provider that
/// watches the SDK client, which the chat list watches.
final _chatListDependentProvider = FutureProvider.autoDispose<Object?>((
  ref,
) async {
  ref.watch(solarNetworkClientProvider);
  return null;
});

/// Stands in for `friend_status_listener`, which keeps the friends overview
/// alive through a weak listener after the chat list unmounts.
final _chatListKeeperProvider = Provider<void>((ref) {
  ref.listen(_chatListDependentProvider, (_, _) {});
});

class _ChatLike extends ConsumerWidget {
  const _ChatLike();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // What ChatListBodyWidget watches.
    ref.watch(_chatListKeeperProvider);
    ref.watch(apiClientProvider);
    ref.watch(_chatListDependentProvider);
    return const SizedBox();
  }
}

class _Host extends ConsumerStatefulWidget {
  const _Host({super.key});

  @override
  ConsumerState<_Host> createState() => _HostState();
}

class _HostState extends ConsumerState<_Host> {
  var _showChatList = false;

  void showChatList() => setState(() => _showChatList = true);

  void hideChatList() => setState(() => _showChatList = false);

  /// What the relay-route listener in `main.dart` runs on a route change.
  void changeNetworkRoute() => refreshNetworkClients(ref);

  @override
  Widget build(BuildContext context) {
    return _showChatList ? const _ChatLike() : const SizedBox();
  }
}

void main() {
  testWidgets('a route change made while the chat list is unmounted does not '
      'invalidate providers during the next build', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final hostKey = GlobalKey<_HostState>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWith((ref) => prefs)],
        child: MaterialApp(home: _Host(key: hostKey)),
      ),
    );
    await tester.pumpAndSettle();

    hostKey.currentState!.showChatList();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Chat list goes off screen; the client chain loses its active subscribers.
    hostKey.currentState!.hideChatList();
    await tester.pumpAndSettle();

    // The route changes while nothing watches the clients.
    hostKey.currentState!.changeNetworkRoute();
    await tester.pump();

    // Coming back must not flush a dirty client chain inside this build: the
    // rebuild hands the dependent a new client, and Riverpod then calls
    // setState() on the ProviderScope mid-build ("This UncontrolledProviderScope
    // widget cannot be marked as needing to build…").
    hostKey.currentState!.showChatList();
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
