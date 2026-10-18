import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/websocket.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _FakeWebSocketService extends SolarWebSocketService {
  _FakeWebSocketService() : super(uri: () => Uri(), token: () async => null);

  final _status = StreamController<WebSocketState>.broadcast();

  @override
  Stream<WebSocketState> get statusStream => _status.stream;

  void emit(WebSocketState state) => _status.add(state);

  @override
  void close() {}
}

class _SignedInUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async {
    final now = DateTime.utc(2026);
    return SnAccount(
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
  }
}

void main() {
  late _FakeWebSocketService service;

  Future<void> pump(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);
    service = _FakeWebSocketService();
    addTearDown(service.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          websocketProvider.overrideWithValue(service),
          userInfoProvider.overrideWith(_SignedInUserInfo.new),
        ],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(padding: EdgeInsets.only(top: 24)),
            child: Stack(children: [WebSocketIndicator()]),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Rect pillRect(WidgetTester tester) =>
      tester.getRect(find.byType(GestureDetector));

  testWidgets('a live connection keeps the pill hidden off the top edge', (
    tester,
  ) async {
    await pump(tester);
    service.emit(const WebSocketState.connected());
    await tester.pumpAndSettle();

    expect(pillRect(tester).bottom, lessThan(0));
  });

  testWidgets('disconnecting slides the pill down from beyond the top edge', (
    tester,
  ) async {
    await pump(tester);
    service.emit(const WebSocketState.connected());
    await tester.pumpAndSettle();
    expect(pillRect(tester).bottom, lessThan(0));

    service.emit(const WebSocketState.serverDown());
    await tester.pumpAndSettle();

    final shown = pillRect(tester);
    expect(shown.top, greaterThan(0));
    expect(shown.bottom, lessThan(800));

    // Pill shape: fully rounded ends.
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.borderRadius, BorderRadius.circular(999));
  });

  testWidgets('hiding again slides the pill back out through the top', (
    tester,
  ) async {
    await pump(tester);
    service.emit(const WebSocketState.serverDown());
    await tester.pumpAndSettle();
    final shownTop = pillRect(tester).top;
    expect(shownTop, greaterThan(0));

    service.emit(const WebSocketState.connected());
    // One frame to deliver the stream event and rebuild, one to start the
    // implicit slide.
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    // Mid-flight: already moving upward through the top edge.
    expect(pillRect(tester).top, lessThan(shownTop));

    await tester.pumpAndSettle();
    expect(pillRect(tester).bottom, lessThan(0));
  });
}
