import 'package:flutter_test/flutter_test.dart';
import 'package:gap/gap.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:island/shared/widgets/pill_surface.dart';
import 'package:material_ui/material_ui.dart';

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

/// Pumps [controls] into a pill bar the way a root tab does.
Future<void> _pumpBar(WidgetTester tester, Widget controls) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(400, 860);
  final inset = const FakeViewPadding(top: _kStatusTop, bottom: 34);
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

/// A title in the brand slot, the shape every root tab's bar uses.
Widget _titleRow({int actions = 0}) => Row(
  children: [
    const IconButton(icon: Icon(Icons.menu), onPressed: null),
    const Gap(SolSpace.sm),
    Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text('realms', style: const TextStyle(fontSize: 16)),
      ),
    ),
    for (var i = 0; i < actions; i++)
      IconButton(icon: const Icon(Icons.add), onPressed: null),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The capsule sizes itself to its child, so a child that fills the height it
  // is offered (any `Expanded`, `Align` or `Center` in the title slot) used to
  // stretch the glass to whatever the slot happened to allow. The page below it
  // reserves `kPillAppBarHeight`, so the extra glass hung over the content and
  // the bar's own `preferredSize` lied about its height.
  testWidgets('the capsule stays a fixed height', (tester) async {
    await _pumpBar(tester, _titleRow());

    final capsule = _capsule(tester);
    // Pinned to the capsule constant, not sized to its child — the header is
    // taller than a bare control row so it reads as a relaxed pill.
    expect(capsule.height, kPillBarContentHeight);
    // Centered in the band the bar reserves: status inset + 12px margin above,
    // and the band's remaining space below.
    expect(capsule.top, _kStatusTop + kPillSideGutter);
  });

  testWidgets('the bar box matches the band it reserves', (tester) async {
    await _pumpBar(tester, _titleRow(actions: 2));

    // Content pages clear the pill using `preferredSize`; if the rendered box
    // were taller, the glass would cover the first row of content.
    final bar = find.byType(PillAppBar);
    expect(
      tester.getSize(bar).height,
      tester.widget<PillAppBar>(bar).preferredSize.height,
    );
    expect(tester.getSize(bar).height, _kStatusTop + kPillAppBarHeight);
  });

  testWidgets('the height holds for every bar shape', (tester) async {
    // A compact trigger instead of a title, as on explore and the chat list.
    await _pumpBar(
      tester,
      Row(
        children: [
          const IconButton(icon: Icon(Icons.menu), onPressed: null),
          const Gap(SolSpace.sm),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () {},
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SolSpace.sm,
                    vertical: SolSpace.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [Icon(Icons.home, size: 20), Text('All')],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    expect(_capsule(tester).height, kPillBarContentHeight);

    // A bare title with no `Align`, the shortest thing a bar can hold.
    await _pumpBar(
      tester,
      Row(
        children: [
          const IconButton(icon: Icon(Icons.menu), onPressed: null),
          const Gap(SolSpace.sm),
          const Expanded(child: Text('wallet')),
        ],
      ),
    );
    expect(_capsule(tester).height, kPillBarContentHeight);
  });
}
