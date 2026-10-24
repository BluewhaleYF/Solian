import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/friends_overview.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/chat/widgets/chat_list_screen.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/core/theme.dart';
import 'package:island/data/database.dart';
import 'package:island/route.dart';
import 'package:island/route.gr.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Answers every request with an empty list: the shell's providers reach for
/// the API on build, and a real client would leave dio's retry timers pending
/// past teardown.
class _EmptyAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(const <dynamic>[]),
      200,
      headers: {
        Headers.contentTypeHeader: const ['application/json'],
      },
    );
  }
}

SnChatRoom _room(String id, String name) {
  final now = DateTime.utc(2026);
  return SnChatRoom(
    id: id,
    name: name,
    description: null,
    type: 0,
    picture: null,
    background: null,
    realmId: null,
    accountId: null,
    realm: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    members: null,
    isPinned: false,
  );
}

class _JoinedRooms extends ChatRoomJoinedNotifier {
  _JoinedRooms(this.rooms);

  final List<SnChatRoom> rooms;

  @override
  Stream<List<SnChatRoom>> build() => Stream.value(rooms);
}

class _NoSummaries extends ChatSummary {
  @override
  Future<Map<String, SnChatSummary>> build() async => const {};
}

class _SignedIn extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async {
    final now = DateTime.utc(2026);
    return SnAccount(
      id: 'me',
      name: 'me',
      nick: 'Me',
      language: 'en',
      isSuperuser: false,
      automatedId: null,
      profile: SnAccountProfile(
        id: 'profile-me',
        experience: 0,
        level: 1,
        levelingProgress: 0,
        picture: null,
        background: null,
        verification: null,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
      ),
      perkSubscription: null,
      activatedAt: null,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    );
  }
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets(
    'wide: the chat list pane is guttered evenly on both sides',
    (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1400, 900);
      addTearDown(tester.view.reset);

      final prefs = await SharedPreferences.getInstance();
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
        ..httpClientAdapter = _EmptyAdapter();
      final router = AppRouter();

      await tester.runAsync(() async {
        await tester.pumpWidget(
          EasyLocalization(
            supportedLocales: const [Locale('en', 'US')],
            path: 'assets/i18n',
            saveLocale: false,
            child: Builder(
              builder: (context) => MaterialApp.router(
                locale: const Locale('en', 'US'),
                supportedLocales: const [Locale('en', 'US')],
                localizationsDelegates: context.localizationDelegates,
                routerConfig: router.config(),
                builder: (context, child) => ProviderScope(
                  overrides: [
                    sharedPreferencesProvider.overrideWithValue(prefs),
                    databaseProvider.overrideWithValue(AppDatabase.web()),
                    apiClientProvider.overrideWithValue(dio),
                    chatRoomJoinedProvider.overrideWith(
                      () => _JoinedRooms([
                        _room('r1', 'Design crew'),
                        _room('r2', 'Ops'),
                      ]),
                    ),
                    chatSummaryProvider.overrideWith(_NoSummaries.new),
                    userInfoProvider.overrideWith(_SignedIn.new),
                    friendsOverviewExpandedProvider.overrideWith(
                      (ref) async => const <SnFriendOverviewItem>[],
                    ),
                  ],
                  child: child!,
                ),
              ),
            ),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });

      await router.navigate(const ChatRoute());
      // The shell keeps repeating sync timers that never idle, so settle with
      // the test clock rather than pumpAndSettle.
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(tester.takeException(), isNull);
      expect(find.byType(ChatListWidget), findsOneWidget);

      final window = tester.getSize(find.byType(MaterialApp));
      final list = tester.getRect(find.byType(ChatListWidget));
      // The room pane is the Card the wide branch wraps the routed room in.
      final card = tester.getRect(find.byType(Card).last);
      final rail = tester.getRect(find.byType(NavigationRail));

      // The split reads as one even frame: the rail-to-list gutter, the
      // list-to-room gap and the room-to-window gutter are all the same.
      // Drifting one of them back to a different constant is what made the
      // pane look pushed to one side.
      expect(list.left - rail.right, SolSpace.sm);
      expect(card.left - list.right, SolSpace.sm);
      expect(window.width - card.right, SolSpace.sm);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      while (tester.takeException() != null) {}
    },
  );
}
