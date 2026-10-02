import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/message_item.dart';
import 'package:island/core/config.dart';

const _surface = Size(400, 320);

void main() {
  Widget harness({required bool insideBubble}) {
    Widget reactions() => MessageReactionChips(
          displayStyle: 'bubble',
          isCurrentUser: false,
          showAvatar: true,
          reactionsCount: const {'heart': 1},
          reactionsMade: const {},
          isExpanded: false,
          submitting: false,
          insideBubble: insideBubble,
          onReact: (_, _) async {},
        );

    return ProviderScope(
      overrides: [serverUrlProvider.overrideWithValue('http://localhost')],
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: double.infinity,
            child: insideBubble
                // Production bubble: the chips are the last child of the
                // bubble body column, next to a Flexible bubble in a row.
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Container(
                          key: const Key('bubble'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(10),
                                child: Text('hi'),
                              ),
                              reactions(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  )
                // Production below-the-bubble chips: a stretch column.
                : Column(
                    key: const Key('stretch-column'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [reactions()],
                  ),
          ),
        ),
      ),
    );
  }

  testWidgets('bubble hugs its content when the chips sit inside it', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(_surface);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(harness(insideBubble: true));
    await tester.pumpAndSettle();

    final bubbleRect = tester.getRect(find.byKey(const Key('bubble')));

    // A one-glyph bubble with a single chip must stay narrow: the chips may
    // not drag the bubble out to the row's full width.
    expect(
      bubbleRect.width,
      lessThan(_surface.width / 2),
      reason: 'chips inside the bubble must not stretch it to the row width',
    );
    // ...and the chips still have to fit inside the bubble they belong to.
    final chipsRect = tester.getRect(find.byType(Wrap));
    expect(chipsRect.left, greaterThanOrEqualTo(bubbleRect.left));
    expect(chipsRect.right, lessThanOrEqualTo(bubbleRect.right));
  });

  testWidgets('below-the-bubble chips still fill the message row', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(_surface);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(harness(insideBubble: false));
    await tester.pumpAndSettle();

    // The chip row is a child of a stretch column in the other display
    // styles, so hugging its content must not change its width there.
    expect(
      tester.getSize(find.byType(MessageReactionChips)).width,
      _surface.width,
    );
  });
}
