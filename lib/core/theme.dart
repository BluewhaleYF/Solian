import 'package:flutter/cupertino.dart';
import 'package:material_ui/material_ui.dart';
import 'package:island/core/config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme.g.dart';

@riverpod
ThemeSet theme(Ref ref) {
  final settings = ref.watch(appSettingsProvider);
  return createAppThemeSet(settings);
}

class ThemeSet {
  ThemeData light;
  ThemeData dark;

  ThemeSet({required this.light, required this.dark});
}

/// Radius of every menu surface: `PopupMenuButton` popups and `MenuAnchor`
/// menus (MD3 "medium" shape token, matching the 12px input/card radius used
/// elsewhere in the app). The framework default is 4px, so this is applied
/// globally here; a caller that needs another radius must override it on the
/// widget itself.
const kMenuBorderRadius = 12.0;

const _menuShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(kMenuBorderRadius)),
);

ThemeSet createAppThemeSet(AppSettings settings) {
  return ThemeSet(
    light: createAppTheme(Brightness.light, settings),
    dark: createAppTheme(Brightness.dark, settings),
  );
}

ThemeData createAppTheme(Brightness brightness, AppSettings settings) {
  final seedColor = settings.appColorScheme != null
      ? Color(settings.appColorScheme!)
      : Colors.indigo;

  var colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
  );

  final customColors = settings.customColors;
  if (customColors != null) {
    colorScheme = colorScheme.copyWith(
      primary: customColors.primary != null
          ? Color(customColors.primary!)
          : null,
      onPrimary: customColors.onPrimary != null
          ? Color(customColors.onPrimary!)
          : null,
      primaryContainer: customColors.primaryContainer != null
          ? Color(customColors.primaryContainer!)
          : null,
      secondary: customColors.secondary != null
          ? Color(customColors.secondary!)
          : null,
      onSecondary: customColors.onSecondary != null
          ? Color(customColors.onSecondary!)
          : null,
      secondaryContainer: customColors.secondaryContainer != null
          ? Color(customColors.secondaryContainer!)
          : null,
      tertiary: customColors.tertiary != null
          ? Color(customColors.tertiary!)
          : null,
      onTertiary: customColors.onTertiary != null
          ? Color(customColors.onTertiary!)
          : null,
      tertiaryContainer: customColors.tertiaryContainer != null
          ? Color(customColors.tertiaryContainer!)
          : null,
      surface: customColors.surface != null
          ? Color(customColors.surface!)
          : null,
      surfaceContainerHighest: customColors.surfaceContainerHighest != null
          ? Color(customColors.surfaceContainerHighest!)
          : null,
      background: customColors.background != null
          ? Color(customColors.background!)
          : null,
      outline: customColors.outline != null
          ? Color(customColors.outline!)
          : null,
      shadow: customColors.shadow != null ? Color(customColors.shadow!) : null,
      error: customColors.error != null ? Color(customColors.error!) : null,
    );
  }

  final hasAppBarTransparent = settings.appBarTransparent;

  final inUseFonts =
      settings.customFonts?.split(',').map((ele) => ele.trim()).toList() ??
      ['Nunito'];

  final theme = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: brightness,
    fontFamily: inUseFonts.firstOrNull,
    fontFamilyFallback: inUseFonts.sublist(1),
    iconTheme: IconThemeData(
      fill: 0,
      weight: 400,
      opticalSize: 20,
      color: colorScheme.onSurface,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: hasAppBarTransparent ? 0 : null,
      backgroundColor: hasAppBarTransparent
          ? Colors.transparent
          : colorScheme.surface,
      foregroundColor: hasAppBarTransparent
          ? colorScheme.onSurface
          : colorScheme.onSurface,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainer.withOpacity(
        settings.cardTransparency,
      ),
      elevation: settings.cardTransparency < 1 ? 0 : null,
    ),
    inputDecorationTheme: InputDecorationThemeData(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(year2023: false),
    sliderTheme: SliderThemeData(year2023: false),
    popupMenuTheme: const PopupMenuThemeData(shape: _menuShape),
    menuTheme: const MenuThemeData(
      style: MenuStyle(
        shape: WidgetStatePropertyAll<OutlinedBorder>(_menuShape),
      ),
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.fuchsia: FadeForwardsPageTransitionsBuilder(),
      },
    ),
  );

  // App bar titles keep the app-wide font (taken from the theme's own text
  // style) while shrinking to 16 and going semibold.
  return theme.copyWith(
    appBarTheme: theme.appBarTheme.copyWith(
      titleTextStyle: theme.textTheme.titleLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    ),
  );
}
