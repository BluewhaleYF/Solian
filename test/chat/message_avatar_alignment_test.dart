import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/messages_notifier.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/chat/pods/chat_room_state.dart';
import 'package:island/chat/widgets/room_message_list.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island/data/database.dart';
import 'package:island/data/message.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

/// A grouped sender draws a single sticky avatar for the whole group while an
/// ungrouped message draws its own avatar inside the row. Both must land on the
/// same left edge: the group overlay is positioned in the list's coordinate
/// space, which skips the selection stripe that MessageItemWrapper reserves
/// inside every row.
class _EmptyResponseAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions _,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async => ResponseBody.fromString(
    '{}',
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

class _FakeWebSocketService extends WebSocketService {
  final _controller = StreamController<WebSocketPacket>.broadcast();

  @override
  Stream<WebSocketPacket> get dataStream => _controller.stream;
}

class _FakeMessagesNotifier extends MessagesNotifier {
  @override
  FutureOr<List<LocalChatMessage>> build(String roomId) => const [];

  // The room state pages when the list nears its oldest end; the fake room has
  // no history to page, and a real page here would outlive the test harness.
  @override
  Future<void> loadMore({int? offset}) async {}

  @override
  Future<void> loadMoreBeforeOldest() async {}

  @override
  Future<MessageLoadGap?> compactForOlderScroll({
    int retainedMessagesPerSection = 100,
  }) async => null;
}

class _FakeRoomNotifier extends ChatRoomNotifier {
  @override
  Future<SnChatRoom?> build(String? identifier) async => null;
}

class _FakeIdentityNotifier extends ChatRoomIdentityNotifier {
  @override
  Future<SnChatMember?> build(String? identifier) async => null;
}

SnChatMember _member(String id) {
  final now = DateTime.utc(2026);
  return SnChatMember(
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    id: 'member-$id',
    chatRoomId: 'room-1',
    chatRoom: null,
    accountId: id,
    account: SnAccount(
      id: id,
      name: id,
      nick: id,
      language: 'en',
      isSuperuser: false,
      automatedId: null,
      profile: SnAccountProfile(
        id: 'profile-$id',
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
    ),
    nick: null,
    notify: 0,
    joinedAt: now,
    breakUntil: null,
    timeoutUntil: null,
    chatGroupId: null,
    chatGroup: null,
    lastReadAt: null,
    status: null,
    realmNick: null,
    realmBio: null,
    realmExperience: null,
    realmLevel: null,
    realmLevelingProgress: null,
    realmLabel: null,
  );
}

LocalChatMessage _message(String id, String senderId, DateTime at) {
  return LocalChatMessage.fromRemoteMessage(
    SnChatMessage(
      createdAt: at,
      updatedAt: at,
      id: id,
      content: 'hello from $id',
      type: 'text',
      senderId: senderId,
      sender: _member(senderId),
      chatRoomId: 'room-1',
    ),
    MessageStatus.sent,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late _FakeWebSocketService ws;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() async {
    database = AppDatabase.web();
    ws = _FakeWebSocketService();
  });

  tearDown(() async {
    await database.close();
    await ws._controller.close();
  });

  for (final displayStyle in ['bubble', 'column']) {
    testWidgets(
      'grouped and ungrouped avatars share a left edge ($displayStyle)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(420, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        SharedPreferences.setMockInitialValues({
          kAppMessageDisplayStyle: displayStyle,
        });
        final preferences = await SharedPreferences.getInstance();

        final base = DateTime.utc(2026, 1, 1, 12);
        // Newest first, the order RoomMessageList receives from the room.
        final messages = [
          _message('m2', 'alice', base),
          _message('m1', 'alice', base.subtract(const Duration(minutes: 1))),
          _message('s1', 'bob', base.subtract(const Duration(minutes: 30))),
        ];

        await tester.runAsync(() async {
          await tester.pumpWidget(
            EasyLocalization(
              supportedLocales: const [Locale('en', 'US')],
              path: 'assets/i18n',
              saveLocale: false,
              child: Builder(
                builder: (context) => MaterialApp(
                  locale: const Locale('en', 'US'),
                  supportedLocales: const [Locale('en', 'US')],
                  localizationsDelegates: context.localizationDelegates,
                  home: ProviderScope(
                    retry: (_, _) => null,
                    overrides: [
                      databaseProvider.overrideWithValue(database),
                      sharedPreferencesProvider.overrideWithValue(preferences),
                      tokenProvider.overrideWithValue(null),
                      apiClientProvider.overrideWithValue(
                        Dio()..httpClientAdapter = _EmptyResponseAdapter(),
                      ),
                      websocketProvider.overrideWithValue(ws),
                      messagesProvider(
                        'room-1',
                      ).overrideWith(() => _FakeMessagesNotifier()),
                      chatRoomProvider(
                        'room-1',
                      ).overrideWith(() => _FakeRoomNotifier()),
                      chatRoomIdentityProvider(
                        'room-1',
                      ).overrideWith(() => _FakeIdentityNotifier()),
                    ],
                    child: Scaffold(
                      body: RoomMessageList(
                        roomId: 'room-1',
                        messages: messages,
                        roomAsync: const AsyncValue.data(null),
                        chatIdentity: const AsyncValue.data(null),
                        onJump: (_) {},
                        onLoadMessageGap: (_) async {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 200));
        });
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        final listLeft = tester.getTopLeft(find.byType(RoomMessageList)).dx;
        final avatars = find.byType(ProfilePictureWidget);
        expect(
          avatars,
          findsNWidgets(2),
          reason: 'one avatar for the alice group, one for bob',
        );

        final avatarBoxes = tester.renderObjectList<RenderBox>(avatars).toList()
          ..sort(
            (a, b) => a
                .localToGlobal(Offset.zero)
                .dy
                .compareTo(b.localToGlobal(Offset.zero).dy),
          );
        final lefts = avatarBoxes
            .map((box) => box.localToGlobal(Offset.zero).dx - listLeft)
            .toList();

        // The group avatar sits above bob's, both inset by the row's 3px
        // selection stripe plus the message's 12px padding.
        expect(lefts, [15.0, 15.0]);
      },
    );
  }

  for (final displayStyle in ['bubble', 'column']) {
    testWidgets(
      'group avatar stays pinned while the group scrolls ($displayStyle)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(420, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        SharedPreferences.setMockInitialValues({
          kAppMessageDisplayStyle: displayStyle,
        });
        final preferences = await SharedPreferences.getInstance();

        final base = DateTime.utc(2026, 1, 1, 12);
        // Newest first. Three senders, tall groups: the middle group is taller
        // than the viewport so it spans it once scrolled up.
        final messages = <LocalChatMessage>[];
        for (var i = 0; i < 14; i++) {
          messages.add(
            _message('b$i', 'bob', base.subtract(Duration(minutes: i * 2))),
          );
        }
        for (var i = 0; i < 6; i++) {
          messages.add(
            _message('a$i', 'alice', base.subtract(Duration(minutes: 40 + i))),
          );
        }
        for (var i = 0; i < 20; i++) {
          messages.add(
            _message(
              'c$i',
              'carol',
              base.subtract(Duration(minutes: 80 + i * 2)),
            ),
          );
        }

        await tester.runAsync(() async {
          await tester.pumpWidget(
            EasyLocalization(
              supportedLocales: const [Locale('en', 'US')],
              path: 'assets/i18n',
              saveLocale: false,
              child: Builder(
                builder: (context) => MaterialApp(
                  locale: const Locale('en', 'US'),
                  supportedLocales: const [Locale('en', 'US')],
                  localizationsDelegates: context.localizationDelegates,
                  home: ProviderScope(
                    retry: (_, _) => null,
                    overrides: [
                      databaseProvider.overrideWithValue(database),
                      sharedPreferencesProvider.overrideWithValue(preferences),
                      tokenProvider.overrideWithValue(null),
                      apiClientProvider.overrideWithValue(
                        Dio()..httpClientAdapter = _EmptyResponseAdapter(),
                      ),
                      websocketProvider.overrideWithValue(ws),
                      messagesProvider(
                        'room-1',
                      ).overrideWith(() => _FakeMessagesNotifier()),
                      chatRoomProvider(
                        'room-1',
                      ).overrideWith(() => _FakeRoomNotifier()),
                      chatRoomIdentityProvider(
                        'room-1',
                      ).overrideWith(() => _FakeIdentityNotifier()),
                    ],
                    child: Scaffold(
                      body: RoomMessageList(
                        roomId: 'room-1',
                        messages: messages,
                        roomAsync: const AsyncValue.data(null),
                        chatIdentity: const AsyncValue.data(null),
                        onJump: (_) {},
                        onLoadMessageGap: (_) async {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await Future<void>.delayed(const Duration(milliseconds: 200));
        });
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        final listTop = tester.getTopLeft(find.byType(RoomMessageList)).dy;
        // The group's newest message names its sticky avatar and its container.
        const groupSuffixes = ['b0', 'a0', 'c0'];

        void expectPinnedGroupsAreExact() {
          for (final suffix in groupSuffixes) {
            final groupFinder = find.byKey(ValueKey('sticky-group-$suffix'));
            if (groupFinder.evaluate().isEmpty) continue;

            final group = tester.getRect(groupFinder);
            final avatar = tester.getRect(
              find.descendant(
                of: groupFinder,
                matching: find.byType(ProfilePictureWidget),
              ),
            );
            final stickyTop = listTop + 12;
            final lowestTop = (group.bottom - avatar.height).clamp(
              group.top,
              double.infinity,
            );

            if (group.top <= stickyTop - 20 && lowestTop >= stickyTop + 20) {
              // Crossing the top edge: the avatar is pinned, and pinned to the
              // viewport margin rather than to its own row.
              expect(
                avatar.top,
                closeTo(stickyTop, 0.01),
                reason:
                    'group $suffix spans the viewport top, so its avatar must '
                    'sit 12px below it (group ${group.top}, avatar '
                    '${avatar.top})',
              );
            } else if (group.bottom < stickyTop) {
              // Owner scrolled out: the avatar rides its bottom edge.
              expect(
                avatar.bottom,
                closeTo(group.bottom, 0.01),
                reason:
                    'group $suffix left the viewport, so its avatar must '
                    'ride its bottom edge',
              );
            } else {
              // Below the margin: the avatar rests on its own row.
              expect(
                avatar.top,
                closeTo(group.top + (avatar.top - group.top), 0.01),
              );
              expect(avatar.top, greaterThanOrEqualTo(stickyTop - 0.01));
            }
          }
        }

        expectPinnedGroupsAreExact();
        for (var step = 0; step < 8; step++) {
          await tester.drag(find.byType(SuperListView), const Offset(0, 120));
          await tester.pumpAndSettle();
          expectPinnedGroupsAreExact();
        }
      },
    );
  }
}

