import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/pinned_messages_bar.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/data/database.dart';
import 'package:island/data/message.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  SnChatMessagePin pin(String messageId) => SnChatMessagePin(
    id: 'pin-$messageId',
    messageId: messageId,
    chatRoomId: 'room-1',
    pinnedByMemberId: 'member-1',
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  LocalChatMessage message(String id) => LocalChatMessage(
    id: id,
    roomId: 'room-1',
    senderId: 'account-1',
    sender: null,
    data: const {},
    createdAt: DateTime.utc(2026),
    clientMessageId: null,
    status: MessageStatus.sent,
    content: 'Pinned body $id',
    type: 'text',
    meta: const {},
    membersMentioned: const [],
    attachments: const [],
    reactions: const [],
  );

  testWidgets('pinned messages render as an inset floating card', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);
    final prefs = await SharedPreferences.getInstance();

    var collapsed = false;
    var toggles = 0;

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
                overrides: [
                  sharedPreferencesProvider.overrideWithValue(prefs),
                  databaseProvider.overrideWithValue(AppDatabase.web()),
                ],
                child: Scaffold(
                  body: StatefulBuilder(
                    builder: (context, setState) => Column(
                      children: [
                        PinnedMessagesBar(
                          pins: [pin('m1'), pin('m2')],
                          isCollapsed: collapsed,
                          onToggleCollapse: () {
                            setState(() {
                              collapsed = !collapsed;
                              toggles++;
                            });
                          },
                          onTapPin: (_) {},
                          onViewAll: () {},
                          fetchMessageById: (id) async =>
                              Future.value(message(id)),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.byType(ExploreCard), findsOneWidget);

    // The card is a floating surface: 12px in from both screen edges.
    final card = find.byType(ExploreCard);
    expect(tester.getTopLeft(card).dx, 12);
    expect(400 - tester.getTopRight(card).dx, 12);
    expect(tester.getTopLeft(card).dy, 12);

    expect(find.text('2 pinned messages'), findsOneWidget);
    expect(find.text('Pinned body m1'), findsOneWidget);

    // Collapsing keeps the card, drops the preview rows.
    await tester.tap(find.text('2 pinned messages'));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(toggles, 1);
    expect(find.byType(ExploreCard), findsOneWidget);
    expect(find.text('Pinned body m1'), findsNothing);
    expect(find.text('2 pinned messages'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    while (tester.takeException() != null) {}
  });
}
