import 'dart:convert';
import 'dart:typed_data';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart' as legacy_material;
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island_ui_foundation/island_ui_foundation.dart';
import 'package:island/data/database.dart';
import 'package:island/posts/widgets/compose/compose_schedule.dart';
import 'package:island/posts/widgets/compose/compose_settings_sheet.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:island/realms/screens/realms.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Answers the settings sheet's own lookups (tag suggestions, realms,
/// categories) with empty lists, and the publisher's collections with two
/// entries, so nothing touches the network.
class _ScriptedAdapter implements HttpClientAdapter {
  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async {
    final body = options.path.endsWith('/collections')
        ? [
            {
              'id': 'c1',
              'slug': 'first',
              'name': 'First collection',
              'publisher_id': 'p',
            },
            {
              'id': 'c2',
              'slug': 'second',
              'name': 'Second collection',
              'publisher_id': 'p',
            },
          ]
        : const [];
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        'x-total': ['${body.length}'],
      },
    );
  }
}

class _SheetHost extends HookWidget {
  final ComposeState state;

  const _SheetHost({required this.state});

  @override
  Widget build(BuildContext context) {
    // The app wraps its whole tree in a legacy `Material` (main.dart's
    // compatibility bridge) because dropdown_button2 still lives in
    // flutter/material; the sheet needs the same ancestor here.
    return legacy_material.Material(
      type: legacy_material.MaterialType.transparency,
      child: Material(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ComposeSettingsSheet(state: state),
        ),
      ),
    );
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

  Future<void> pumpSheet(
    WidgetTester tester,
    ComposeState state, {
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
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
                Dio()..httpClientAdapter = _ScriptedAdapter(),
              ),
              realmsJoinedProvider.overrideWith((ref) async => <SnRealm>[]),
            ],
            child: Builder(
              builder: (context) => MaterialApp(
                navigatorKey: navigatorKey,
                locale: const Locale('en', 'US'),
                // main.dart's compatibility bridge gives every route a legacy
                // `Material`; dropdown_button2 still needs one.
                builder: (context, child) => legacy_material.Material(
                  type: legacy_material.MaterialType.transparency,
                  child: child ?? const SizedBox.shrink(),
                ),
                supportedLocales: const [Locale('en', 'US')],
                localizationsDelegates: context.localizationDelegates,
                theme: ThemeData(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
                  inputDecorationTheme: const InputDecorationThemeData(
                    filled: true,
                    fillColor: Color(0xFFEFE7D8),
                  ),
                ),
                home: _SheetHost(state: state),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
  }

  testWidgets('tags field is a filled, labelled field like the others', (
    tester,
  ) async {
    final state = ComposeLogic.createState();
    await pumpSheet(tester, state);

    // The tags field renders through the decorated field used across the
    // settings (filled background, floating label) instead of a bare
    // container with a heading of its own.
    InputDecorator tagsDecorator() => tester
        .widgetList<InputDecorator>(find.byType(InputDecorator))
        .firstWhere((decorator) => decorator.decoration.labelText == 'Tags');
    expect(tagsDecorator().decoration.labelText, 'Tags');
    expect(find.text('Tags'), findsOneWidget);
    expect(find.text('Add Tag'), findsOneWidget);

    // A tag in the field shows up as a removable chip inside it.
    state.tags.value = ['flutter'];
    await tester.pump();
    expect(find.text('#flutter'), findsOneWidget);
  });

  testWidgets('settings sheet embeds the publish-time field', (tester) async {
    final state = ComposeLogic.createState();
    await pumpSheet(tester, state);

    expect(find.byType(ComposeScheduleField), findsOneWidget);
    expect(find.text('Not set'), findsOneWidget);

    state.scheduledAt.value = DateTime.now().add(const Duration(hours: 3));
    await tester.pump();

    expect(find.textContaining('Scheduled for'), findsOneWidget);
    expect(find.text('Publish now'), findsOneWidget);

    await tester.tap(find.text('Publish now'));
    await tester.pump();

    expect(state.scheduledAt.value, isNull);
    expect(find.text('Not set'), findsOneWidget);
  });

  testWidgets('settings open as an attention modal with its own chrome', (
    tester,
  ) async {
    final state = ComposeLogic.createState();
    final navigatorKey = GlobalKey<NavigatorState>();
    IslandUIFoundation.configureNavigator(navigatorKey);
    addTearDown(dismissAllAttentionModals);

    await pumpSheet(tester, state, navigatorKey: navigatorKey);

    showComposeSettingsSheet(tester.element(find.byType(_SheetHost)), state);
    await tester.pumpAndSettle();

    // The modal scaffold owns the surface: settings title in the header, one
    // sheet body inside it, and the composer keeps its settings button.
    final scaffold = tester.widget<AttentionModalScaffold>(
      find.byType(AttentionModalScaffold),
    );
    expect(scaffold.titleText, 'Settings');
    expect(
      find.descendant(
        of: find.byType(AttentionModalScaffold),
        matching: find.byType(ComposeSettingsSheet),
      ),
      findsOneWidget,
    );

    // Dismissing through the modal's own close button tears the sheet down.
    await tester.tap(find.byIcon(Symbols.close));
    await tester.pumpAndSettle();
    expect(find.byType(AttentionModalScaffold), findsNothing);
  });

  testWidgets('a collection toggles instead of piling up', (tester) async {
    final state = ComposeLogic.createState();
    state.currentPublisher.value = SnPublisher.fromJson({
      'id': 'p',
      'type': 0,
      'name': 'publisher',
      'nick': 'N',
    });
    await pumpSheet(tester, state);
    await tester.tap(find.byType(DropdownButton2<SnPostCollection>));
    await tester.pumpAndSettle();

    // A chosen collection also shows as a chip in the field, so taps have to
    // target the menu row. The menu keeps its item widgets from the moment it
    // opened, so the tick has to come from the live selection: tapping the
    // same collection twice adds it once, and unticking removes it again.
    Future<void> tapRow(String name) => tester.tap(
      find.descendant(
        of: find.byType(legacy_material.InkWell),
        matching: find.text(name),
      ),
    );

    await tapRow('First collection');
    await tester.pump();
    expect(state.collectionIds.value, ['c1']);

    await tapRow('First collection');
    await tester.pump();
    expect(state.collectionIds.value, isEmpty);

    await tapRow('First collection');
    await tester.pump();
    await tapRow('Second collection');
    await tester.pump();
    expect(state.collectionIds.value, ['c1', 'c2']);
  });
}
