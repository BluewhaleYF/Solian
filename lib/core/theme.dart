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

// ---------------------------------------------------------------------------
// Design tokens
//
// One small scale for the whole app. Values are deliberately coarse: if a
// spacing or radius is not on this list, it is probably a one-off rather than
// a system decision. Keeping the scales small is what makes the UI feel
// coherent as more screens are migrated onto them.
//
// Visual direction: "sun-warmed paper". Neutrals are tinted toward warm
// ochre instead of blue-gray, geometry is generous and rounded, and contrast
// comes from tone and space rather than hard outlines. The user's seed color
// still supplies every accent role, so custom color schemes keep working.
// ---------------------------------------------------------------------------

/// Spacing scale, in logical pixels.
abstract final class SolSpace {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  /// Horizontal gutter for phone layouts.
  static const double page = xl;

  /// Horizontal gutter for tablet / desktop layouts.
  static const double pageWide = xxxl;

  /// Gap between major sections of a page.
  static const double section = xxl;

  /// Inset inside cards and other primary content surfaces.
  static const double card = xl;

  /// Minimum height of a comfortable primary control.
  static const double control = 48;
}

/// Corner-radius scale, in logical pixels.
///
/// Buttons, cards, inputs and menus all share [lg] (20) so the primary
/// interactive language reads as one family. Sheets and dialogs step up to
/// [xxl] (28); chips stay at [sm] (12) so dense filter rows do not turn into
/// a wall of pills.
abstract final class SolRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double pill = 999;

  static const double control = lg;
  static const double card = lg;
  static const double input = lg;
  static const double chip = sm;
  static const double menu = lg;
  static const double sheet = xxl;
  static const double dialog = xxl;

  static const BorderRadius controlRadius = BorderRadius.all(
    Radius.circular(control),
  );
  static const BorderRadius cardRadius = BorderRadius.all(
    Radius.circular(card),
  );
  static const BorderRadius inputRadius = BorderRadius.all(
    Radius.circular(input),
  );
  static const BorderRadius menuRadius = BorderRadius.all(
    Radius.circular(menu),
  );
  static const BorderRadius sheetRadius = BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
  static const BorderRadius dialogRadius = BorderRadius.all(
    Radius.circular(dialog),
  );
}

/// Reusable insets built from [SolSpace].
abstract final class SolInsets {
  static const page = EdgeInsets.symmetric(horizontal: SolSpace.page);
  static const pageVertical = EdgeInsets.symmetric(vertical: SolSpace.page);
  static const card = EdgeInsets.all(SolSpace.card);
  static const control = EdgeInsets.symmetric(
    horizontal: SolSpace.xxl,
    vertical: SolSpace.md,
  );
  static const input = EdgeInsets.symmetric(
    horizontal: SolSpace.lg,
    vertical: SolSpace.lg,
  );
}

/// Page gutter for the current width: 20 on phones, 32 from tablet up.
EdgeInsets solPagePadding(BuildContext context) => EdgeInsets.symmetric(
  horizontal: MediaQuery.sizeOf(context).width >= 600
      ? SolSpace.pageWide
      : SolSpace.page,
);

/// Radius of every menu surface: `PopupMenuButton` popups and `MenuAnchor`
/// menus (the 20px primary-shape token used by buttons, cards and inputs).
/// The framework default is 4px, so this is applied globally here; a caller
/// that needs another radius must override it on the widget itself.
const kMenuBorderRadius = SolRadius.menu;

const _menuShape = RoundedRectangleBorder(borderRadius: SolRadius.menuRadius);

const _cardShape = RoundedRectangleBorder(borderRadius: SolRadius.cardRadius);

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

  // Warm the neutral ground before applying user overrides, so a custom
  // accent still sits on the same warm paper.
  colorScheme = _warmNeutrals(colorScheme, brightness);

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

  final inUseFonts = (settings.customFonts ?? '')
      .split(',')
      .map((font) => font.trim())
      .where((font) => font.isNotEmpty)
      .toList();
  if (inUseFonts.isEmpty) inUseFonts.add('Nunito');

  final baseTheme = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    brightness: brightness,
    fontFamily: inUseFonts.first,
    fontFamilyFallback: inUseFonts.sublist(1),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
    iconTheme: IconThemeData(
      fill: 0,
      weight: 400,
      opticalSize: 20,
      color: colorScheme.onSurface,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colorScheme.primary,
      selectionColor: colorScheme.primary.withValues(alpha: 0.24),
      selectionHandleColor: colorScheme.primary,
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
    progressIndicatorTheme: ProgressIndicatorThemeData(year2023: false),
    sliderTheme: SliderThemeData(year2023: false),
  );

  final textTheme = _buildTextTheme(baseTheme.textTheme);
  final onSurface = colorScheme.onSurface;
  final onSurfaceVariant = colorScheme.onSurfaceVariant;

  final buttonShape = RoundedRectangleBorder(
    borderRadius: SolRadius.controlRadius,
  );

  // Inputs use the stronger outline, not the decorative outlineVariant: a
  // control boundary has to stay legible (3:1) against its own fill.
  final inputBorder = OutlineInputBorder(
    borderRadius: SolRadius.inputRadius,
    borderSide: BorderSide(color: colorScheme.outline),
  );
  final focusedInputBorder = OutlineInputBorder(
    borderRadius: SolRadius.inputRadius,
    borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
  );
  final errorInputBorder = OutlineInputBorder(
    borderRadius: SolRadius.inputRadius,
    borderSide: BorderSide(color: colorScheme.error),
  );

  final appBarForeground = colorScheme.onSurface;

  return baseTheme.copyWith(
    textTheme: textTheme,
    appBarTheme: AppBarThemeData(
      centerTitle: true,
      elevation: hasAppBarTransparent ? 0 : null,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: hasAppBarTransparent
          ? Colors.transparent
          : colorScheme.surface,
      foregroundColor: appBarForeground,
      iconTheme: IconThemeData(color: appBarForeground),
      actionsIconTheme: IconThemeData(color: appBarForeground),
      toolbarHeight: 60,
      titleSpacing: SolSpace.xl,
      actionsPadding: const EdgeInsets.only(right: SolSpace.sm),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: appBarForeground,
      ),
    ),
    cardTheme: CardThemeData(
      // A card is a slightly deeper sheet of the same warm paper. Separation
      // comes from tone, not from a shadow.
      color: colorScheme.surfaceContainer.withValues(
        alpha: settings.cardTransparency,
      ),
      surfaceTintColor: Colors.transparent,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.12),
      elevation: 0,
      margin: const EdgeInsets.all(SolSpace.xs),
      shape: _cardShape,
      clipBehavior: Clip.antiAlias,
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: SolSpace.xl),
      minVerticalPadding: SolSpace.sm,
      minTileHeight: 56,
      horizontalTitleGap: 14,
      minLeadingWidth: 40,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SolRadius.sm),
      ),
      selectedTileColor: colorScheme.secondaryContainer.withValues(alpha: 0.55),
      iconColor: onSurfaceVariant,
      textColor: onSurface,
      titleTextStyle: textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: onSurface,
      ),
      subtitleTextStyle: textTheme.bodySmall?.copyWith(
        color: onSurfaceVariant,
        height: 1.4,
      ),
      leadingAndTrailingTextStyle: textTheme.labelMedium?.copyWith(
        color: onSurfaceVariant,
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: colorScheme.surfaceContainerHigh.withValues(alpha: 0.55),
      contentPadding: SolInsets.input,
      border: inputBorder,
      enabledBorder: inputBorder,
      focusedBorder: focusedInputBorder,
      errorBorder: errorInputBorder,
      focusedErrorBorder: focusedInputBorder.copyWith(
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: SolRadius.inputRadius,
        borderSide: BorderSide(
          color: colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: onSurfaceVariant.withValues(alpha: 0.72),
      ),
      labelStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
      floatingLabelStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      helperStyle: textTheme.bodySmall?.copyWith(color: onSurfaceVariant),
      errorStyle: textTheme.bodySmall?.copyWith(color: colorScheme.error),
      iconColor: onSurfaceVariant,
      prefixIconColor: onSurfaceVariant,
      suffixIconColor: onSurfaceVariant,
      prefixStyle: textTheme.bodyMedium?.copyWith(color: onSurface),
      suffixStyle: textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: SolInsets.control,
        minimumSize: const Size(64, SolSpace.control),
        shape: buttonShape,
        animationDuration: const Duration(milliseconds: 180),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: SolInsets.control,
        minimumSize: const Size(64, SolSpace.control),
        shape: buttonShape,
        animationDuration: const Duration(milliseconds: 180),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: SolInsets.control,
        minimumSize: const Size(64, SolSpace.control),
        shape: buttonShape,
        side: BorderSide(color: colorScheme.outline),
        animationDuration: const Duration(milliseconds: 180),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: SolSpace.lg,
          vertical: SolSpace.md,
        ),
        minimumSize: const Size(48, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SolRadius.md),
        ),
        animationDuration: const Duration(milliseconds: 180),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: SolSpace.lg, vertical: SolSpace.md),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(64, 44)),
        textStyle: WidgetStatePropertyAll(
          textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: const ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(SolRadius.md)),
          ),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: buttonShape,
      // Flat like the rest of the surfaces; elevation only appears as a
      // hover/press affordance.
      elevation: 0,
      focusElevation: 1,
      hoverElevation: 2,
      highlightElevation: 1,
      extendedPadding: const EdgeInsets.symmetric(
        horizontal: SolSpace.xxl,
        vertical: SolSpace.lg,
      ),
      extendedIconLabelSpacing: SolSpace.md,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.18),
      elevation: 3,
      shape: const RoundedRectangleBorder(borderRadius: SolRadius.dialogRadius),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: SolSpace.xxl,
        vertical: SolSpace.xxl,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        SolSpace.xl,
        0,
        SolSpace.xl,
        SolSpace.lg,
      ),
      titleTextStyle: textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: onSurface,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: onSurfaceVariant,
        height: 1.5,
      ),
      iconColor: colorScheme.primary,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      modalBackgroundColor: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: SolRadius.sheetRadius),
      dragHandleColor: onSurfaceVariant.withValues(alpha: 0.4),
      clipBehavior: Clip.antiAlias,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onInverseSurface,
      ),
      actionTextColor: colorScheme.inversePrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SolRadius.md),
      ),
      insetPadding: const EdgeInsets.fromLTRB(
        SolSpace.xl,
        0,
        SolSpace.xl,
        SolSpace.lg,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.18),
      elevation: 3,
      shape: _menuShape,
      menuPadding: const EdgeInsets.symmetric(vertical: SolSpace.sm),
      textStyle: textTheme.bodyMedium?.copyWith(color: onSurface),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          colorScheme.surfaceContainerLow,
        ),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(3),
        shape: const WidgetStatePropertyAll<OutlinedBorder>(_menuShape),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: SolSpace.sm),
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      selectedColor: colorScheme.secondaryContainer,
      secondarySelectedColor: colorScheme.secondaryContainer,
      side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.55)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SolRadius.chip),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: SolSpace.sm),
      labelStyle: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
      secondaryLabelStyle: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
        color: colorScheme.onSecondaryContainer,
      ),
      iconTheme: IconThemeData(size: 18, color: onSurfaceVariant),
      checkmarkColor: colorScheme.onSecondaryContainer,
    ),
    expansionTileTheme: ExpansionTileThemeData(
      tilePadding: const EdgeInsets.symmetric(
        horizontal: SolSpace.xl,
        vertical: SolSpace.xs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SolRadius.sm),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SolRadius.sm),
      ),
      iconColor: onSurfaceVariant,
      collapsedIconColor: onSurfaceVariant,
      textColor: onSurface,
      collapsedTextColor: onSurface,
    ),
    tabBarTheme: TabBarThemeData(
      dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.5),
      splashBorderRadius: BorderRadius.circular(SolRadius.sm),
      labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      unselectedLabelStyle: textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surfaceContainer,
      elevation: 0,
      indicatorColor: colorScheme.secondaryContainer,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SolRadius.md),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return textTheme.labelMedium?.copyWith(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? colorScheme.onSurface : onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 24,
          color: selected ? colorScheme.onSecondaryContainer : onSurfaceVariant,
        );
      }),
    ),
    navigationRailTheme: NavigationRailThemeData(
      indicatorColor: colorScheme.secondaryContainer,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SolRadius.md),
      ),
      selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: onSurfaceVariant,
      ),
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(SolRadius.xl),
        ),
      ),
      endShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(SolRadius.xl),
        ),
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      elevation: const WidgetStatePropertyAll(0),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
      side: WidgetStatePropertyAll(
        BorderSide(color: colorScheme.outline.withValues(alpha: 0.8)),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(SolRadius.input)),
        ),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: SolSpace.lg),
      ),
      textStyle: WidgetStatePropertyAll(
        textTheme.bodyMedium?.copyWith(color: onSurface),
      ),
      hintStyle: WidgetStatePropertyAll(
        textTheme.bodyMedium?.copyWith(color: onSurfaceVariant),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(SolRadius.sm),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: SolSpace.md,
        vertical: SolSpace.sm,
      ),
      textStyle: textTheme.bodySmall?.copyWith(
        color: colorScheme.onInverseSurface,
      ),
      waitDuration: const Duration(milliseconds: 400),
      exitDuration: const Duration(milliseconds: 100),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant.withValues(alpha: 0.7),
      thickness: 1,
      space: SolSpace.lg,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered) ? 8 : 4,
      ),
      radius: const Radius.circular(SolRadius.pill),
      thumbColor: WidgetStatePropertyAll(
        onSurfaceVariant.withValues(alpha: 0.35),
      ),
      trackColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      year2023: false,
      color: colorScheme.primary,
      linearTrackColor: colorScheme.surfaceContainerHighest,
      circularTrackColor: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(SolRadius.pill),
    ),
    sliderTheme: SliderThemeData(
      year2023: false,
      activeTrackColor: colorScheme.primary,
      inactiveTrackColor: colorScheme.surfaceContainerHighest,
      thumbColor: colorScheme.primary,
      overlayColor: colorScheme.primary.withValues(alpha: 0.12),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide(color: colorScheme.outline, width: 1.2),
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.transparent;
        return colorScheme.outline;
      }),
    ),
  );
}

/// Turns the seed-generated neutrals into a warm paper palette.
///
/// Accent roles (primary / secondary / tertiary / error) are left exactly as
/// the seed produced them. Only the ground the accents sit on is warmed, which
/// is what makes a cool indigo or a bright orange scheme feel equally cozy.
ColorScheme _warmNeutrals(ColorScheme scheme, Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  return scheme.copyWith(
    surface: isDark ? const Color(0xFF17130F) : const Color(0xFFFBF7F3),
    surfaceDim: isDark ? const Color(0xFF14110E) : const Color(0xFFE9DFD6),
    surfaceBright: isDark ? const Color(0xFF3D332C) : const Color(0xFFFFFCF8),
    surfaceContainerLowest: isDark
        ? const Color(0xFF120F0C)
        : const Color(0xFFFFFFFF),
    surfaceContainerLow: isDark
        ? const Color(0xFF1E1915)
        : const Color(0xFFF8F2EC),
    surfaceContainer: isDark
        ? const Color(0xFF231D18)
        : const Color(0xFFF3ECE5),
    surfaceContainerHigh: isDark
        ? const Color(0xFF2D2620)
        : const Color(0xFFEDE4DC),
    surfaceContainerHighest: isDark
        ? const Color(0xFF392F28)
        : const Color(0xFFE7DDD4),
    onSurface: isDark ? const Color(0xFFF3EAE2) : const Color(0xFF261F1A),
    onSurfaceVariant: isDark
        ? const Color(0xFFD2C3B6)
        : const Color(0xFF5E544B),
    outline: isDark ? const Color(0xFF9C8B7D) : const Color(0xFF8D7F73),
    outlineVariant: isDark ? const Color(0xFF4D423A) : const Color(0xFFDBCFC4),
    inverseSurface: isDark ? const Color(0xFFF3EAE2) : const Color(0xFF362E27),
    onInverseSurface: isDark
        ? const Color(0xFF2B241E)
        : const Color(0xFFF8F0E9),
    shadow: isDark ? Colors.black : const Color(0xFF3D2C1E),
    scrim: isDark ? Colors.black : const Color(0xFF2A1F17),
  );
}

/// Softens the generated type ramp without changing its sizes.
///
/// Nunito already carries most of the warmth; the extra tracking on headings
/// and the taller body leading make long feeds and settings pages easier to
/// scan without making them feel loose.
TextTheme _buildTextTheme(TextTheme base) {
  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -1,
    ),
    displayMedium: base.displayMedium?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.8,
    ),
    displaySmall: base.displaySmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.6,
    ),
    headlineLarge: base.headlineLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    ),
    headlineSmall: base.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.25,
      height: 1.25,
    ),
    titleMedium: base.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      height: 1.3,
    ),
    titleSmall: base.titleSmall?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.3,
    ),
    bodyLarge: base.bodyLarge?.copyWith(height: 1.5),
    bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
    bodySmall: base.bodySmall?.copyWith(height: 1.4),
    labelLarge: base.labelLarge?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
    labelMedium: base.labelMedium?.copyWith(
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
  );
}

/// Horizontal title alignment a collapsing header must be told explicitly.
///
/// A plain `AppBar` resolves `centerTitle` as
/// `centerTitle ?? AppBarTheme.centerTitle ?? platformDefault`. `FlexibleSpaceBar`
/// does not: it resolves `centerTitle ?? platformDefault`, and `AppBarTheme`
/// never reaches it (nor is it forwarded through `FlexibleSpaceBar.createSettings`).
/// The platform default is left-aligned on Android/Windows/Linux and centered
/// only on iOS/macOS, so a `SliverAppBar` whose title lives in a
/// `FlexibleSpaceBar` must thread this value into *both* widgets itself.
bool appBarCenterTitle(ThemeData theme) =>
    theme.appBarTheme.centerTitle ?? true;
