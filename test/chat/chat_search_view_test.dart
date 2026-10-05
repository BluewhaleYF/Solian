import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/chat_search_screen.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/data/database.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

SnChatRoom _room(String id, String name) {
  final now = DateTime.utc(2026);
  return SnChatRoom(
    id: id,
    name: name,
    description: null,
    type: 0,
    picture: null,
    background: null,
    realmId: null,
    accountId: null,
    realm: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    members: null,
  );
}

SnChatMember _member(String roomId, String nick) {
  final now = DateTime.utc(2026);
  final account = SnAccount(
    id: 'account-$nick',
    name: nick.toLowerCase(),
    nick: nick,
    language: 'en',
    isSuperuser: false,
    automatedId: null,
    profile: SnAccountProfile(
      id: 'profile-$nick',
      experience: 0,
      level: 1,
      levelingProgress: 0,
      picture: null,
      background: null,
      verification: null,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    ),
    perkSubscription: null,
    activatedAt: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
  return SnChatMember(
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
    id: 'member-$roomId',
    chatRoomId: roomId,
    chatRoom: null,
    accountId: account.id,
    account: account,
    nick: null,
    notify: 0,
    joinedAt: now,
    breakUntil: null,
    timeoutUntil: null,
    chatGroupId: null,
    chatGroup: null,
    lastReadAt: null,
    status: null,
    realmNick: null,
    realmBio: null,
    realmExperience: null,
    realmLevel: null,
    realmLevelingProgress: null,
    realmLabel: null,
  );
}

Map<String, dynamic> _messageJson({
  required String roomId,
  required String id,
  required String content,
  required DateTime createdAt,
  String type = 'text',
}) {
  final sender = _member(roomId, 'Nia');
  return SnChatMessage(
    id: id,
    chatRoomId: roomId,
    senderId: sender.id,
    sender: sender,
    type: type,
    content: content,
    createdAt: createdAt,
    updatedAt: createdAt,
  ).toJson();
}

/// Two rooms' worth of cloud hits, newest match first, the way the search
/// endpoint groups them.
String _searchPayload() {
  final now = DateTime.now();
  return jsonEncode([
    {
      'room': _room('room-design', 'Design crew').toJson(),
      'messages': [
        _messageJson(
          roomId: 'room-design',
          id: 'm-1',
          content: '**the needle is here**, pick it up',
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
        _messageJson(
          roomId: 'room-design',
          id: 'm-2',
          content: 'another needle drops tomorrow',
          createdAt: now.subtract(const Duration(days: 20)),
        ),
      ],
    },
    {
      'room': _room('room-ops', 'Ops').toJson(),
      'messages': [
        _messageJson(
          roomId: 'room-ops',
          id: 'm-3',
          content: 'we ship on Friday',
          createdAt: now.subtract(const Duration(days: 2)),
        ),
        _messageJson(
          roomId: 'room-ops',
          id: 'm-4',
          content: 'Nia joined the chat',
          createdAt: now.subtract(const Duration(days: 2)),
          type: 'system.member.joined',
        ),
      ],
    },
  ]);
}

class _ScriptedAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.contains('/messager/chat/rooms/sync')) {
      return ResponseBody.fromString(
        jsonEncode(<String, dynamic>{}),
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }
    return ResponseBody.fromString(
      _searchPayload(),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        'x-total': ['4'],
      },
    );
  }
}

/// Every run of text a result row drew with the query mark on it.
List<String> _markedRuns(WidgetTester tester) {
  final marked = <String>[];
  for (final text in tester.widgetList<Text>(find.byType(Text))) {
    final span = text.textSpan;
    if (span is! TextSpan) continue;
    span.visitChildren((child) {
      if (child is TextSpan && child.style?.backgroundColor != null) {
        marked.add(child.text ?? '');
      }
      return true;
    });
  }
  return marked;
}

String _plainTextOf(WidgetTester tester, Finder finder) {
  final text = tester.widget<Text>(finder);
  return text.textSpan?.toPlainText() ?? text.data ?? '';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<ValueNotifier<String>> pumpView(
    WidgetTester tester,
    Size size, {
    String query = 'needle',
  }) async {
    final searchQuery = ValueNotifier<String>(query);
    final filtersVisible = ValueNotifier<bool>(false);
    addTearDown(() {
      searchQuery.dispose();
      filtersVisible.dispose();
    });
    final prefs = await SharedPreferences.getInstance();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = size;
    addTearDown(tester.view.reset);

    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'))
      ..httpClientAdapter = _ScriptedAdapter();

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
                  databaseProvider.overrideWithValue(AppDatabase.web()),
                ],
                child: Scaffold(
                  body: ChatMessageSearchView(
                    searchQuery: searchQuery,
                    filtersVisible: filtersVisible,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Design crew').evaluate().isNotEmpty) break;
    }
    await tester.pump(const Duration(milliseconds: 200));
    return searchQuery;
  }

  /// Unmounts inside the test body: the joined-rooms watcher reschedules as
  /// the tree goes away, which trips the pending-timer invariant at teardown.
  Future<void> disposeTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    while (tester.takeException() != null) {}
  }

  testWidgets('groups hits under room bands that state their reach', (
    tester,
  ) async {
    await pumpView(tester, const Size(400, 800));

    expect(find.text('Design crew'), findsOneWidget);
    expect(find.text('Ops'), findsOneWidget);
    // Bands keep the payload's order: newest match first.
    expect(
      tester.getTopLeft(find.text('Design crew')).dy,
      lessThan(tester.getTopLeft(find.text('Ops')).dy),
    );

    // Each band states how many hits it holds and the days they fall on: the
    // upper room's two hits sit weeks apart, the lower room's on one day.
    final readouts = tester
        .widgetList<Text>(
          find.byWidgetPredicate(
            (w) => w is Text && (w.data?.startsWith('2 matches') ?? false),
          ),
        )
        .map((text) => text.data!)
        .toList();
    expect(readouts, hasLength(2));
    expect(readouts.first, contains('–'));
    expect(readouts.last, isNot(contains('–')));
    for (final readout in readouts) {
      expect(
        readout,
        matches(
          RegExp(
            r'^2 matches {2}· {2}[A-Z][a-z]{2} \d{1,2}(, \d{4})?'
            r'( – [A-Z][a-z]{2} \d{1,2}(, \d{4})?)?$',
          ),
        ),
      );
    }

    await disposeTree(tester);
  });

  testWidgets('marks the query inside each hit body', (tester) async {
    await pumpView(tester, const Size(400, 800));

    // Both hits in "Design crew" spell the term out; the Ops hit does not,
    // which is what a term-matched index result looks like.
    expect(_markedRuns(tester), ['needle', 'needle']);

    // Markdown is unwrapped before the window is taken.
    final firstBody = _plainTextOf(
      tester,
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            (w.textSpan?.toPlainText().contains('pick it up') ?? false),
      ),
    );
    expect(firstBody, 'the needle is here, pick it up');

    // A term-matched row still shows its body, unmarked.
    final opsBody = _plainTextOf(
      tester,
      find.byWidgetPredicate(
        (w) =>
            w is Text &&
            (w.textSpan?.toPlainText().contains('we ship on Friday') ?? false),
      ),
    );
    expect(opsBody, 'we ship on Friday');

    await disposeTree(tester);
  });

  testWidgets('draws event messages with the rich renderer', (tester) async {
    await pumpView(tester, const Size(400, 800));

    // `system.member.joined` bodies are not prose: the row keeps the icon and
    // text the chat itself draws.
    expect(find.text('Nia joined the chat'), findsOneWidget);
    expect(find.byIcon(Symbols.group_add), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('the footer reads out matches and rooms', (tester) async {
    await pumpView(tester, const Size(400, 800));

    expect(find.text('4 matches  ·  2 rooms'), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('the ledger stops widening on a wide window', (tester) async {
    await pumpView(tester, const Size(1400, 900));

    final listWidth = tester.getSize(find.byType(SuperListView)).width;
    expect(listWidth, kChatSearchLedgerWidth);
    expect(
      tester.getSize(find.text('4 matches  ·  2 rooms')).width,
      lessThan(400),
    );

    await disposeTree(tester);
  });

  testWidgets('idle: teaches the search before it runs', (tester) async {
    final query = await pumpView(tester, const Size(400, 800), query: '');

    expect(find.text("Search every room you're in"), findsOneWidget);
    expect(
      find.text(
        'Type a phrase, or narrow it with a sender, a date range, '
        'links, or attachments.',
      ),
      findsOneWidget,
    );

    // Nothing has been searched, so no readout claims a count.
    expect(find.textContaining('matches'), findsNothing);

    // The host page's field drives the section: a new query runs the search.
    query.value = 'needle';
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Design crew').evaluate().isNotEmpty) break;
    }
    expect(find.text('Design crew'), findsOneWidget);
    expect(find.text('4 matches  ·  2 rooms'), findsOneWidget);

    await disposeTree(tester);
  });
}
