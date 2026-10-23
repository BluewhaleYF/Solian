import 'package:flutter_test/flutter_test.dart';
import 'package:island/shared/widgets/sliver_floating_tab_bar.dart';
import 'package:material_ui/material_ui.dart';

/// The strip leaves the viewport with the content it heads, and comes back on
/// the first upward drag instead of waiting for the pane to reach its top.
void main() {
  testWidgets('floating tab bar leaves and returns with scroll', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(500, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            body: Builder(
              builder: (context) => NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverFloatingTabBar(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: TabBar(
                      tabs: const [Tab(text: 'One'), Tab(text: 'Two')],
                    ),
                  ),
                ],
                body: TabBarView(
                  children: [
                    ListView(
                      children: [
                        for (var i = 0; i < 60; i++)
                          SizedBox(height: 60, child: Text('row $i')),
                      ],
                    ),
                    const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TabBar), findsOneWidget);
    final startTop = tester.getRect(find.byType(TabBar)).top;
    expect(startTop, greaterThanOrEqualTo(0));

    // Deep into the list: the strip has left with the content.
    await tester.drag(find.text('row 3'), const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(find.byType(TabBar), findsNothing);

    // A short upward drag is enough — the pane is nowhere near its top.
    await tester.drag(find.text('row 20'), const Offset(0, 60));
    await tester.pumpAndSettle();
    expect(find.byType(TabBar), findsOneWidget);
    expect(tester.getRect(find.byType(TabBar)).top, greaterThanOrEqualTo(0));
  });
}
