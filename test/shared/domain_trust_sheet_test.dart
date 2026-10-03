import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/network/domain_trust.dart';
import 'package:island/shared/widgets/content/blocked_image_placeholder.dart';
import 'package:island/shared/widgets/content/domain_trust_sheet.dart';
import 'package:island/shared/widgets/hold_to_confirm_button.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The domain-trust surfaces: the prompt sheet for an untrusted link and the
/// inline card standing in for an untrusted image.
///
/// The sheet renders exactly the height it is handed, so the height it hands
/// itself is the thing most likely to break — silently, by pushing the
/// actions below the fold. That is what the fit assertions here guard.

const _dpr = 3.0;

void _useViewport(WidgetTester tester, {required Size size}) {
  tester.view.devicePixelRatio = _dpr;
  tester.view.physicalSize = size * _dpr;
  addTearDown(tester.view.reset);
}

Widget _host(Widget child) {
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
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
}

final _blocked = const DomainTrustResult(
  isAllowed: false,
  isVerified: false,
  blockReason: 'Phishing domain reported by the community',
);

const _unverified = DomainTrustResult(isAllowed: true, isVerified: false);

void _expectSheetFits(WidgetTester tester) {
  final scrollable = tester.state<ScrollableState>(
    find.descendant(
      of: find.byType(SheetScaffold),
      matching: find.byType(Scrollable),
    ),
  );
  expect(scrollable.position.maxScrollExtent, 0);
  expect(tester.takeException(), isNull);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('blocked link sheet shows where it goes and what it costs', (
    tester,
  ) async {
    _useViewport(tester, size: const Size(390, 844));
    await tester.runAsync(() async {
      await tester.pumpWidget(
        _host(
          DomainTrustSheet(
            uri: Uri.parse('https://evil.example.com/login?next=abc'),
            result: _blocked,
            action: DomainTrustAction.openLink,
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();

    _expectSheetFits(tester);
    expect(find.text('evil.example.com'), findsOneWidget);
    expect(
      find.text('https://evil.example.com/login?next=abc'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Phishing domain reported by the community'),
      findsOneWidget,
    );
    // A blocked domain is only ever reachable by holding the button.
    expect(find.byType(HoldToConfirmButton), findsOneWidget);
  });

  testWidgets('unverified sheet still fits on a small phone', (tester) async {
    _useViewport(tester, size: const Size(320, 568));
    await tester.runAsync(() async {
      await tester.pumpWidget(
        _host(
          DomainTrustSheet(
            uri: Uri.parse('https://unknown.example.org/'),
            result: _unverified,
            action: DomainTrustAction.loadImage,
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();

    _expectSheetFits(tester);
    expect(find.byType(HoldToConfirmButton), findsNothing);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
  });

  testWidgets('proceeding returns the decision to the caller', (tester) async {
    _useViewport(tester, size: const Size(390, 844));
    DomainTrustDecision? decision;
    await tester.runAsync(() async {
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                decision = await showDomainTrustSheet(
                  context,
                  uri: Uri.parse('https://unknown.example.org/'),
                  result: _unverified,
                  action: DomainTrustAction.loadImage,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(decision, DomainTrustDecision.proceed);
  });

  testWidgets('hold-to-confirm fires only after the full hold', (tester) async {
    _useViewport(tester, size: const Size(390, 844));
    var confirmed = 0;
    await tester.runAsync(() async {
      await tester.pumpWidget(
        _host(
          Center(
            child: HoldToConfirmButton(
              label: 'Long Press to Load',
              onConfirmed: () => confirmed++,
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();

    final center = tester.getCenter(find.byType(HoldToConfirmButton));

    // A tap, and a hold released early, must both be no-ops: the whole point
    // of the gesture is that it cannot be completed by accident.
    await tester.tap(find.byType(HoldToConfirmButton));
    await tester.pump(const Duration(milliseconds: 900));
    expect(confirmed, 0);

    final early = await tester.startGesture(center);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await early.up();
    await tester.pump(const Duration(milliseconds: 900));
    expect(confirmed, 0);

    final full = await tester.startGesture(center);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 950));
    await full.up();
    await tester.pump();
    expect(confirmed, 1);
  });

  testWidgets('a blocked image is not loaded by a stray tap', (tester) async {
    _useViewport(tester, size: const Size(390, 844));
    var proceeded = false;
    await tester.runAsync(() async {
      await tester.pumpWidget(
        _host(
          Padding(
            padding: const EdgeInsets.all(16),
            child: BlockedImagePlaceholder(
              uri: Uri.parse('https://images.example.net/a.png'),
              result: _blocked,
              onProceed: () => proceeded = true,
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('images.example.net'), findsOneWidget);

    await tester.tap(find.byType(BlockedImagePlaceholder));
    await tester.pump(const Duration(milliseconds: 900));
    expect(proceeded, isFalse);

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(HoldToConfirmButton)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 950));
    await gesture.up();
    await tester.pump();
    expect(proceeded, isTrue);
  });
}
