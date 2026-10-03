import 'package:flutter/material.dart' as legacy_material;
import 'package:flutter_localizations/flutter_localizations.dart'
    as flutter_localizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:island/auth/widgets/auth_consent.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pinput/pinput.dart';

/// Pumps the segmented code field at the width it gets inside the sheet
/// (390pt screen minus the sheet's 20pt horizontal padding on both sides).
Future<String Function()> _pumpInput(WidgetTester tester) async {
  var typed = '';
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      localizationsDelegates: [
        // The app hands both material libraries their localizations in
        // lib/main.dart; `Pinput` is built on Flutter's own material.
        ...GlobalMaterialLocalizations.delegates,
        flutter_localizations.GlobalMaterialLocalizations.delegate,
      ],
      home: legacy_material.Material(
        // Same reason: `Pinput` wants Flutter's Material ancestor, which the
        // app provides through `MaterialUiCompatibilityBridge`.
        type: legacy_material.MaterialType.transparency,
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: 350,
              child: AuthUserCodeInput(onChanged: (value) => typed = value),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return () => typed;
}

void main() {
  group('formatAuthUserCode', () {
    test('groups the eight characters behind the separator', () {
      expect(formatAuthUserCode('BCDFGHJK'), 'BCDF-GHJK');
    });

    test('accepts a code that already carries the separator', () {
      expect(formatAuthUserCode('BCDF-GHJK'), 'BCDF-GHJK');
    });

    test('leaves a partial code alone', () {
      expect(formatAuthUserCode('BCDF'), 'BCDF');
      expect(formatAuthUserCode(''), '');
    });
  });

  testWidgets('shows a separator between the two groups', (tester) async {
    await _pumpInput(tester);

    expect(find.byType(Pinput), findsOneWidget);
    expect(find.text('-'), findsOneWidget);
  });

  testWidgets('autofilled and pasted text fills the boxes', (tester) async {
    final typed = await _pumpInput(tester);

    // A code copied from the requesting device carries no separator, and one
    // copied from the web page does; both land on the same eight characters.
    await tester.enterText(find.byType(Pinput), 'bcdfghjk');
    await tester.pump();
    expect(typed(), 'BCDFGHJK');

    await tester.enterText(find.byType(Pinput), 'BCDF-GHJK');
    await tester.pump();
    expect(typed(), 'BCDFGHJK');

    // The separator is chrome: it is rendered, never part of the value.
    expect(find.text('-'), findsOneWidget);
    expect(typed(), isNot(contains('-')));
  });

  testWidgets('drops characters the server cannot have generated', (
    tester,
  ) async {
    final typed = await _pumpInput(tester);

    // The server's alphabet excludes the vowels and the digits.
    await tester.enterText(find.byType(Pinput), 'aeiobcdf-ghjk0123');
    await tester.pump();

    expect(typed(), 'BCDFGHJK');
  });

  testWidgets('the entered characters form the canonical wire code', (
    tester,
  ) async {
    final typed = await _pumpInput(tester);

    await tester.enterText(find.byType(Pinput), 'bcdfghjk');
    await tester.pump();

    expect(formatAuthUserCode(typed()), 'BCDF-GHJK');
  });
}
