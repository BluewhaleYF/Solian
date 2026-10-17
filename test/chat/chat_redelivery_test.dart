import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/event_bus.dart';
import 'package:island/core/websocket.dart';
import 'package:island/data/database.dart';
import 'package:island/data/message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// A websocket service the test pushes frames into directly.
class _FakeWebSocketService extends SolarWebSocketService {
  _FakeWebSocketService() : super(uri: () => Uri(), token: () async => null);

  final _controller = StreamController<WebSocketPacket>.broadcast();

  @override
  Stream<WebSocketPacket> get dataStream => _controller.stream;

  void push(Map<String, dynamic> json) =>
      _controller.add(WebSocketPacket.fromJson(json));
}

/// Never reaches the network; the codes under test only touch the database.
class _EmptyAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions _,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async => ResponseBody.fromString(
    '[]',
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

/// Signed out: the handlers then skip account-specific gating, which keeps the
/// test focused on re-delivery.
class _SignedOutUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

SnAccount _account(DateTime now) => SnAccount(
  id: 'account-1',
  name: 'test-user',
  nick: 'Test User',
  language: 'en',
  isSuperuser: false,
  automatedId: null,
  profile: SnAccountProfile(
    id: 'profile-1',
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

SnChatMember _member(DateTime now) => SnChatMember(
  createdAt: now,
  updatedAt: now,
  deletedAt: null,
  id: 'member-1',
  chatRoomId: 'room-1',
  chatRoom: null,
  accountId: 'account-1',
  account: _account(now),
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

/// A `messages.new` frame as the gateway pushes it, stamped for ack tracking.
Map<String, dynamic> _newMessageFrame(String id) {
  final now = DateTime.utc(2026);
  final message = SnChatMessage(
    createdAt: now,
    updatedAt: now,
    id: id,
    content: 'hello',
    senderId: 'member-1',
    sender: _member(now),
    chatRoomId: 'room-1',
  );
  return {
    'type': 'messages.new',
    'data': message.toJson(),
    // The gateway stamps this on every at-least-once frame.
    '_ack_id': 'ack-$id',
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatGlobalSyncNotifier re-delivery', () {
    late AppDatabase database;
    late ProviderContainer container;
    late _FakeWebSocketService ws;
    late List<ChatMessageNewEvent> fired;

    setUp(() async {
      database = AppDatabase.web();
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      ws = _FakeWebSocketService();
      fired = [];
      final sub = eventBus.on<ChatMessageNewEvent>().listen(fired.add);

      container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          databaseProvider.overrideWithValue(database),
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenProvider.overrideWithValue(null),
          websocketProvider.overrideWithValue(ws),
          userInfoProvider.overrideWith(_SignedOutUserInfo.new),
          apiClientProvider.overrideWithValue(
            Dio()..httpClientAdapter = _EmptyAdapter(),
          ),
        ],
      );
      addTearDown(() async {
        await sub.cancel();
        container.dispose();
        await database.close();
      });
      // Building the notifier installs its websocket listener.
      await container.read(chatGlobalSyncProvider.future);
    });

    test('stores a repeated frame once and fires one event', () async {
      ws.push(_newMessageFrame('m1'));
      await _settle(() async => (await _row(container, 'm1')) != null);

      // The same frame again: what a retry or a session.resume replay delivers.
      ws.push(_newMessageFrame('m1'));
      await Future<void>.delayed(const Duration(milliseconds: 300));

      expect(fired.map((e) => e.message.id), ['m1']);
      final messages = await _roomMessages(container, 'room-1');
      expect(
        messages.where((m) => m.id == 'm1'),
        hasLength(1),
        reason: 'the row is updated in place, not duplicated',
      );
    });

    test('fires an event for each distinct message', () async {
      ws.push(_newMessageFrame('m1'));
      await _settle(() async => (await _row(container, 'm1')) != null);
      ws.push(_newMessageFrame('m2'));
      await _settle(() async => (await _row(container, 'm2')) != null);

      expect(fired.map((e) => e.message.id), ['m1', 'm2']);
    });
  });
}

Future<void> _settle(Future<bool> Function() until) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    if (await until()) return;
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  fail('condition not reached');
}

Future<LocalChatMessage?> _row(ProviderContainer container, String id) async {
  final row = await container.read(databaseProvider).getMessageById(id);
  return row;
}

Future<List<LocalChatMessage>> _roomMessages(
  ProviderContainer container,
  String roomId,
) async {
  return container.read(databaseProvider).getMessagesForRoom(roomId, limit: 50);
}
