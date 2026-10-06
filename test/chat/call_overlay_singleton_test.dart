import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/pods/call.dart';
import 'package:island/chat/widgets/call_button.dart';
import 'package:island/chat/widgets/call_overlay.dart';
import 'package:island/main.dart';
import 'package:material_ui/material_ui.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final _account = SnAccount.fromJson({
  'id': 'account-1',
  'name': 'alice',
  'nick': 'Alice',
  'language': 'en-US',
  'is_superuser': false,
  'automated_id': null,
  'profile': {
    'id': 'profile-1',
    'bio': 'hello',
    'experience': 0,
    'level': 0,
    'leveling_progress': 0.0,
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  },
  'perk_subscription': null,
  'activated_at': '2026-01-01T00:00:00Z',
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
  'deleted_at': null,
});

class _SignedInUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => _account;
}

/// Connected session with no participants: the panel stays mounted but renders
/// nothing, which keeps it observable without a LiveKit room.
class _ConnectedCallNotifier extends CallNotifier {
  @override
  CallState build() => const CallState(
    isConnected: true,
    isMicrophoneEnabled: true,
    isCameraEnabled: false,
    isScreenSharing: false,
    isSpeakerphone: true,
    hasJoined: true,
  );
}

SnChatRoom _room(String id) {
  final now = DateTime.utc(2026);
  return SnChatRoom(
    id: id,
    name: 'Test room',
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
  );
}

Finder get _overlayPanels => find.byWidgetPredicate(
  (widget) => widget.runtimeType.toString() == '_CallOverlayPanel',
);

void main() {
  testWidgets('re-entrant showCallOverlay keeps a single panel', (
    tester,
  ) async {
    setCallScreenActive(false);
    final overlayKey = GlobalKey<OverlayState>();
    globalOverlay = overlayKey;
    final room = _room('room-1');

    final container = ProviderContainer(
      overrides: [
        userInfoProvider.overrideWith(_SignedInUserInfo.new),
        callProvider.overrideWith(_ConnectedCallNotifier.new),
        activeCallParticipantCountProvider(room.id).overrideWith((_) => 0),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Overlay(
            key: overlayKey,
            initialEntries: [
              OverlayEntry(builder: (_) => const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
    // The panel requires a resolved account on its first build.
    await container.read(userInfoProvider.future);
    await tester.pump();

    // An entry has been inserted but not yet built in the window below:
    // `OverlayEntry.mounted` is still false there, which is what previously
    // made the second call discard the live entry and insert a second one.
    showCallOverlay(room);
    await tester.pump();
    showCallOverlay(room);
    await tester.pump();
    await tester.pump();

    expect(_overlayPanels, findsOneWidget);

    hideCallOverlay();
    await tester.pump();
    expect(_overlayPanels, findsNothing);
  });
}
