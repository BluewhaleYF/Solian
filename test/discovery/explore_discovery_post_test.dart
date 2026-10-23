import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/discovery/explore.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/posts/posts_pod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _GuestUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

Map<String, dynamic> _image(String id) => {
  'id': id,
  'name': '$id.png',
  'mime_type': 'image/png',
  'width': 400,
  'height': 300,
};

SnPost _replyPost(String id, {Map<String, dynamic> refOverrides = const {}}) => SnPost.fromJson({
  'id': id,
  'type': 0,
  'content': 'my reply body that is a little longer so it wraps',
  'publisher': {'id': 'publisher-1', 'name': 'alice', 'nick': 'Alice'},
  'replied_post_id': 'parent-$id',
  'replied_post': {
    'id': 'parent-$id',
    'type': 0,
    'content': 'parent body',
    'chained_posts': const [],
    'publisher': {'id': 'publisher-2', 'name': 'bob', 'nick': 'Bob'},
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  },
  'reactions_count': <String, dynamic>{},
  'reactions_made': <String, dynamic>{},
  'chained_posts': <dynamic>[],
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
});

class _DiscoveryFeed extends ActivityListNotifier {
  @override
  Future<PaginationState<SnTimelineEvent>> build() async {
    final post = _replyPost('post-1');
    final event = SnTimelineEvent.fromJson({
      'id': 'event-1',
      'type': 'discovery.v2',
      'resource_identifier': 'discovery:post',
      'data': {
        'kind': 'post',
        'items': [
          {'data': post.toJson(), 'rank': 'highest', 'score': 0.9},
        ],
      },
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-01-01T00:00:00Z',
      'deleted_at': null,
    });
    return PaginationState(
      items: [event],
      isLoading: false,
      isReloading: false,
      totalCount: 1,
      hasMore: false,
      cursor: null,
    );
  }

  @override
  Future<List<SnTimelineEvent>> fetch({int retryCount = 0}) async => [];
}

class _EmptyAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(const <dynamic>[]),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('reference with two images', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(420, 900);
    addTearDown(tester.view.reset);

    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _EmptyAdapter();

    final item = PostActionableItem(
      item: _replyPost('post-2', refOverrides: {
        'attachments': [_image('a'), _image('b')],
      }),
      isCompact: true,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
    );

    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: Builder(
            builder: (context) => MaterialApp(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              localizationsDelegates: context.localizationDelegates,
              home: ProviderScope(
                overrides: [
                  sharedPreferencesProvider.overrideWithValue(prefs),
                  apiClientProvider.overrideWithValue(dio),
                  userInfoProvider.overrideWith(() => _GuestUserInfo()),
                ],
                child: Material(
                  child: Center(
                    child: SizedBox(width: 320, height: 280, child: SingleChildScrollView(child: item)),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final ex = tester.takeException();
    // ignore: avoid_print
    print('EXCEPTION: $ex');
    expect(ex, isNull);
  });

  testWidgets('explore discovery post card renders', (tester) async {
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(420, 900);
    addTearDown(tester.view.reset);

    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _EmptyAdapter();

    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: Builder(
            builder: (context) => MaterialApp(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              localizationsDelegates: context.localizationDelegates,
              home: ProviderScope(
                overrides: [
                  sharedPreferencesProvider.overrideWithValue(prefs),
                  apiClientProvider.overrideWithValue(dio),
                  userInfoProvider.overrideWith(() => _GuestUserInfo()),
                  activityListProvider.overrideWith(() => _DiscoveryFeed()),
                ],
                child: const ExploreScreen(),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    for (final e in find.byType(Icon).evaluate()) {
      final icon = e.widget as Icon;
      // ignore: avoid_print
      print('ICON ${icon.icon?.codePoint} @ ${tester.getRect(find.byWidget(icon))}');
    }
    // ignore: avoid_print
    print('REF: ${find.byType(ReferencedPostWidget).evaluate().length}');
    for (final e in find.byType(SingleChildScrollView).evaluate()) {
      final box = e.renderObject as RenderBox?;
      // ignore: avoid_print
      print('SCROLL ${box?.size} at ${box == null ? null : box.localToGlobal(Offset.zero)}');
    }
    // ignore: avoid_print
    print('POST ROW: ${tester.getRect(find.byType(PostActionableItem))}');
    // ignore: avoid_print
    print('REF RECT: ${tester.getRect(find.byType(ReferencedPostWidget))}');

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });
}
