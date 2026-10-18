import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

Widget _tiles() => Scaffold(
  body: Column(
    children: [
      ListTile(
        key: const Key('dense-one-line'),
        dense: true,
        leading: const Icon(Icons.abc),
        title: const Text('dense one line'),
      ),
      ListTile(
        key: const Key('one-line'),
        leading: const Icon(Icons.abc),
        title: const Text('one line'),
      ),
      ListTile(
        key: const Key('two-line'),
        leading: const Icon(Icons.abc),
        title: const Text('two line'),
        subtitle: const Text('subtitle'),
      ),
      ListTile(
        key: const Key('dense-two-line'),
        dense: true,
        leading: const Icon(Icons.abc),
        title: const Text('dense two line'),
        subtitle: const Text('subtitle'),
      ),
    ],
  ),
);

void main() {
  // Regression: a global `ListTileThemeData.minTileHeight` floor overrides
  // material_ui's per-shape defaults instead of just raising the minimum. It
  // pushed dense one-line rows up to the floor and dropped two-line rows into
  // the renderer's "compact" branch, collapsing them to content height.
  testWidgets('the theme keeps the framework tile heights intact', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: await _readTheme(), home: _tiles()),
    );
    await tester.pumpAndSettle();

    double heightOf(String key) =>
        tester.getSize(find.byKey(Key(key))).height;

    expect(heightOf('dense-one-line'), lessThan(heightOf('one-line')));
    expect(heightOf('dense-one-line'), 48);
    expect(heightOf('one-line'), 56);
    expect(heightOf('two-line'), 72);
    expect(heightOf('dense-two-line'), 64);
  });
}