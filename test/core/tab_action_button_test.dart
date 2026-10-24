import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/navigation/tab_action_button.dart';

void _noop() {}

TabActionButtonSpec _spec(String label) =>
    TabActionButtonSpec(symbol: 'plus', icon: Icons.add, label: label, onPressed: _noop);

void main() {
  testWidgets('registration publishes the action; a null spec withdraws it', (
    tester,
  ) async {
    final state = TabActionState();

    Widget shell({TabActionButtonSpec? spec}) {
      return TabActionScope(
        state: state,
        child: Column(
          children: [
            ValueListenableBuilder<Map<String, TabActionButtonSpec?>>(
              valueListenable: state,
              builder: (context, actions, _) {
                return Text(
                  actions['explore']?.label ?? 'none',
                  textDirection: TextDirection.ltr,
                );
              },
            ),
            TabActionRegistration(
              id: 'explore',
              spec: spec,
              child: const SizedBox(),
            ),
          ],
        ),
      );
    }

    await tester.pumpWidget(shell(spec: _spec('Compose')));
    await tester.pump();
    expect(state.of('explore'), isNotNull);
    expect(state.of('explore')!.label, 'Compose');

    // A tab that no longer offers an action (e.g. signed out) withdraws it.
    await tester.pumpWidget(shell(spec: null));
    await tester.pump();
    expect(state.of('explore'), isNull);
  });
}
