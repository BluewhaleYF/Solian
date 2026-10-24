import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/pill_surface.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  /// A scaffold whose body is one tall scrollable, so the pill's fade has
  /// something to rail against.
  Future<ValueNotifier<double>> pump(
    WidgetTester tester, {
    required bool appBarOverContent,
  }) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    final fade = ValueNotifier<double>(0.0);
    addTearDown(fade.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: AppScaffold(
            // Keeps the page off the app-background provider: this test is
            // about the bar's band, not the wallpaper.
            isNoBackground: true,
            appBarOverContent: appBarOverContent,
            appBar: PillAppBar(
              fade: fade,
              statusTop: 0,
              child: const SizedBox(
                height: SolSpace.control,
                child: Text('Chats'),
              ),
            ),
            body: NotificationListener<ScrollNotification>(
              onNotification: (n) => updatePillFade(n, fade),
              child: ListView(
                children: [
                  for (var i = 0; i < 40; i++)
                    SizedBox(height: 48, child: Text('room $i')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return fade;
  }

  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    while (tester.takeException() != null) {}
  }

  testWidgets('the default scaffold pushes the body below the bar', (
    tester,
  ) async {
    await pump(tester, appBarOverContent: false);

    // The reserved band is the bar's own height, so the first row starts at or
    // below its bottom edge — nothing can slide under it, so a blur-backed bar
    // would have nothing to sample.
    expect(
      tester.getTopLeft(find.text('room 0')).dy,
      greaterThanOrEqualTo(kPillAppBarHeight),
    );

    await disposeTree(tester);
  });

  testWidgets('appBarOverContent lets the body scroll under the bar', (
    tester,
  ) async {
    final fade = await pump(tester, appBarOverContent: true);

    // Both modes start the content below the bar — the scaffold publishes the
    // bar's height as MediaQuery top padding in either case, and the scroll
    // view pads itself with it. The difference is that here the content extends
    // under that band, so scrolling moves it beneath the bar and the pill has
    // something to blur; the reserved mode clips the body at the bar's edge.
    await tester.drag(find.byType(ListView), const Offset(0, -120));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(
      fade.value,
      greaterThan(0),
      reason: 'the body scrolls under the bar instead of being clipped below it',
    );

    await disposeTree(tester);
  });

  testWidgets('scrolling the body drives the pill surface', (tester) async {
    final fade = await pump(tester, appBarOverContent: true);

    BoxDecoration surface() =>
        (tester
                .widgetList<DecoratedBox>(
                  find.descendant(
                    of: find.byType(PillBarSurface),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .first
                .decoration
            as BoxDecoration);

    expect(fade.value, 0, reason: 'a body at its origin leaves the pill flat');
    expect(surface().color!.a, 0);
    expect(
      find.byType(BackdropFilter),
      findsNothing,
      reason: 'nothing has slid under the bar yet, so there is no layer',
    );

    await tester.drag(find.byType(ListView), const Offset(0, -200));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(fade.value, 1.0);
    expect(surface().color!.a, closeTo(kPillGlassTint, 0.01));
    expect(find.byType(BackdropFilter), findsOneWidget);

    await disposeTree(tester);
  });
}