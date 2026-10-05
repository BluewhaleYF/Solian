import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ThemeData> _readTheme({double cardTransparency = 1}) async {
  SharedPreferences.setMockInitialValues({
    kAppCardTransparent: cardTransparency,
  });
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

Material _cardSurface(WidgetTester tester) => tester
    .widgetList<Material>(find.byType(Material))
    .singleWhere((m) => m.type == MaterialType.card);

void main() {
  test('card theme defaults to flat elevation regardless of transparency', () async {
    expect((await _readTheme()).cardTheme.elevation, 0);
    expect((await _readTheme(cardTransparency: 0.6)).cardTheme.elevation, 0);
  });

  testWidgets('a bare Card renders with zero elevation', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: await _readTheme(cardTransparency: 0.6),
        home: const Scaffold(body: Card(child: Text('content'))),
      ),
    );
    expect(_cardSurface(tester).elevation, 0);
  });
}
