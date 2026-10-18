import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// `CarouselView.padding` wraps every card from outside its surface, so a
/// horizontal h both insets the leading edge by h and doubles into a 2h gap
/// between neighbours. A caller that hands over its whole gutter therefore
/// either gets an inflated gap (16) or, after halving the gutter to fix the
/// gap, an image that no longer lines up with the body text (8 instead of 16).
/// `CloudFileList.itemGap` splits the difference: half the gap to the view, the
/// rest of the gutter outside the viewport. These tests pin that geometry.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpCarousel(
    WidgetTester tester, {
    bool isFullBleed = false,
    double fullBleedFraction = 0.9,
    EdgeInsets? padding,
    double? itemGap,
    ValueChanged<int>? onIndexChanged,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final files = <IDisplayableCloudFile>[
      for (var i = 0; i < 3; i++)
        SnCloudFileReference(
          id: 'file-$i',
          name: 'image-$i.jpg',
          mimeType: 'image/jpeg',
          width: 100,
          height: 100,
        ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          serverUrlProvider.overrideWithValue('https://example.com'),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: CloudFileList(
              files: files,
              padding: padding,
              isFullBleed: isFullBleed,
              fullBleedFraction: fullBleedFraction,
              itemGap: itemGap,
              onIndexChanged: onIndexChanged,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // One Hero per rendered card: the artwork itself, not the card's chrome.
  List<Rect> cardRects(WidgetTester tester, Finder carouselFinder) {
    final heroes = find.descendant(
      of: carouselFinder,
      matching: find.byType(Hero),
    );
    final seen = <double>{};
    final rects = <Rect>[];
    for (final entity in heroes.evaluate()) {
      final rect = tester.getRect(find.byWidget(entity.widget));
      if (seen.add(rect.left)) rects.add(rect);
    }
    return rects..sort((a, b) => a.left.compareTo(b.left));
  }

  testWidgets('itemGap aligns the leading card with the gutter it was given', (
    tester,
  ) async {
    await pumpCarousel(
      tester,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemGap: 8,
    );

    final carouselFinder = find.byType(mui.CarouselView);
    expect(carouselFinder, findsOneWidget);

    final cards = cardRects(tester, carouselFinder);
    expect(cards.length, greaterThanOrEqualTo(2));
    expect(
      cards.first.left,
      16,
      reason: 'the first image must sit on the body gutter, not half of it',
    );
    expect(
      cards[1].left - cards.first.right,
      8,
      reason: 'two images sit itemGap apart, not 2×itemGap',
    );
  });

  testWidgets('a wider gap still starts on the same gutter', (tester) async {
    await pumpCarousel(
      tester,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemGap: 4,
    );

    final cards = cardRects(tester, find.byType(mui.CarouselView));
    expect(cards.first.left, 16);
    expect(
      cards[1].left - cards.first.right,
      4,
      reason: 'the leading inset must not drift when the gap changes',
    );
  });

  testWidgets('the peeking full-bleed strip keeps its card-side gap', (
    tester,
  ) async {
    await pumpCarousel(
      tester,
      isFullBleed: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
    );

    final carouselFinder = find.byType(mui.CarouselView);
    final carousel = tester.widget<mui.CarouselView>(carouselFinder);
    final viewportWidth = tester.getSize(carouselFinder).width;

    expect(
      carousel.itemExtent,
      closeTo(viewportWidth * 0.9, 0.001),
      reason: 'each item takes 90% of the width so the next one peeks',
    );
    expect(
      (carousel.shape as RoundedRectangleBorder).borderRadius,
      BorderRadius.zero,
      reason: 'multi-attachment items must have sharp borders',
    );
    expect(
      carousel.padding,
      const EdgeInsets.symmetric(vertical: 8),
      reason: 'the bleed reaches the host edges, so nothing horizontally '
          'insets it',
    );

    final children = carousel.children;
    expect(children.length, 3);
    for (final child in children.take(children.length - 1)) {
      expect(
        (child as Padding).padding,
        const EdgeInsets.only(right: 8),
        reason: 'inter-item gap lives on each card',
      );
    }
    expect(
      children.last,
      isNot(isA<Padding>()),
      reason: 'the last card is ungapped so the final page snaps flush to the '
          'right border',
    );
  });

  testWidgets('full-width carousel (post detail) is flush and reports index', (
    tester,
  ) async {
    final changed = <int>[];
    await pumpCarousel(
      tester,
      isFullBleed: true,
      fullBleedFraction: 1.0,
      padding: EdgeInsets.zero,
      onIndexChanged: changed.add,
    );

    final carouselFinder = find.byType(mui.CarouselView);
    final carousel = tester.widget<mui.CarouselView>(carouselFinder);
    final viewportWidth = tester.getSize(carouselFinder).width;

    expect(
      carousel.itemExtent,
      viewportWidth,
      reason: 'full-width pages — no peek in the dedicated viewer',
    );
    for (final child in carousel.children) {
      expect(
        child,
        isNot(isA<Padding>()),
        reason: 'full-width pages must be flush on both edges',
      );
    }

    await tester.drag(carouselFinder, Offset(-viewportWidth * 0.8, 0));
    await tester.pumpAndSettle();
    expect(
      changed,
      contains(1),
      reason: 'the viewer must learn the current page index',
    );
  });

  testWidgets('callers without an itemGap keep the padding they passed in', (
    tester,
  ) async {
    await pumpCarousel(tester, padding: EdgeInsets.zero);

    final carouselFinder = find.byType(mui.CarouselView);
    expect(
      tester.widget<mui.CarouselView>(carouselFinder).padding,
      EdgeInsets.zero,
      reason: 'chat bubbles rely on the explicit zero to keep cards touching',
    );
    expect(
      tester.getRect(carouselFinder).left,
      0,
      reason: 'no outer inset may appear for a caller that asked for none',
    );
  });
}
