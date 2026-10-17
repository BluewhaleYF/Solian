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
import 'package:island/posts/widgets/compose/compose_schedule.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/tasks/tasks_notifier.dart';
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

ResponseBody _json(Object data, {int status = 200}) => ResponseBody.fromString(
  jsonEncode(data),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
    'x-total': ['1'],
  },
);

SnPublisher _publisher() => SnPublisher.fromJson({
  'id': 'publisher-1',
  'type': 0,
  'name': 'tester',
  'nick': 'Tester',
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
});

Map<String, dynamic> _postJson({
  required String id,
  required String content,
  String? publishedAt,
  bool drafted = false,
}) => {
  'id': id,
  'type': 0,
  'content': content,
  'chained_posts': const [],
  'publisher': _publisher().toJson(),
  'drafted_at': drafted ? '2026-01-01T00:00:00Z' : null,
  'published_at':
      publishedAt ??
      (drafted ? null : DateTime.now().toUtc().toIso8601String()),
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
};

late WidgetRef capturedRef;
late BuildContext capturedContext;

class _RefCapture extends ConsumerWidget {
  const _RefCapture();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    capturedRef = ref;
    capturedContext = context;
    // Keep the task queue alive for the duration of the submission flow.
    ref.watch(tasksProvider);
    return const SizedBox.shrink();
  }
}

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

  Future<void> pumpHost(WidgetTester tester, HttpClientAdapter adapter) async {
    final prefs = await SharedPreferences.getInstance();
    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en', 'US')],
          path: 'assets/i18n',
          saveLocale: false,
          child: ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              databaseProvider.overrideWithValue(database),
              apiClientProvider.overrideWithValue(
                Dio()..httpClientAdapter = adapter,
              ),
            ],
            child: const MaterialApp(home: _RefCapture()),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pump();
  }

  testWidgets('scheduled post sends published_at instead of drafting', (
    tester,
  ) async {
    final scheduledAt = DateTime.now().add(const Duration(days: 1));
    final adapter = _ScriptedAdapter(
      (options) async => _json(
        _postJson(
          id: 'scheduled-post',
          content: 'later',
          publishedAt: scheduledAt.toUtc().toIso8601String(),
        ),
      ),
    );
    await pumpHost(tester, adapter);

    final state = ComposeLogic.createState();
    state.currentPublisher.value = _publisher();
    state.contentController.text = 'later';
    state.scheduledAt.value = scheduledAt;

    await tester.runAsync(
      () => ComposeLogic.performSubmit(
        capturedRef,
        state,
        capturedContext,
        onSuccess: () {},
      ),
    );

    final request = adapter.requests.single;
    expect(request.method.toUpperCase(), 'POST');
    expect(request.path, '/sphere/posts');
    final data = request.data as Map<String, dynamic>;
    expect(data['published_at'], scheduledAt.toUtc().toIso8601String());
    expect(data.containsKey('drafted_at'), isFalse);
    expect(state.scheduledAt.value, isNull);
  });

  testWidgets('scheduled cloud draft is patched and never published', (
    tester,
  ) async {
    final scheduledAt = DateTime.now().add(const Duration(days: 2));
    final adapter = _ScriptedAdapter(
      (options) async => _json(
        _postJson(
          id: 'cloud-draft',
          content: 'later',
          publishedAt: scheduledAt.toUtc().toIso8601String(),
        ),
      ),
    );
    await pumpHost(tester, adapter);

    final state = ComposeLogic.createState(cloudDraftId: 'cloud-draft');
    state.currentPublisher.value = _publisher();
    state.contentController.text = 'later';
    state.scheduledAt.value = scheduledAt;

    await tester.runAsync(
      () => ComposeLogic.performSubmit(
        capturedRef,
        state,
        capturedContext,
        onSuccess: () {},
      ),
    );

    expect(adapter.requests, isNotEmpty);
    final patch = adapter.requests.single;
    expect(patch.method.toUpperCase(), 'PATCH');
    expect(patch.path, '/sphere/posts/cloud-draft');
    final data = patch.data as Map<String, dynamic>;
    expect(data['published_at'], scheduledAt.toUtc().toIso8601String());
    expect(adapter.requests.any((r) => r.path.endsWith('/publish')), isFalse);
  });

  testWidgets('schedule button and banner reflect the chosen time', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final state = ComposeLogic.createState();
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en', 'US')],
        path: 'assets/i18n',
        saveLocale: false,
        child: ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            databaseProvider.overrideWithValue(database),
          ],
          child: Builder(
            builder: (context) => MaterialApp(
              locale: const Locale('en', 'US'),
              supportedLocales: const [Locale('en', 'US')],
              localizationsDelegates: context.localizationDelegates,
              home: Scaffold(
                body: Column(
                  children: [
                    ComposeScheduleButton(state: state),
                    ComposeScheduledBanner(state: state),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Publish now'), findsNothing);

    state.scheduledAt.value = DateTime.now().add(const Duration(hours: 2));
    await tester.pump();

    for (final w in tester.widgetList<Text>(find.byType(Text))) {
      // ignore: avoid_print
      print('TEXT: ${w.data}');
    }
    expect(find.textContaining('Scheduled for'), findsOneWidget);
    expect(find.text('Publish now'), findsOneWidget);

    await tester.tap(find.text('Publish now'));
    await tester.pump();

    expect(state.scheduledAt.value, isNull);
    expect(find.text('Publish now'), findsNothing);
  });

  testWidgets(
    'clearing the schedule publishes an existing scheduled post now',
    (tester) async {
      final scheduledAt = DateTime.now().add(const Duration(days: 3));
      final originalPost = SnPost.fromJson(
        _postJson(
          id: 'scheduled-post',
          content: 'scheduled content',
          publishedAt: scheduledAt.toUtc().toIso8601String(),
        ),
      );
      final adapter = _ScriptedAdapter(
        (options) async => _json(
          _postJson(id: 'scheduled-post', content: 'scheduled content'),
        ),
      );
      await pumpHost(tester, adapter);

      final state = ComposeLogic.createState(originalPost: originalPost);
      state.currentPublisher.value = _publisher();
      expect(ComposeLogic.scheduledTimeOf(originalPost), isNotNull);
      expect(state.scheduledAt.value, isNotNull);

      ComposeLogic.clearSchedule(state);

      await tester.runAsync(
        () => ComposeLogic.performSubmit(
          capturedRef,
          state,
          capturedContext,
          originalPost: originalPost,
          onSuccess: () {},
        ),
      );

      final patch = adapter.requests.single;
      expect(patch.method.toUpperCase(), 'PATCH');
      expect(patch.path, '/sphere/posts/scheduled-post');
      final data = patch.data as Map<String, dynamic>;
      final publishedAt = DateTime.parse(data['published_at'] as String);
      expect(
        publishedAt.difference(DateTime.now()).inSeconds.abs(),
        lessThan(60),
      );
    },
  );
}
