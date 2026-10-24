import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/shared/widgets/glass_effects.dart';
import 'package:island/shared/widgets/pill_surface.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

Widget _harness({required bool glass}) => GlassEffects(
  enabled: glass,
  child: MaterialApp(
    home: Scaffold(
      body: Center(
        child: PillSurface(
          t: 1,
          margin: EdgeInsets.zero,
          radius: const BorderRadius.all(Radius.circular(999)),
          contentPadding: const EdgeInsets.all(8),
          child: const SizedBox(width: 200, height: 40),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('glass on draws the liquid material', (tester) async {
    await tester.pumpWidget(_harness(glass: true));
    await tester.pumpAndSettle();

    expect(find.byType(LiquidGlassLayer), findsOneWidget);
  });

  testWidgets('glass off swaps in a solid fill with no layer', (tester) async {
    await tester.pumpWidget(_harness(glass: false));
    await tester.pumpAndSettle();

    expect(find.byType(LiquidGlassLayer), findsNothing);

    // The capsule still occupies the same box, now painted from the theme.
    final decoration =
        tester
                .widgetList<DecoratedBox>(
                  find.descendant(
                    of: find.byType(PillSurface),
                    matching: find.byType(DecoratedBox),
                  ),
                )
                .first
                .decoration
            as BoxDecoration;
    expect(
      decoration.borderRadius,
      const BorderRadius.all(Radius.circular(999)),
    );
    expect(decoration.border, isNotNull);
    expect(decoration.color, isNotNull);
    expect(decoration.color!.a, greaterThan(0));
  });

  testWidgets('a fading pill still paints nothing at t = 0', (tester) async {
    await tester.pumpWidget(
      GlassEffects(
        enabled: true,
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: PillSurface(
                t: 0,
                margin: EdgeInsets.zero,
                radius: const BorderRadius.all(Radius.circular(999)),
                contentPadding: const EdgeInsets.all(8),
                child: const SizedBox(width: 200, height: 40),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LiquidGlassLayer), findsNothing);
  });
}
