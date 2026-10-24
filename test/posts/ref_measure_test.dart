import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

SnPost _post() => SnPost.fromJson({
  'id': 'reply-1',
  'type': 0,
  'content': 'reply body',
  'chained_posts': const [],
  'publisher': {'id': 'publisher-1', 'name': 'alice', 'nick': 'Alice'},
  'replied_post_id': 'parent-1',
  'replied_post': {
    'id': 'parent-1',
    'type': 0,
    'content': 'parent body',
    'chained_posts': const [],
    'publisher': {'id': 'publisher-2', 'name': 'bob', 'nick': 'Bob'},
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  },
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('measure', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);

    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: Builder(
            builder: (context) => mui.MaterialApp(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              localizationsDelegates: context.localizationDelegates,
              home: mui.Material(
                child: ProviderScope(
                  overrides: [
                    sharedPreferencesProvider.overrideWithValue(prefs),
                    publishersManagedProvider.overrideWith((ref) async => <SnPublisher>[]),
                    apiClientProvider.overrideWith((ref) => Dio()),
                  ],
                  child: mui.SingleChildScrollView(
                    child: PostActionableItem(item: _post(), isCompact: true),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();

    void dump(String label, Finder f) {
      for (final e in f.evaluate()) {
        final box = e.renderObject as RenderBox?;
        // ignore: avoid_print
        print('$label ${box?.size} at ${box?.localToGlobal(Offset.zero)}');
      }
    }

    dump('AVATAR', find.byType(PostAvatar));
    dump('HEADER', find.byType(PostHeader));
    dump('REF', find.byType(ReferencedPostWidget));
    dump('POSTITEM', find.byType(PostActionableItem));
    for (final e in find.byType(Text).evaluate()) {
      final t = e.widget as Text;
      // ignore: avoid_print
      print('TEXT "${t.data ?? t.textSpan?.toPlainText()}" ${tester.getRect(find.byWidget(t))}');
    }
  });
}
