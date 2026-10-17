import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/pods/chat_subscribe.dart';
import 'package:island/chat/pods/chat_summary.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/websocket.dart';
import 'package:island/notifications/notification.dart';
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

/// Answers the unread REST calls with zero without touching the network.
class _UnreadAdapter implements HttpClientAdapter {
  _UnreadAdapter(this.body);

  final String body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions _,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async => ResponseBody.fromString(
    body,
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
    },
  );
}

class _SignedOutUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

Map<String, dynamic> _newMessageFrame(String id, String roomId) {
  final now = DateTime.utc(2026);
  final member = SnChatMember(
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    id: 'member-$roomId',
    chatRoomId: roomId,
    chatRoom: null,
    accountId: 'account-1',
    account: SnAccount(
      id: 'account-1',
      name: 'other',
      nick: 'Other',
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
  return {
    'type': 'messages.new',
    'data': SnChatMessage(
      createdAt: now,
      updatedAt: now,
      id: id,
      content: 'hello',
      senderId: member.id,
      sender: member,
      chatRoomId: roomId,
    ).toJson(),
    '_ack_id': 'ack-$id',
  };
}

Map<String, dynamic> _notificationFrame(String id) {
  final now = DateTime.utc(2026);
  return {
    'type': 'notifications.new',
    'data': SnNotification(
      id: id,
      appId: 'app-1',
      topic: 'posts.reply',
      title: 'Reply',
      subtitle: '',
      body: 'hi',
      createdAt: now,
      viewedAt: null,
      accountId: 'account-1',
    ).toJson(),
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChatUnreadCountNotifier re-delivery', () {
    late ProviderContainer container;
    late _FakeWebSocketService ws;
    late ProviderSubscription<AsyncValue<int>> subscription;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      ws = _FakeWebSocketService();
      container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenProvider.overrideWithValue(null),
          websocketProvider.overrideWithValue(ws),
          userInfoProvider.overrideWith(_SignedOutUserInfo.new),
          currentSubscribedChatIdProvider.overrideWith(
            _NoSubscribedRoomNotifier.new,
          ),
          apiClientProvider.overrideWithValue(
            Dio()..httpClientAdapter = _UnreadAdapter('0'),
          ),
        ],
      );
      // Keep the auto-disposed notifier alive for the pushed frames.
      subscription = container.listen(
        chatUnreadCountProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(() {
        subscription.close();
        container.dispose();
      });
      await container.read(chatUnreadCountProvider.future);
    });

    test('a repeated frame does not count twice', () async {
      ws.push(_newMessageFrame('m1', 'room-1'));
      await _settle(
        () => _unread(container.read(chatUnreadCountProvider)) == 1,
      );

      // The gateway re-sends until acked, so the same message arrives again.
      ws.push(_newMessageFrame('m1', 'room-1'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(_unread(container.read(chatUnreadCountProvider)), 1);

      // A genuinely new message still counts.
      ws.push(_newMessageFrame('m2', 'room-1'));
      await _settle(
        () => _unread(container.read(chatUnreadCountProvider)) == 2,
      );
    });
  });

  group('NotificationUnreadCountNotifier re-delivery', () {
    late ProviderContainer container;
    late _FakeWebSocketService ws;
    late ProviderSubscription<AsyncValue<int>> subscription;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      ws = _FakeWebSocketService();
      container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          tokenProvider.overrideWithValue(null),
          websocketProvider.overrideWithValue(ws),
          userInfoProvider.overrideWith(_SignedOutUserInfo.new),
          apiClientProvider.overrideWithValue(
            Dio()..httpClientAdapter = _UnreadAdapter('0'),
          ),
        ],
      );
      subscription = container.listen(
        notificationUnreadCountProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(() {
        subscription.close();
        container.dispose();
      });
      await container.read(notificationUnreadCountProvider.future);
    });

    test('a repeated notification does not count twice', () async {
      ws.push(_notificationFrame('n1'));
      await _settle(
        () => _unread(container.read(notificationUnreadCountProvider)) == 1,
      );

      ws.push(_notificationFrame('n1'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(_unread(container.read(notificationUnreadCountProvider)), 1);

      ws.push(_notificationFrame('n2'));
      await _settle(
        () => _unread(container.read(notificationUnreadCountProvider)) == 2,
      );
    });
  });
}

class _NoSubscribedRoomNotifier extends CurrentSubscribedChatIdNotifier {
  @override
  String? build() => null;
}

int _unread(AsyncValue<int> value) =>
    value.maybeWhen(data: (count) => count, orElse: () => -1);

Future<void> _settle(bool Function() until) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (DateTime.now().isBefore(deadline)) {
    if (until()) return;
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  fail('condition not reached');
}
