import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/network/relay.dart';
import 'package:island/misc/widgets/relay_route_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';

const _healthy = RelayEntry(
  id: 'hk-01',
  endpoint: 'hk-01.relay.example',
  port: 443,
  region: 'Hong Kong',
  weight: 3,
  healthy: true,
);
const _unhealthy = RelayEntry(
  id: 'fra-01',
  endpoint: 'fra-01.relay.example',
  port: 7443,
  region: 'Frankfurt',
  weight: 1,
  healthy: false,
);
const _hkRoute = RelayRoute(
  id: 'hk-01',
  host: 'hk-01.relay.example',
  port: 443,
  region: 'Hong Kong',
);
const _fraRoute = RelayRoute(
  id: 'fra-01',
  host: 'fra-01.relay.example',
  port: 7443,
  region: 'Frankfurt',
);

Widget _app({
  required SharedPreferences prefs,
  required Future<List<RelayEntry>> Function() catalog,
  required Widget child,
  RelayProbeReport report = const RelayProbeReport(
    direct: RelayProbeResult(),
    relays: [],
  ),
  RelaySuspension? suspension,
}) {
  return ProviderScope(
    // Riverpod retries failed providers on a timer by default; the error test
    // asserts the state as it is, not as retried.
    retry: (count, error) => null,
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) => prefs),
      relayCatalogProvider.overrideWith(() => _StubCatalog(catalog)),
      if (suspension != null)
        relaySuspensionProvider.overrideWith(
          () => _SuspendedRelay(suspension),
        ),
      // Stubbed, so no test dials the announced relays: the tests below are
      // about what the sheet does with a measurement, not about measuring.
      relayProbeResultsProvider.overrideWith((ref) => report),
    ],
    child: EasyLocalization(
      supportedLocales: const [Locale('en', 'US')],
      path: 'assets/i18n',
      saveLocale: false,
      child: Builder(
        builder: (context) => MaterialApp(
          locale: const Locale('en', 'US'),
          supportedLocales: const [Locale('en', 'US')],
          localizationsDelegates: context.localizationDelegates,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          ),
          home: child,
        ),
      ),
    ),
  );
}

Widget _opener() {
  return Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => const RelayRouteSheet(),
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );
}

Future<SharedPreferences> _prefs({RelayRoute? storedRoute}) async {
  SharedPreferences.setMockInitialValues(
    storedRoute == null
        ? {}
        : {kNetworkRelayRouteStoreKey: jsonEncode(storedRoute.toJson())},
  );
  return SharedPreferences.getInstance();
}

/// A catalog that answers from memory, [load] being what the server would say.
///
/// The real notifier fetches, and no test here may: retry has to be covered
/// too, and it would otherwise reach the network.
class _StubCatalog extends RelayCatalogNotifier {
  _StubCatalog(this.load);

  final Future<List<RelayEntry>> Function() load;

  @override
  Future<List<RelayEntry>> build() => load();

  @override
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(load);
  }
}

/// A relay the app already dropped, so the sheet has to explain the gap.
class _SuspendedRelay extends RelaySuspensionNotifier {
  _SuspendedRelay(this.suspension);

  final RelaySuspension suspension;

  @override
  RelaySuspension? build() => suspension;
}

/// Pumps with a real async window so EasyLocalization's file-backed load
/// finishes before the tree settles.
Future<void> _pumpApp(WidgetTester tester, Widget app) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(app);
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    // EasyLocalization reads the saved locale through shared_preferences during
    // init, so the mock store has to exist first.
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('lists every announced relay with its endpoint', (tester) async {
    final prefs = await _prefs();
    await _pumpApp(
      tester,
      _app(
        prefs: prefs,
        catalog: () async => [_healthy, _unhealthy],
        child: _opener(),
      ),
    );
    await _openSheet(tester);

    expect(find.text('Hong Kong'), findsOneWidget);
    expect(find.text('Frankfurt'), findsOneWidget);
    expect(find.text('hk-01.relay.example'), findsOneWidget);
    expect(find.textContaining('fra-01.relay.example:7443'), findsOneWidget);
    // The sheet explains the choice instead of leaving the rows unexplained.
    expect(find.textContaining('nearby relay'), findsOneWidget);
  });

  testWidgets('marks a relay unhealthy and leaves the healthy one silent', (
    tester,
  ) async {
    final prefs = await _prefs();
    await _pumpApp(
      tester,
      _app(
        prefs: prefs,
        catalog: () async => [_healthy, _unhealthy],
        child: _opener(),
      ),
    );
    await _openSheet(tester);

    expect(find.textContaining('· unhealthy'), findsOneWidget);
    expect(find.text('fra-01.relay.example:7443 · unhealthy'), findsOneWidget);
  });

  testWidgets('shows the stored relay as selected', (tester) async {
    final prefs = await _prefs(
      storedRoute: const RelayRoute(
        id: 'hk-01',
        host: 'hk-01.relay.example',
        port: 443,
        region: 'Hong Kong',
      ),
    );
    await _pumpApp(
      tester,
      _app(
        prefs: prefs,
        catalog: () async => [_healthy, _unhealthy],
        child: _opener(),
      ),
    );
    await _openSheet(tester);

    final selected = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .where((tile) => tile.selected);
    expect(selected, hasLength(1), reason: 'exactly one route is current');
    expect(find.text('hk-01.relay.example'), findsOneWidget);
  });

  testWidgets('tapping a relay stores it and closes the sheet', (tester) async {
    final prefs = await _prefs();
    await _pumpApp(
      tester,
      _app(
        prefs: prefs,
        catalog: () async => [_healthy, _unhealthy],
        child: _opener(),
      ),
    );
    await _openSheet(tester);

    await tester.tap(find.text('Frankfurt'));
    await tester.pumpAndSettle();

    expect(find.byType(RelayRouteSheet), findsNothing);
    final stored = prefs.getString(kNetworkRelayRouteStoreKey);
    expect(stored, isNotNull);
    expect(jsonDecode(stored!), containsPair('id', 'fra-01'));
  });

  testWidgets('tapping direct clears the stored relay', (tester) async {
    final prefs = await _prefs(
      storedRoute: const RelayRoute(
        id: 'hk-01',
        host: 'hk-01.relay.example',
        port: 443,
        region: 'Hong Kong',
      ),
    );
    await _pumpApp(
      tester,
      _app(
        prefs: prefs,
        catalog: () async => [_healthy, _unhealthy],
        child: _opener(),
      ),
    );
    await _openSheet(tester);

    await tester.tap(find.text('Direct'));
    await tester.pumpAndSettle();

    expect(prefs.getString(kNetworkRelayRouteStoreKey), isNull);
  });

  testWidgets('keeps a selection the server no longer announces', (
    tester,
  ) async {
    final prefs = await _prefs(
      storedRoute: const RelayRoute(
        id: 'old-01',
        host: 'old-01.relay.example',
        port: 443,
      ),
    );
    await _pumpApp(
      tester,
      _app(prefs: prefs, catalog: () async => [_healthy], child: _opener()),
    );
    await _openSheet(tester);

    expect(find.text('old-01.relay.example'), findsOneWidget);
    expect(find.text('hk-01.relay.example'), findsOneWidget);
  });

  testWidgets('a dropped relay is announced and can be tried again', (
    tester,
  ) async {
    final prefs = await _prefs(
      storedRoute: const RelayRoute(
        id: 'hk-01',
        host: 'hk-01.relay.example',
        port: 443,
        region: 'Hong Kong',
      ),
    );
    await _pumpApp(
      tester,
      _app(
        prefs: prefs,
        catalog: () async => [_healthy],
        suspension: RelaySuspension(
          route: _hkRoute,
          failure: RelayDialFailure.certificate,
          error: 'CERTIFICATE_VERIFY_FAILED',
          at: DateTime(2026),
        ),
        child: _opener(),
      ),
    );
    await _openSheet(tester);

    expect(
      find.textContaining('was disabled after a failed connection'),
      findsOneWidget,
      reason: 'the picker must not look like it ignored the selection',
    );
    expect(find.text('CERTIFICATE_VERIFY_FAILED'), findsOneWidget);

    await tester.tap(find.text('Use it again'));
    await tester.pumpAndSettle();

    expect(find.byType(RelayRouteSheet), findsNothing);
    final stored = prefs.getString(kNetworkRelayRouteStoreKey);
    expect(stored, isNotNull);
    expect(jsonDecode(stored!), containsPair('id', 'hk-01'));
  });

  testWidgets('empty catalog explains itself', (tester) async {
    final prefs = await _prefs();
    await _pumpApp(
      tester,
      _app(
        prefs: prefs,
        catalog: () async => const <RelayEntry>[],
        child: _opener(),
      ),
    );
    await _openSheet(tester);

    expect(find.textContaining('does not announce'), findsOneWidget);
  });

  testWidgets('catalog failure shows the reason and retries into data', (
    tester,
  ) async {
    final prefs = await _prefs();
    var attempts = 0;
    await _pumpApp(
      tester,
      _app(
        prefs: prefs,
        catalog: () async {
          attempts++;
          if (attempts == 1) {
            throw RelayCatalogException('HTTP 502', statusCode: 502);
          }
          return [_healthy];
        },
        child: _opener(),
      ),
    );
    await _openSheet(tester);

    expect(find.textContaining('Unable to load'), findsOneWidget);
    expect(find.text('HTTP 502'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('hk-01.relay.example'), findsOneWidget);
    expect(find.textContaining('Unable to load'), findsNothing);
  });

  testWidgets('lays out a long catalog on a narrow screen without overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final prefs = await _prefs();
    await _pumpApp(
      tester,
      _app(
        prefs: prefs,
        catalog: () async => [
          const RelayEntry(
            id: 'hk-01',
            endpoint: 'long-relay-name-that-keeps-going.hk-01.relay.example',
            port: 443,
            region: 'Hong Kong',
            healthy: true,
          ),
          _unhealthy,
          ...List.generate(
            6,
            (index) => RelayEntry(
              id: 'sg-0$index',
              endpoint: 'sg-0$index.relay.example',
              port: 443,
              region: 'Singapore',
              healthy: true,
            ),
          ),
        ],
        child: _opener(),
      ),
    );
    await _openSheet(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Hong Kong'), findsOneWidget);
    expect(find.byIcon(Symbols.check), findsOneWidget);
  });

  testWidgets('the relay tile subtitle fills both placeholders', (
    tester,
  ) async {
    final prefs = await _prefs();
    await _pumpApp(
      tester,
      _app(prefs: prefs, catalog: () async => [], child: _opener()),
    );

    const route = RelayRoute(
      id: 'hk-01',
      host: 'hk-01.relay.example',
      port: 7443,
      region: 'Hong Kong',
    );
    final subtitle = 'settingsRelayRouteVia'.tr(
      args: [route.displayHost, relayDisplayName(route.region, route.host)],
    );

    expect(subtitle, contains('hk-01.relay.example:7443'));
    expect(subtitle, contains('Hong Kong'));
    expect(
      subtitle,
      isNot(contains('{')),
      reason: 'placeholders must not leak',
    );
  });

  testWidgets('an airport code region is spelled out for the reader', (
    tester,
  ) async {
    final prefs = await _prefs();
    await _pumpApp(
      tester,
      _app(prefs: prefs, catalog: () async => [], child: _opener()),
    );

    // The fleet names regions by airport code; the reader gets the name.
    expect(relayDisplayName('can', 'net.cnlongy.cc'), 'Guangzhou');
    expect(relayDisplayName('CAN', 'net.cnlongy.cc'), 'Guangzhou');
    expect(relayDisplayName('szx', 'net.cnlongy.cc'), 'Shenzhen');
    expect(relayDisplayName('nrt', 'net.cnlongy.cc'), 'Tokyo');
    expect(relayDisplayName('sin', 'net.cnlongy.cc'), 'Singapore');
    expect(
      relayDisplayName('zzz', 'net.cnlongy.cc'),
      'ZZZ',
      reason: 'a code no language names is still shown as the code',
    );
  });

  test('a relay without a region falls back to its host label', () {
    expect(relayDisplayName('', 'de-fra-01.relay.example'), 'de-fra-01');
    expect(relayDisplayName('  ', 'de-fra-01.relay.example'), 'de-fra-01');
    expect(
      relayDisplayName('Frankfurt', 'de-fra-01.relay.example'),
      'Frankfurt',
    );
    expect(relayDisplayName('', 'relay.example'), 'relay');
  });

  testWidgets('shows what each relay measured', (tester) async {
    final prefs = await _prefs();
    await _pumpApp(
      tester,
      _app(
        prefs: prefs,
        catalog: () async => [_healthy, _unhealthy],
        report: const RelayProbeReport(
          direct: RelayProbeResult(latency: Duration(milliseconds: 30)),
          relays: [
            RelayProbeResult(
              route: _hkRoute,
              latency: Duration(milliseconds: 42),
            ),
            RelayProbeResult(
              route: _fraRoute,
              error: RelayProbeException('no answer'),
            ),
          ],
        ),
        child: _opener(),
      ),
    );
    await _openSheet(tester);

    expect(find.text('42 ms'), findsOneWidget);
    expect(
      find.text('30 ms'),
      findsOneWidget,
      reason: 'the direct row is measured too, so it can be compared',
    );
    expect(
      find.text('—'),
      findsOneWidget,
      reason: 'a relay that never answered is not left looking untested',
    );
    expect(find.textContaining('and the direct connection'), findsOneWidget);
  });

  testWidgets('auto picks the fastest measured relay', (tester) async {
    final prefs = await _prefs();
    await _pumpApp(
      tester,
      _app(
        prefs: prefs,
        catalog: () async => [_healthy, _unhealthy],
        report: const RelayProbeReport(
          direct: RelayProbeResult(latency: Duration(milliseconds: 40)),
          relays: [
            RelayProbeResult(
              route: _hkRoute,
              latency: Duration(milliseconds: 90),
            ),
            // Faster than a relay the catalog calls healthy, and the
            // measurement is the one that knows about this network.
            RelayProbeResult(
              route: _fraRoute,
              latency: Duration(milliseconds: 12),
            ),
          ],
        ),
        child: _opener(),
      ),
    );
    await _openSheet(tester);

    await tester.tap(find.text('Auto (fastest)'));
    await tester.pumpAndSettle();

    expect(find.byType(RelayRouteSheet), findsNothing);
    final stored = prefs.getString(kNetworkRelayRouteStoreKey);
    expect(stored, isNotNull);
    expect(jsonDecode(stored!), containsPair('id', 'fra-01'));
  });

  testWidgets('auto takes the direct connection when it is the fastest', (
    tester,
  ) async {
    final prefs = await _prefs(
      storedRoute: const RelayRoute(
        id: 'hk-01',
        host: 'hk-01.relay.example',
        port: 443,
        region: 'Hong Kong',
      ),
    );
    await _pumpApp(
      tester,
      _app(
        prefs: prefs,
        catalog: () async => [_healthy, _unhealthy],
        report: const RelayProbeReport(
          direct: RelayProbeResult(latency: Duration(milliseconds: 8)),
          relays: [
            RelayProbeResult(
              route: _hkRoute,
              latency: Duration(milliseconds: 90),
            ),
          ],
        ),
        child: _opener(),
      ),
    );
    await _openSheet(tester);

    await tester.tap(find.text('Auto (fastest)'));
    await tester.pumpAndSettle();

    expect(find.byType(RelayRouteSheet), findsNothing);
    expect(
      prefs.getString(kNetworkRelayRouteStoreKey),
      isNull,
      reason: 'the fastest candidate is no relay, so nothing is stored',
    );
  });

  testWidgets('auto stays unavailable until something answers', (tester) async {
    final prefs = await _prefs();
    await _pumpApp(
      tester,
      _app(
        prefs: prefs,
        catalog: () async => [_healthy],
        report: const RelayProbeReport(
          direct: RelayProbeResult(error: RelayProbeException('no answer')),
          relays: [
            RelayProbeResult(
              route: _hkRoute,
              error: RelayProbeException('no answer'),
            ),
          ],
        ),
        child: _opener(),
      ),
    );
    await _openSheet(tester);

    expect(find.text('No relay answered the latency test.'), findsOneWidget);

    await tester.tap(find.text('Auto (fastest)'));
    await tester.pumpAndSettle();

    expect(find.byType(RelayRouteSheet), findsOneWidget);
    expect(prefs.getString(kNetworkRelayRouteStoreKey), isNull);
  });
}
