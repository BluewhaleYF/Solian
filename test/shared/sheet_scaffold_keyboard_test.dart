import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gap/gap.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// iPhone-class viewport used by the two sheets below.
const double _screenWidth = 390;
const double _screenHeight = 844;
const double _keyboardHeight = 336;
const double _dpr = 3;

/// Stands in for the device-authorization code sheet: a title, a hint, a
/// focused text field and an action pinned to the bottom.
Widget _codeSheet() {
  return SheetScaffold(
    titleText: 'Enter code',
    heightFactor: 0.55,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Type the eight character code shown on the other device.'),
          const Gap(20),
          const TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'XXXX-XXXX'),
          ),
          const Spacer(),
          FilledButton(onPressed: () {}, child: const Text('Check')),
        ],
      ),
    ),
  );
}

Widget _app() {
  return EasyLocalization(
    supportedLocales: const [Locale('en', 'US')],
    path: 'assets/i18n',
    saveLocale: false,
    child: Builder(
      builder: (context) => MaterialApp(
        locale: const Locale('en', 'US'),
        supportedLocales: const [Locale('en', 'US')],
        localizationsDelegates: [
          ...context.localizationDelegates,
          ...GlobalMaterialLocalizations.delegates,
        ],
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  useRootNavigator: true,
                  builder: (context) => _codeSheet(),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Drives the `MediaQuery` view metrics directly: `setSurfaceSize` does not
/// refresh `MediaQuery`, which would leave the sheet with stale dimensions.
void _useViewport(WidgetTester tester, {required double keyboardHeight}) {
  tester.view.devicePixelRatio = _dpr;
  tester.view.physicalSize = const Size(
    _screenWidth * _dpr,
    _screenHeight * _dpr,
  );
  tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight * _dpr);
  addTearDown(tester.view.reset);
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(ProviderScope(child: _app()));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.text('open'));
  // No pumpAndSettle: the sheet animates and the focused field blinks forever.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('sheet keeps its form above the software keyboard', (
    tester,
  ) async {
    _useViewport(tester, keyboardHeight: _keyboardHeight);
    await _openSheet(tester);

    final keyboardTop = _screenHeight - _keyboardHeight;
    final fieldRect = tester.getRect(find.byType(TextField));
    final buttonRect = tester.getRect(find.byType(FilledButton));

    // The regression: the sheet used to subtract the keyboard inset from its
    // own height, squeezing the form into a sliver that overflowed and left
    // both the field and the action behind the keyboard.
    expect(tester.takeException(), isNull);
    expect(fieldRect.bottom, lessThanOrEqualTo(keyboardTop));
    expect(buttonRect.bottom, lessThanOrEqualTo(keyboardTop));
  });

  testWidgets('sheet keeps its height factor when no keyboard is shown', (
    tester,
  ) async {
    _useViewport(tester, keyboardHeight: 0);
    await _openSheet(tester);

    expect(tester.takeException(), isNull);
    expect(
      tester.getRect(find.byType(SheetScaffold)).height,
      moreOrLessEquals(_screenHeight * 0.55, epsilon: 1),
    );
  });
}
