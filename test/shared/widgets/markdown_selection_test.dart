import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';

const _firstParagraph = 'Alpha bravo charlie';
const _secondParagraph = 'Delta echo foxtrot';

Widget _wrap(
  Widget child, {
  GlobalKey<NavigatorState>? navigatorKey,
  NavigatorObserver? observer,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en', 'US')],
    path: 'assets/i18n',
    saveLocale: false,
    child: Builder(
      builder: (context) => ProviderScope(
        // Above the navigator, as `main` does it: the post detail modal is
        // pushed as a route and reads its own providers from here.
        child: mui.MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [?observer],
          locale: const Locale('en', 'US'),
          supportedLocales: const [Locale('en', 'US')],
          localizationsDelegates: context.localizationDelegates,
          theme: mui.ThemeData(
            colorScheme: mui.ColorScheme.fromSeed(seedColor: Colors.indigo),
          ),
          home: mui.Material(child: mui.SingleChildScrollView(child: child)),
        ),
      ),
    ),
  );
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  GlobalKey<NavigatorState>? navigatorKey,
  NavigatorObserver? observer,
}) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(
      _wrap(child, navigatorKey: navigatorKey, observer: observer),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

/// The paragraph that renders [text], found through its plain text so the
/// assertion does not depend on widget nesting.
RenderParagraph _paragraph(WidgetTester tester, String text) {
  final paragraphs = tester
      .renderObjectList<RenderParagraph>(find.byType(RichText))
      .where((paragraph) => paragraph.text.toPlainText() == text);
  expect(paragraphs, hasLength(1), reason: 'no paragraph renders "$text"');
  return paragraphs.single;
}

/// The single paragraph whose text contains [needle].
RenderParagraph _paragraphContaining(WidgetTester tester, String needle) {
  final paragraphs = tester
      .renderObjectList<RenderParagraph>(find.byType(RichText))
      .where((paragraph) => paragraph.text.toPlainText().contains(needle))
      .toList();
  expect(paragraphs, hasLength(1), reason: 'no paragraph contains "$needle"');
  return paragraphs.single;
}

Offset _startOf(RenderParagraph paragraph) {
  return paragraph.localToGlobal(
    paragraph.getOffsetForCaret(const TextPosition(offset: 0), Rect.zero),
  );
}

Offset _endOf(RenderParagraph paragraph) {
  final text = paragraph.text.toPlainText();
  return paragraph.localToGlobal(
    paragraph.getOffsetForCaret(TextPosition(offset: text.length), Rect.zero),
  );
}

/// Every non-empty selection a paragraph currently reports.
List<TextSelection> _selections(RenderParagraph paragraph) {
  return paragraph.selections.where((s) => !s.isCollapsed).toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('a single drag selects across paragraphs', (tester) async {
    await _pump(
      tester,
      const MarkdownTextContent(
        content: '$_firstParagraph\n\n$_secondParagraph\n',
        isSelectable: true,
      ),
    );

    final first = _paragraph(tester, _firstParagraph);
    final second = _paragraph(tester, _secondParagraph);

    final gesture = await tester.startGesture(
      _startOf(first),
      kind: PointerDeviceKind.mouse,
    );
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(_endOf(second));
    await tester.pumpAndSettle();
    await gesture.up();
    await tester.pump();

    expect(
      _selections(first),
      isNotEmpty,
      reason: 'the paragraph the drag started in is part of the selection',
    );
    expect(
      _selections(second),
      isNotEmpty,
      reason: 'the drag continues into the next paragraph',
    );
    expect(
      _selections(first).first.baseOffset,
      0,
      reason: 'the selection starts at the beginning of the first paragraph',
    );
    expect(
      _selections(second).last.extentOffset,
      _secondParagraph.length,
      reason: 'the selection reaches the end of the second paragraph',
    );
  });

  testWidgets('a non-selectable body keeps its text inert', (tester) async {
    await _pump(
      tester,
      const MarkdownTextContent(
        content: '$_firstParagraph\n\n$_secondParagraph\n',
      ),
    );

    final first = _paragraph(tester, _firstParagraph);
    final gesture = await tester.startGesture(
      _startOf(first),
      kind: PointerDeviceKind.mouse,
    );
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(_endOf(_paragraph(tester, _secondParagraph)));
    await tester.pumpAndSettle();
    await gesture.up();
    await tester.pump();

    expect(_selections(first), isEmpty);
  });

  testWidgets('a link inside the selection area still responds to a tap', (
    tester,
  ) async {
    const id = '0198f0c2-1d4e-7a3b-9c6d-2f5e8a1b4c7d';
    const linked = 'first paragraph ';
    final navigatorKey = GlobalKey<NavigatorState>();
    final pushed = <String?>[];
    IslandUIFoundation.configureNavigator(navigatorKey);
    addTearDown(dismissAllAttentionModals);

    await _pump(
      tester,
      MarkdownTextContent(
        content:
            '$linked[a linked post](https://solian.app/posts/$id)\n\n'
            '$_secondParagraph\n',
        isSelectable: true,
      ),
      navigatorKey: navigatorKey,
      observer: _RouteSpy(pushed),
    );

    final paragraph = _paragraphContaining(tester, 'a linked post');
    final plain = paragraph.text.toPlainText();
    final linkStart = plain.indexOf('a linked post');
    final linkEnd = linkStart + 'a linked post'.length;
    final middle = paragraph.getOffsetForCaret(
      TextPosition(offset: (linkStart + linkEnd) ~/ 2),
      Rect.zero,
    );
    await tester.tapAt(paragraph.localToGlobal(middle + const Offset(0, 4)));
    await tester.pump();

    expect(pushed, contains('attention-modal:post-detail:$id'));
  });
}

/// Records the routes a tap pushes.
class _RouteSpy extends NavigatorObserver {
  _RouteSpy(this.pushed);

  final List<String?> pushed;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route.settings.name);
    super.didPush(route, previousRoute);
  }
}
