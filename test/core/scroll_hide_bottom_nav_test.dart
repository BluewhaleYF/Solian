import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auto_route/auto_route.dart';
import 'package:island/core/navigation/conditional_bottom_nav.dart';

const double _barHeight = 72.0;
const Key _bodyKey = Key('body');
const Key _barChildKey = Key('bar-child');

/// How far the bar has dissolved out of its slot: 0 is fully visible, 1 is
/// fully gone. The bar fades rather than slides, so this is the inverse of its
/// opacity.
double _barOffset(WidgetTester tester) {
  final fade = tester.widget<FadeTransition>(
    find.descendant(
      of: find.byType(ScrollHideBottomNav),
      matching: find.byType(FadeTransition),
    ),
  );
  return 1 - fade.opacity.value;
}

/// The blur sigma the bar is currently filtered by; 0 when it paints plainly.
double _barBlurSigma(WidgetTester tester) {
  final filtered = find.descendant(
    of: find.byType(ScrollHideBottomNav),
    matching: find.byType(ImageFiltered),
  );
  if (filtered.evaluate().isEmpty) return 0;
  final filter = tester.widget<ImageFiltered>(filtered).imageFilter;
  // `ImageFilter.blur` exposes no getters, so the sigma is recovered from the
  // filter's own description.
  final match = RegExp(r'blur\((\d+(?:\.\d+)?)').firstMatch('$filter');
  return match == null ? 0 : double.parse(match.group(1)!);
}

/// The bottom inset the scaffold hands to its body. Under `extendBody: true`
/// this is the bar's slot height plus the device inset, and it must not move
/// when the bar parks.
double _bodyBottomInset(WidgetTester tester) {
  return MediaQuery.paddingOf(tester.element(find.byKey(_bodyKey))).bottom;
}

Widget _app(
  Widget body, {
  bool enabled = true,
  Object? resetToken,
  bool withBar = true,
  double hideThreshold = kBottomNavHideScrollThreshold,
  Duration hideDuration = kBottomNavHideDuration,
}) {
  return MaterialApp(
    home: Scaffold(
      extendBody: true,
      body: KeyedSubtree(key: _bodyKey, child: body),
      bottomNavigationBar: withBar
          ? ScrollHideBottomNav(
              enabled: enabled,
              resetToken: resetToken,
              hideThreshold: hideThreshold,
              hideDuration: hideDuration,
              child: const SizedBox(
                key: _barChildKey,
                height: _barHeight,
                child: Text('bar'),
              ),
            )
          : null,
    ),
  );
}

Widget _tallList({int items = 60}) {
  return ListView.builder(
    itemCount: items,
    itemBuilder: (context, index) =>
        SizedBox(height: 60, child: Text('row $index')),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(400, 800);
    view.devicePixelRatio = 1.0;
    addTearDown(view.reset);
  });

  testWidgets('the bar leaves on a downward scroll and returns at the top', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_tallList()));
    expect(_barOffset(tester), 0.0);

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(_barOffset(tester), 1.0);

    // Flinging back up to the leading edge restores it even though the drag
    // itself is short.
    await tester.drag(find.byType(ListView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(_barOffset(tester), 0.0);
  });

  testWidgets('the body inset is unchanged while the bar is parked', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_tallList()));
    final before = _bodyBottomInset(tester);

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();

    expect(_barOffset(tester), 1.0);
    expect(_bodyBottomInset(tester), before);
    // Still laid out — the bar is clipped by its slot, not removed from the
    // tree, so the slot height above stays exact.
    expect(tester.getSize(find.byKey(_barChildKey)).height, _barHeight);
  });

  testWidgets('only the outermost vertical viewport drives the bar', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        ListView(
          children: [
            const SizedBox(height: 200, child: _HorizontalStrip()),
            SizedBox(
              height: 200,
              child: ListView(
                key: const Key('inner-list'),
                children: [SizedBox(height: 600, child: Text('inner'))],
              ),
            ),
            SizedBox(height: 1200, child: Text('outer')),
          ],
        ),
      ),
    );

    // A horizontal strip never moves the bar, whatever it does.
    await tester.drag(
      find.byKey(const Key('horizontal-strip')),
      const Offset(-200, 0),
    );
    await tester.pumpAndSettle();
    expect(_barOffset(tester), 0.0);

    // A nested vertical list reports a non-zero notification depth, so the
    // bar stays put; the page itself has not moved.
    await tester.drag(
      find.byKey(const Key('inner-list')),
      const Offset(0, -150),
    );
    await tester.pumpAndSettle();
    expect(_barOffset(tester), 0.0);
  });

  testWidgets('a reversal shorter than the threshold leaves the bar parked', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_tallList()));

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(_barOffset(tester), 1.0);

    // Smaller than the threshold, so the reversal is not yet a deliberate
    // scroll back.
    await tester.drag(find.byType(ListView), const Offset(0, 4));
    await tester.pumpAndSettle();
    expect(_barOffset(tester), 1.0);
  });

  testWidgets('the bar round-trips: back up, then re-hidden going down', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_tallList()));

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, 40));
    await tester.pumpAndSettle();
    expect(_barOffset(tester), 0.0);

    // Hiding is not one-way: a settled bar re-hides on the next deliberate
    // scroll down, so the same gesture that parked it can park it again.
    await tester.drag(find.byType(ListView), const Offset(0, -40));
    await tester.pumpAndSettle();
    expect(_barOffset(tester), 1.0);
  });

  testWidgets(
    'a new reset token returns the bar while the page stays scrolled',
    (tester) async {
      await tester.pumpWidget(_app(_tallList(), resetToken: 'a'));
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(_barOffset(tester), 1.0);

      // Same page, same scroll offset: only the token changed, the way a tab
      // switch changes the route.
      await tester.pumpWidget(_app(_tallList(), resetToken: 'b'));
      await tester.pumpAndSettle();
      expect(_barOffset(tester), 0.0);
    },
  );

  testWidgets('a tab page with its own Scaffold still drives the bar', (
    tester,
  ) async {
    // Mirrors the shell: the bar sits in the shell's slot while the page
    // below owns a nested Scaffold and its own scrollable.
    await tester.pumpWidget(_app(Scaffold(body: _tallList())));

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(_barOffset(tester), 1.0);
  });

  testWidgets('a page too short to scroll keeps its bar', (tester) async {
    // Bouncing with always-scrollable is what a refreshable feed uses, so a
    // drag on content that fits still produces overscroll rather than
    // silence; that motion must not park the bar over nothing.
    await tester.pumpWidget(
      _app(
        ListView.builder(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          itemCount: 2,
          itemBuilder: (context, index) =>
              SizedBox(height: 60, child: Text('row $index')),
        ),
      ),
    );

    // Sampled frame by frame: the failure is a flicker out and back, which the
    // settled state alone would hide. The fling's own rubber band is what
    // pushes past the threshold if the guard is missing.
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    for (var frame = 0; frame < 25; frame++) {
      expect(_barOffset(tester), 0.0, reason: 'frame $frame');
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();
    expect(_barOffset(tester), 0.0);
  });

  testWidgets('a fling off the end of a feed never flickers the bar', (
    tester,
  ) async {
    final list = ListView.builder(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemCount: 30,
      itemBuilder: (context, index) =>
          SizedBox(height: 60, child: Text('row $index')),
    );
    await tester.pumpWidget(_app(list));

    // Park the bar, then run to the trailing edge.
    for (var i = 0; i < 6; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
    }
    expect(_barOffset(tester), 1.0);

    // Overscrolling off the end reveals nothing new, so the bar must hold
    // still through the whole rubber band.
    await tester.fling(find.byType(ListView), const Offset(0, -300), 1200);
    for (var frame = 0; frame < 40; frame++) {
      expect(_barOffset(tester), 1.0, reason: 'frame $frame');
      await tester.pump(const Duration(milliseconds: 16));
    }
  });

  testWidgets('the threshold decides how far a scroll must go', (tester) async {
    // One small flick, well short of the default threshold but past a 2px
    // one: the knob is what moves the bar, not the gesture.
    const flick = Offset(0, -6);

    await tester.pumpWidget(_app(_tallList()));
    await tester.drag(find.byType(ListView), flick);
    await tester.pumpAndSettle();
    expect(_barOffset(tester), 0.0);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_app(_tallList(), hideThreshold: 2));
    await tester.drag(find.byType(ListView), flick);
    await tester.pumpAndSettle();
    expect(_barOffset(tester), 1.0);
  });

  testWidgets('the duration decides how long the bar takes to leave', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_tallList(), hideDuration: const Duration(seconds: 1)),
    );

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    // A quarter of the way through a one-second slide, so still short of
    // parked — with the 200ms default it would already be there.
    final midway = _barOffset(tester);
    expect(midway, greaterThan(0.0));
    expect(midway, lessThan(1.0));

    await tester.pumpAndSettle();
    expect(_barOffset(tester), 1.0);
  });

  testWidgets('the bar dissolves rather than slides out of its slot', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(_tallList(), hideDuration: const Duration(seconds: 1)),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Mid-way the bar is both partly transparent and smeared: the motion is a
    // defocus, and nothing under the slot translates.
    final opacity = 1 - _barOffset(tester);
    expect(opacity, greaterThan(0.0));
    expect(opacity, lessThan(1.0));
    expect(_barBlurSigma(tester), greaterThan(0.0));
    expect(
      find.descendant(
        of: find.byType(ScrollHideBottomNav),
        matching: find.byType(SlideTransition),
      ),
      findsNothing,
    );

    await tester.pumpAndSettle();
    expect(_barOffset(tester), 1.0);
    expect(_barBlurSigma(tester), kBottomNavBlurSigma);
  });

  _shellWiringTests();
}

void _shellWiringTests() {
  // `ConditionalBottomNav` gates on the current tab route, so exercising it
  // needs a real router scope.
  testWidgets('the shell bar hides while a tab page scrolls', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(routerConfig: _ShellRouter().config()),
    );
    await tester.pumpAndSettle();

    double offset() =>
        1 -
        tester
            .widget<FadeTransition>(
              find
                  .descendant(
                    of: find.byType(ScrollHideBottomNav),
                    matching: find.byType(FadeTransition),
                  )
                  .first,
            )
            .opacity
            .value;

    expect(offset(), 0.0);
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(offset(), 1.0);
  });
}

/// Mirrors the tab shell: one routed page whose own `Scaffold` carries the
/// bar, exactly as `TabsScreen` mounts `ConditionalBottomNav`.
class _ShellRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: PageInfo.builder(
        'tab',
        builder: (context, data) => Scaffold(
          extendBody: true,
          body: _tallList(),
          bottomNavigationBar: ConditionalBottomNav(
            routes: const ['/'],
            child: const SizedBox(height: _barHeight, child: Text('bar')),
          ),
        ),
      ),
      path: '/',
      initial: true,
    ),
  ];
}

class _HorizontalStrip extends StatelessWidget {
  const _HorizontalStrip();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      key: const Key('horizontal-strip'),
      scrollDirection: Axis.horizontal,
      itemCount: 40,
      itemBuilder: (context, index) =>
          SizedBox(width: 60, child: Text('$index')),
    );
  }
}
