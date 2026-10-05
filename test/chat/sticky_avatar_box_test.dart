import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/chat/widgets/sticky_avatar_box.dart';

/// A tall owner box (a message row or a sender group) inside a scroll view,
/// carrying one avatar pinned to the viewport. The avatar must rest on its
/// anchor while the owner is below the top edge, pin 12px below the viewport
/// top while the owner crosses it, and ride up with the owner's bottom edge.
void main() {
  const viewportHeight = 300.0;
  const topMargin = 12.0;
  const avatarSize = 32.0;
  const ownerTop = 200.0;
  const ownerHeight = 400.0;
  const anchorTop = 40.0;

  late ScrollController controller;
  late GlobalKey anchorKey;
  late GlobalKey avatarKey;

  Future<void> pumpOwner(WidgetTester tester, {bool enabled = true}) async {
    controller = ScrollController();
    anchorKey = GlobalKey();
    avatarKey = GlobalKey();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: viewportHeight,
            child: ListView(
              controller: controller,
              children: [
                const SizedBox(height: ownerTop),
                SizedBox(
                  height: ownerHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: anchorTop),
                          const SizedBox(height: 24, key: ValueKey('row')),
                        ],
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        child: StickyAvatarBox(
                          anchorKey: anchorKey,
                          topMargin: topMargin,
                          enabled: enabled,
                          child: SizedBox.fromSize(
                            key: avatarKey,
                            size: const Size.square(avatarSize),
                            child: const ColoredBox(color: Colors.blue),
                          ),
                        ),
                      ),
                      // Anchor marker: the box the avatar rests on. Hidden
                      // behind the avatar when it is not pinned.
                      Positioned(
                        left: 0,
                        top: anchorTop,
                        child: SizedBox.fromSize(
                          size: const Size.square(1),
                          key: anchorKey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 600),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double avatarTop(WidgetTester tester) =>
      tester.getTopLeft(find.byKey(avatarKey)).dy;

  double scrollTop(WidgetTester tester) =>
      tester.getTopLeft(find.byType(Scrollable)).dy;

  testWidgets('rests on its anchor while the owner is below the top edge', (
    tester,
  ) async {
    await pumpOwner(tester);

    expect(avatarTop(tester), scrollTop(tester) + ownerTop + anchorTop);
  });

  testWidgets('pins to the top margin while the owner crosses it', (
    tester,
  ) async {
    await pumpOwner(tester);

    controller.jumpTo(300);
    await tester.pump();

    // Owner top is 100px above the viewport; owner bottom is still 300px
    // below it.
    expect(avatarTop(tester), scrollTop(tester) + topMargin);
  });

  testWidgets('rides the owner bottom once the owner leaves', (tester) async {
    await pumpOwner(tester);

    controller.jumpTo(ownerTop + ownerHeight - avatarSize - 2);
    await tester.pump();

    final ownerBottom = scrollTop(tester) + 2 + avatarSize;
    expect(avatarTop(tester), ownerBottom - avatarSize);
    expect(tester.getBottomLeft(find.byKey(avatarKey)).dy, ownerBottom);
  });

  testWidgets('stays on its anchor when pinning is disabled', (tester) async {
    await pumpOwner(tester, enabled: false);

    controller.jumpTo(300);
    await tester.pump();

    // The owner scrolls up; the avatar moves with it, unpinned.
    expect(avatarTop(tester), tester.getTopLeft(find.byKey(anchorKey)).dy);
  });
}
