import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/chat/widgets/room_selection_mode.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The selection strip carries a count and two labelled actions. Long labels
/// and narrow phones must not push the actions off the edge or overflow the
/// row; the actions stay inside the screen and keep a hit target.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpBar(WidgetTester tester, {required double width}) async {
    await tester.binding.setSurfaceSize(Size(width, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

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
              home: Scaffold(
                body: Column(
                  children: [
                    const Spacer(),
                    RoomSelectionMode(
                      visible: true,
                      selectedCount: 12,
                      onClose: () {},
                      onRedirect: () {},
                      onRedirectToCurrentChat: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.pumpAndSettle();
  }

  for (final width in [320.0, 420.0]) {
    testWidgets('actions stay on screen at ${width.toInt()}px', (tester) async {
      await pumpBar(tester, width: width);

      expect(tester.takeException(), isNull);

      final bar = tester.getRect(find.byType(RoomSelectionMode));
      expect(bar.right, lessThanOrEqualTo(width + 0.01));

      for (final icon in [Symbols.send, Symbols.move_to_inbox]) {
        final action = tester.getRect(find.byIcon(icon));
        expect(
          action.right,
          lessThanOrEqualTo(width + 0.01),
          reason: 'the ${icon.codePoint} action must stay inside the screen',
        );
        expect(action.left, greaterThanOrEqualTo(bar.left - 0.01));
      }
    });
  }
}
