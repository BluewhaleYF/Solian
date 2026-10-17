import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/data/database.dart';
import 'package:island/posts/compose_storage_db.dart';
import 'package:island/posts/pods/draft_box.dart';
import 'package:island/posts/screens/draft_box.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart' as material_ui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _ScriptedAdapter implements HttpClientAdapter {
  _ScriptedAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;
  final List<RequestOptions> requests = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) {
    requests.add(options);
    return handler(options);
  }
}

ResponseBody _json(Object data, {int status = 200, int total = 0}) =>
    ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        if (total > 0) 'x-total': ['$total'],
      },
    );

Map<String, dynamic> _postJson({
  required String id,
  required String content,
  String? draftedAt,
  String? publishedAt,
  String updatedAt = '2026-03-01T00:00:00Z',
}) => {
  'id': id,
  'type': 0,
  'content': content,
  'publisher': {
    'id': 'publisher-1',
    'type': 0,
    'name': 'tester',
    'nick': 'Tester',
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  },
  'chained_posts': const [],
  'drafted_at': draftedAt,
  'published_at': publishedAt,
  'created_at': updatedAt,
  'updated_at': updatedAt,
};

SnPost _cloudDraft(String id, String updatedAt) => SnPost.fromJson(
  _postJson(
    id: id,
    content: 'cloud draft',
    draftedAt: updatedAt,
    updatedAt: updatedAt,
  ),
);

SnPost _scheduledPost(String id, String updatedAt) => SnPost.fromJson(
  _postJson(
    id: id,
    content: 'goes out later',
    publishedAt: DateTime.now()
        .add(const Duration(days: 2))
        .toUtc()
        .toIso8601String(),
    updatedAt: updatedAt,
  ),
);

SnPost _localDraft(String id, String updatedAt) => SnPost.fromJson(
  _postJson(id: id, content: 'device only draft', updatedAt: updatedAt),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    database = AppDatabase.web();
  });

  tearDown(() async {
    await database.close();
  });

  Future<ProviderContainer> makeContainer(HttpClientAdapter adapter) async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(database),
        apiClientProvider.overrideWithValue(Dio()..httpClientAdapter = adapter),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('merges device drafts, cloud drafts and scheduled posts', () async {
    await database.addPostDraftFromPost(
      _localDraft('m1', '2026-03-10T00:00:00Z'),
    );
    // A cloud draft is mirrored locally; it must not be listed twice.
    await database.addPostDraftFromPost(
      _cloudDraft('c1', '2026-03-01T00:00:00Z'),
    );

    final adapter = _ScriptedAdapter(
      (options) async => _json([
        _postJson(
          id: 'c1',
          content: 'cloud draft',
          draftedAt: '2026-03-01T00:00:00Z',
          updatedAt: '2026-03-01T00:00:00Z',
        ),
        _postJson(
          id: 's1',
          content: 'goes out later',
          publishedAt: DateTime.now()
              .add(const Duration(days: 2))
              .toUtc()
              .toIso8601String(),
          updatedAt: '2026-03-05T00:00:00Z',
        ),
      ], total: 2),
    );
    final container = await makeContainer(adapter);
    // Keep the auto-dispose provider alive for the duration of the read.
    final subscription = container.listen(draftBoxProvider, (_, _) {});
    addTearDown(subscription.close);

    final state = await container.read(draftBoxProvider.future);
    final entries = state.items;

    expect(entries.map((e) => e.post.id), ['m1', 's1', 'c1']);
    expect(entries.map((e) => e.source), [
      DraftBoxSource.localDraft,
      DraftBoxSource.scheduledPost,
      DraftBoxSource.cloudDraft,
    ]);
    expect(entries[0].isLocalOnly, isTrue);
    expect(entries[1].isScheduled, isTrue);
    expect(entries[1].scheduledAt, isNotNull);
    expect(entries[2].scheduledAt, isNull);
    expect(state.totalCount, 3);

    final request = adapter.requests.single;
    expect(request.path, '/sphere/posts/drafts');
    expect(request.queryParameters['include_scheduled'], isTrue);
  });

  Future<void> pumpTile(
    WidgetTester tester,
    HttpClientAdapter adapter,
    DraftBoxEntry entry,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(database),
        apiClientProvider.overrideWithValue(Dio()..httpClientAdapter = adapter),
      ],
    );
    addTearDown(container.dispose);

    await tester.runAsync(() async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: EasyLocalization(
            supportedLocales: const [Locale('en', 'US')],
            path: 'assets/i18n',
            saveLocale: false,
            child: Builder(
              builder: (context) => MaterialApp(
                locale: const Locale('en', 'US'),
                supportedLocales: const [Locale('en', 'US')],
                localizationsDelegates: [
                  ...context.localizationDelegates,
                  ...material_ui.GlobalMaterialLocalizations.delegates,
                ],
                home: Scaffold(body: DraftBoxTile(entry: entry)),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();
  }

  testWidgets('a scheduled entry offers publishing it right away', (
    tester,
  ) async {
    final scheduled = _scheduledPost('s1', '2026-03-05T00:00:00Z');
    final adapter = _ScriptedAdapter(
      (options) async => _json(const <dynamic>[], total: 0),
    );
    await pumpTile(
      tester,
      adapter,
      DraftBoxEntry(post: scheduled, source: DraftBoxSource.scheduledPost),
    );

    expect(find.textContaining('Scheduled for'), findsOneWidget);

    await tester.tap(find.byIcon(Symbols.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publish now'));
    await tester.pumpAndSettle();

    final publish = adapter.requests.firstWhere(
      (r) => r.path == '/sphere/posts/batch/visibility',
    );
    final data = publish.data as Map<String, dynamic>;
    expect(data['post_ids'], ['s1']);
    expect(
      DateTime.parse(
        data['published_at'] as String,
      ).difference(DateTime.now()).inSeconds.abs(),
      lessThan(60),
    );
    expect(data.containsKey('drafted_at'), isFalse);
  });

  testWidgets('a scheduled entry can be moved back to a draft', (tester) async {
    final scheduled = _scheduledPost('s1', '2026-03-05T00:00:00Z');
    final adapter = _ScriptedAdapter(
      (options) async => _json(const <dynamic>[], total: 0),
    );
    await pumpTile(
      tester,
      adapter,
      DraftBoxEntry(post: scheduled, source: DraftBoxSource.scheduledPost),
    );

    await tester.tap(find.byIcon(Symbols.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Move back to draft'));
    await tester.pumpAndSettle();

    final update = adapter.requests.firstWhere(
      (r) => r.path == '/sphere/posts/batch/visibility',
    );
    final data = update.data as Map<String, dynamic>;
    expect(data['post_ids'], ['s1']);
    expect(data['drafted_at'], isNotNull);
    expect(data.containsKey('published_at'), isFalse);
  });

  testWidgets('a device only draft is not offered scheduled actions', (
    tester,
  ) async {
    final adapter = _ScriptedAdapter(
      (options) async => _json(const <dynamic>[], total: 0),
    );
    await pumpTile(
      tester,
      adapter,
      DraftBoxEntry(
        post: _localDraft('m1', '2026-03-10T00:00:00Z'),
        source: DraftBoxSource.localDraft,
      ),
    );

    expect(find.text('This device only'), findsOneWidget);

    await tester.tap(find.byIcon(Symbols.more_vert));
    await tester.pumpAndSettle();

    expect(find.text('Publish now'), findsNothing);
    expect(find.text('Move back to draft'), findsNothing);
    expect(find.text('Upload to cloud'), findsOneWidget);
  });
  test('uploading a scheduled device draft keeps its publish time', () async {
    final scheduledAt = DateTime.now().add(const Duration(days: 1));
    final adapter = _ScriptedAdapter(
      (options) async => _json(
        _postJson(
          id: 'm2',
          content: 'device only draft',
          publishedAt: scheduledAt.toUtc().toIso8601String(),
          updatedAt: '2026-03-10T00:00:00Z',
        ),
      ),
    );
    final container = await makeContainer(adapter);
    final subscription = container.listen(composeStorageProvider, (_, _) {});
    addTearDown(subscription.close);

    final storage = container.read(composeStorageProvider.notifier);
    await storage.saveDraft(
      _localDraft(
        'm2',
        '2026-03-10T00:00:00Z',
      ).copyWith(publishedAt: scheduledAt),
    );

    await storage.uploadDraftToCloud('m2');

    final upload = adapter.requests.last;
    expect(upload.method.toUpperCase(), 'POST');
    expect(upload.path, '/sphere/posts');
    final data = upload.data as Map<String, dynamic>;
    expect(data['published_at'], scheduledAt.toUtc().toIso8601String());
    expect(data['drafted_at'], isNull);

    // The scheduled post now lives on the server; the device copy is gone so
    // the box lists it once.
    final drafts = await database.getAllPostDrafts();
    expect(drafts.map((d) => d.id), isNot(contains('m2')));
  });
}
