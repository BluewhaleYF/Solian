import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

double _radius(ShapeBorder? shape) => (shape! as RoundedRectangleBorder)
    .borderRadius
    .resolve(TextDirection.ltr)
    .topLeft
    .x;

Future<ThemeData> _readTheme() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWith((ref) => prefs)],
  );
  final theme = createAppTheme(
    Brightness.light,
    container.read(appSettingsProvider),
  );
  container.dispose();
  return theme;
}

void main() {
  test('menu themes carry the global radius', () async {
    final theme = await _readTheme();
    expect(_radius(theme.popupMenuTheme.shape), kMenuBorderRadius);
    expect(
      _radius(theme.menuTheme.style?.shape?.resolve(const {})),
      kMenuBorderRadius,
    );
  });

  testWidgets('PopupMenuButton uses the global radius', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: await _readTheme(),
        home: Scaffold(
          body: PopupMenuButton<String>(
            child: const Text('anchor'),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'a', child: Text('entry')),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('anchor'));
    await tester.pumpAndSettle();
    expect(find.text('entry'), findsOneWidget);
    final panel = tester
        .widgetList<Material>(find.byType(Material))
        .singleWhere((m) => m.type == MaterialType.card && m.shape != null);
    expect(_radius(panel.shape), kMenuBorderRadius);
  });

  testWidgets('MenuAnchor uses the global radius', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: await _readTheme(),
        home: Scaffold(
          body: MenuAnchor(
            menuChildren: [
              MenuItemButton(
                onPressed: () {},
                child: const Text('entry'),
              ),
            ],
            builder: (context, controller, _) => TextButton(
              onPressed: controller.open,
              child: const Text('anchor'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('anchor'));
    await tester.pumpAndSettle();
    expect(find.text('entry'), findsOneWidget);
    final panels = tester
        .widgetList<Material>(
          find.ancestor(of: find.text('entry'), matching: find.byType(Material)),
        )
        .where((m) => m.shape is RoundedRectangleBorder && _radius(m.shape) > 0);
    expect(_radius(panels.single.shape), kMenuBorderRadius);
  });
}
