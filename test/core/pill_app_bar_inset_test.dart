import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:island/shared/widgets/pill_surface.dart';

const double _kStatusTop = 44;

/// The painted capsule of a pill, excluding its margin.
Rect _capsule(WidgetTester tester) => tester.getRect(
  find
      .descendant(
        of: find.byType(PillBarSurface),
        matching: find.byType(DecoratedBox),
      )
      .first,
);

Future<void> _pumpBar(WidgetTester tester, Widget controls) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(400, 860);
  final inset = const FakeViewPadding(top: _kStatusTop);
  tester.view.padding = inset;
  tester.view.viewPadding = inset;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PillAppBar(
          fade: ValueNotifier<double>(0.0),
          statusTop: _kStatusTop,
          child: controls,
        ),
        body: const SizedBox.expand(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// A leading icon button, the first thing every pill bar puts in the capsule.
Widget _leadingRow() => Row(
  children: [
    IconButton(
      icon: const Icon(Icons.menu),
      onPressed: null,
      style: const ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
    const Spacer(),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The capsule's end caps curve inwards, so a control pinned to a bare
  // `SolSpace.md` inset sat partly under the curve and read as crowding the
  // edge. The header now insets one step wider than its own side gutter.
  testWidgets('the controls clear the end caps by more than the side gutter', (
    tester,
  ) async {
    await _pumpBar(tester, _leadingRow());

    final capsule = _capsule(tester);
    final leading = tester.getRect(find.byType(IconButton));

    expect(capsule.left, kPillSideGutter);
    expect(
      leading.left - capsule.left,
      greaterThan(kPillSideGutter),
      reason: 'the first control must clear the end cap, not sit on it',
    );
  });

  testWidgets('the wider inset does not change the bar height', (
    tester,
  ) async {
    await _pumpBar(tester, _leadingRow());

    // Height is a separate contract: pages reserve `kPillAppBarHeight` and a
    // horizontal inset must not leak into it.
    expect(_capsule(tester).height, kPillBarContentHeight);
    expect(
      tester.getSize(find.byType(PillAppBar)).height,
      _kStatusTop + kPillAppBarHeight,
    );
  });

  testWidgets('the inset scales with the app spacing scale', (tester) async {
    await _pumpBar(tester, _leadingRow());

    final capsule = _capsule(tester);
    final leading = tester.getRect(find.byType(IconButton));

    expect(leading.left - capsule.left, SolSpace.lg);
  });
}
