import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _indigoSeed = 0xFF3F51B5;
const _greenSeed = 0xFF2F7A63;

Future<AppSettings> _settings() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWith((ref) => prefs)],
  );
  final settings = container.read(appSettingsProvider);
  container.dispose();
  return settings;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppSettings base;
  setUpAll(() async {
    base = await _settings();
  });

  test('the neutral ground follows the seed, not a fixed palette', () {
    final indigo = createAppTheme(
      Brightness.light,
      base.copyWith(appColorScheme: _indigoSeed),
    ).colorScheme;
    final green = createAppTheme(
      Brightness.light,
      base.copyWith(appColorScheme: _greenSeed),
    ).colorScheme;

    // Before the fix these were hardcoded beige and identical for every seed.
    expect(indigo.surface, isNot(green.surface));
    expect(indigo.surfaceContainer, isNot(green.surfaceContainer));
    expect(indigo.surfaceContainerHigh, isNot(green.surfaceContainerHigh));
    expect(indigo.outlineVariant, isNot(green.outlineVariant));
    expect(indigo.onSurface, isNot(green.onSurface));
    expect(indigo.primary, isNot(green.primary));
  });

  test('dark surfaces follow the seed too', () {
    final indigo = createAppTheme(
      Brightness.dark,
      base.copyWith(appColorScheme: _indigoSeed),
    ).colorScheme;
    final green = createAppTheme(
      Brightness.dark,
      base.copyWith(appColorScheme: _greenSeed),
    ).colorScheme;

    expect(indigo.surface, isNot(green.surface));
    expect(indigo.surfaceContainer, isNot(green.surfaceContainer));
  });

  test('an explicit custom color still wins over the seed', () {
    final theme = createAppTheme(
      Brightness.light,
      base.copyWith(
        appColorScheme: _indigoSeed,
        customColors: ThemeColors(primary: 0xFF9A3412),
      ),
    );
    expect(theme.colorScheme.primary, const Color(0xFF9A3412));
  });

  test('resting inputs and chips are tonal, not outlined', () {
    final theme = createAppTheme(
      Brightness.light,
      base.copyWith(appColorScheme: _indigoSeed),
    );
    expect(theme.inputDecorationTheme.filled, isTrue);
    final restingBorder =
        theme.inputDecorationTheme.enabledBorder! as OutlineInputBorder;
    expect(restingBorder.borderSide, BorderSide.none);
    expect(theme.chipTheme.side, BorderSide.none);
  });
}
