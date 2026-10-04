import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';

/// The height below which a pinned profile header counts as collapsed:
/// the pinned toolbar plus the status-bar inset.
double profileHeaderCollapseThreshold(
  BuildContext context,
  double expandedHeight,
) {
  return expandedHeight - (kToolbarHeight + MediaQuery.paddingOf(context).top);
}

/// Average color of [provider]'s image, or null when it never resolves or
/// cannot be decoded. Pixels are sampled sparsely, so this stays cheap on
/// large headers.
Future<Color?> sampleImageAverageColor(ImageProvider provider) {
  final completer = Completer<Color?>();
  final stream = provider.resolve(const ImageConfiguration());
  late final ImageStreamListener listener;
  listener = ImageStreamListener(
    (info, synchronousCall) {
      stream.removeListener(listener);
      // The stream owns [info.image]; clone before releasing it so the async
      // decode below does not race with its disposal.
      final image = info.image.clone();
      unawaited(() async {
        Color? value;
        try {
          value = await _averageColorOf(image);
        } catch (_) {
          value = null;
        } finally {
          image.dispose();
        }
        completer.complete(value);
      }());
    },
    onError: (error, stackTrace) {
      stream.removeListener(listener);
      completer.complete(null);
    },
  );
  stream.addListener(listener);
  return completer.future;
}

Future<Color?> _averageColorOf(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (data == null) return null;
  final bytes = data.buffer.asUint8List();
  // Every 32nd pixel: plenty for an average, cheap on big images.
  const step = 4 * 32;
  var rSum = 0;
  var gSum = 0;
  var bSum = 0;
  var count = 0;
  for (var i = 0; i + 3 < bytes.length; i += step) {
    if (bytes[i + 3] == 0) continue; // skip fully transparent pixels
    rSum += bytes[i];
    gSum += bytes[i + 1];
    bSum += bytes[i + 2];
    count++;
  }
  if (count == 0) return null;
  return Color.fromARGB(255, rSum ~/ count, gSum ~/ count, bSum ~/ count);
}

/// Feeds [collapsed] with whether the scrollable rendered by [child] has
/// scrolled past [threshold]. Only notifications from the outermost viewport
/// are considered, so nested scrollables (e.g. `NestedScrollView`) do not
/// report their own inner offset.
class ProfileHeaderScrollListener extends StatelessWidget {
  final ValueNotifier<bool> collapsed;
  final double threshold;
  final Widget child;

  const ProfileHeaderScrollListener({
    super.key,
    required this.collapsed,
    required this.threshold,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth != 0) return false;
        final isCollapsed = notification.metrics.pixels >= threshold;
        if (collapsed.value != isCollapsed) collapsed.value = isCollapsed;
        return false;
      },
      child: child,
    );
  }
}

/// The primary/on-primary pair derived from a header image's average tint.
class ProfileHeaderColors {
  final Color primary;
  final Color onPrimary;

  const ProfileHeaderColors({required this.primary, required this.onPrimary});
}

/// Derives a header's dominant color pair from a sampled [tint]. Falls back to
/// the theme's primary when the image could not be sampled.
ProfileHeaderColors profileHeaderColors(ThemeData theme, Color? tint) {
  final scheme = tint == null ? null : ColorScheme.fromSeed(seedColor: tint);
  final primary = scheme?.primary ?? theme.colorScheme.primary;
  final onPrimary = primary.computeLuminance() < 0.5
      ? Colors.white
      : Colors.black87;
  return ProfileHeaderColors(primary: primary, onPrimary: onPrimary);
}

/// Pinned, collapsing header shared by the profile screens.
///
/// [background] (the profile image) fills the header with [title] over a scrim
/// tinted by the image's average color. Once [collapsed] flips true the header
/// becomes a solid app bar painted with that image's dominant ("primary")
/// color, keeping the title legible. Pass [samplingProvider] so the tint can
/// be sampled; without it the header is a plain surface. [tintNotifier]
/// receives the sampled tint so sibling chrome (e.g. the tab bar) can match.
class ProfileHeaderAppBar extends HookWidget {
  final String title;
  final Widget background;
  final ValueListenable<bool> collapsed;
  final ImageProvider? samplingProvider;
  final ValueNotifier<Color?>? tintNotifier;
  final Widget? overlay;
  final double expandedHeight;
  final Widget? leading;

  const ProfileHeaderAppBar({
    super.key,
    required this.title,
    required this.background,
    required this.collapsed,
    this.samplingProvider,
    this.tintNotifier,
    this.overlay,
    this.expandedHeight = 220,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = useState<Color?>(null);

    useEffect(() {
      final provider = samplingProvider;
      if (provider == null) return null;
      var disposed = false;
      sampleImageAverageColor(provider).then((color) {
        if (disposed) return;
        final value = color ?? Colors.black;
        tint.value = value;
        tintNotifier?.value = value;
      });
      return () => disposed = true;
    }, [samplingProvider]);

    final hasImage = samplingProvider != null;
    final colors = profileHeaderColors(theme, tint.value);
    final primary = colors.primary;
    final onPrimary = colors.onPrimary;
    final isCollapsed = useValueListenable(collapsed);
    final titleColor = isCollapsed
        ? onPrimary
        : (hasImage
              ? Colors.white.withOpacity(0.9)
              : theme.colorScheme.onSurface);
    // Reuse the app bar title style so the header keeps the app-wide font and
    // size; only the color is overridden for legibility over the image.
    final titleStyle =
        (theme.appBarTheme.titleTextStyle ??
                theme.textTheme.titleLarge ??
                const TextStyle())
            .copyWith(color: titleColor, fontWeight: FontWeight.w600);
    // FlexibleSpaceBar ignores AppBarTheme.centerTitle, so mirror it here.
    final centerTitle = theme.appBarTheme.centerTitle ?? true;

    return SliverAppBar(
      pinned: true,
      centerTitle: centerTitle,
      expandedHeight: expandedHeight,
      automaticallyImplyLeading: false,
      leading: leading,
      backgroundColor: isCollapsed ? primary : theme.colorScheme.surface,
      foregroundColor: titleColor,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        centerTitle: centerTitle,
        title: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: titleStyle,
          child: Text(title),
        ),
        background: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isCollapsed
              ? ColoredBox(
                  key: const ValueKey('profile-header-collapsed'),
                  color: primary,
                )
              : Stack(
                  key: const ValueKey('profile-header-expanded'),
                  fit: StackFit.expand,
                  children: [
                    background,
                    if (hasImage)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              (tint.value ?? Colors.black).withOpacity(0.45),
                              (tint.value ?? Colors.black).withOpacity(0),
                              (tint.value ?? Colors.black).withOpacity(0.5),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ?overlay,
                  ],
                ),
        ),
      ),
    );
  }
}
