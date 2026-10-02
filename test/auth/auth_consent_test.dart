import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/auth/web_auth/web_auth_app_info.dart';
import 'package:island/auth/widgets/auth_consent.dart';
import 'package:island/core/config.dart';
import 'package:island/developers/models/dev_project.dart';
import 'package:island/developers/models/developer.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Covers the shared consent surfaces rendered by the login-approval sheet, the
/// QR login sheet and the two device-authorization sheets. They are the only
/// place a user can check who is asking and what they get, so the fallbacks
/// matter as much as the happy path.
///
/// [AuthRequestingAppCard], [AppOwnerInfo] and [AuthUserCodeCard] are always
/// exercised without a picture: that keeps the test off the network-backed
/// `CloudImageWidget` while still covering the layout and copy.

Widget _wrap(Widget child) {
  return EasyLocalization(
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
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ),
  );
}

/// EasyLocalization loads from disk, so pump inside `runAsync` before settling.
Future<void> _pump(WidgetTester tester, Widget child) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.runAsync(() async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWith((ref) => prefs)],
        child: _wrap(child),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  group('AuthScopeList', () {
    testWidgets('humanizes known scopes', (tester) async {
      await _pump(
        tester,
        const AuthScopeList(scopes: ['openid', 'profile', 'email']),
      );

      expect(find.text('Read your Solarpass profile'), findsOneWidget);
      expect(
        find.text('Read your public profile information'),
        findsOneWidget,
      );
      expect(find.text('Read your email address'), findsOneWidget);
    });

    testWidgets('renders unknown scopes verbatim rather than inventing copy', (
      tester,
    ) async {
      await _pump(tester, const AuthScopeList(scopes: ['posts.bookmark']));

      expect(find.text('posts.bookmark'), findsOneWidget);
    });

    testWidgets('calls out wildcard access', (tester) async {
      await _pump(tester, const AuthScopeList(scopes: ['*']));

      expect(
        find.text('Full access: this app can do anything as you'),
        findsOneWidget,
      );
      expect(find.byIcon(Symbols.warning), findsOneWidget);
    });

    testWidgets('falls back to the no-scopes copy', (tester) async {
      await _pump(tester, const AuthScopeList(scopes: []));

      expect(find.text('No explicit scopes provided.'), findsOneWidget);
    });
  });

  group('AppOwnerInfo', () {
    testWidgets('shows the publisher and the home page host', (tester) async {
      await _pump(
        tester,
        const AppOwnerInfo(
          publisherName: 'Solar Studio',
          homeUri: 'https://example.com/about?ref=app',
        ),
      );

      expect(find.text('by'), findsOneWidget);
      expect(find.text('Solar Studio'), findsOneWidget);
      // Only the host is shown, matching the web provenance line.
      expect(find.text('example.com'), findsOneWidget);
    });

    testWidgets('collapses when there is no evidence to show', (tester) async {
      await _pump(tester, const AppOwnerInfo());

      expect(find.byType(Wrap), findsNothing);
    });
  });

  group('AuthRequestingAppCard', () {
    testWidgets('falls back to the client payload without a profile', (
      tester,
    ) async {
      await _pump(
        tester,
        AuthRequestingAppCard.fromClient(
          clientName: 'Some Client',
          clientDescription: 'A client description',
        ),
      );

      expect(find.text('Some Client'), findsOneWidget);
      expect(find.text('wants access to your account'), findsOneWidget);
      expect(find.text('A client description'), findsOneWidget);
    });

    testWidgets('prefers the resolved public app profile', (tester) async {
      final publisher = SnPublisher(name: 'studio', nick: 'Solar Studio');
      final developer = SnDeveloper(
        id: 'dev-1',
        publisherId: 'pub-1',
        publisher: publisher,
      );
      final project = SnDevProject(
        id: 'proj-1',
        slug: 'project',
        name: 'Project',
        description: 'project description',
        developer: developer,
        developerId: 'dev-1',
        createdAt: DateTime(2020),
        updatedAt: DateTime(2020),
        deletedAt: null,
      );
      final profile = WebAuthAppInfo(
        id: 'app-1',
        slug: 'verified-app',
        name: 'Verified App',
        description: 'fresh copy',
        status: 1,
        picture: null,
        background: null,
        verification: null,
        links: const {'home_page': 'https://verified.example/start'},
        projectId: 'proj-1',
        project: project,
        resourceIdentifier: 'developer.app:app-1',
        createdAt: DateTime(2020),
        updatedAt: DateTime(2020),
        deletedAt: null,
      );

      await _pump(
        tester,
        AuthRequestingAppCard.fromClient(
          clientName: 'raw-client-id',
          clientDescription: 'stale copy',
          clientHomeUri: 'https://raw.example',
          profile: profile,
        ),
      );

      expect(find.text('Verified App'), findsOneWidget);
      expect(find.text('fresh copy'), findsOneWidget);
      expect(find.text('stale copy'), findsNothing);
      expect(find.text('raw-client-id'), findsNothing);
      // Provenance: developer name plus the profile's home page host.
      expect(find.text('Solar Studio'), findsOneWidget);
      expect(find.text('verified.example'), findsOneWidget);
    });
  });

  group('AuthUserCodeCard', () {
    testWidgets('renders the code in the comparison style', (tester) async {
      await _pump(tester, const AuthUserCodeCard(userCode: 'BCDF-GHJK'));

      expect(find.text('BCDF-GHJK'), findsOneWidget);
      expect(find.text('User Code'), findsOneWidget);

      final code = tester.widget<Text>(find.text('BCDF-GHJK'));
      expect(code.style?.fontFamily, 'monospace');
      expect(code.style?.letterSpacing, 4);
    });
  });

  group('AuthResolvedPanel', () {
    testWidgets('names an approval and reports a remote decision', (
      tester,
    ) async {
      await _pump(
        tester,
        AuthResolvedPanel(
          outcome: AuthConsentOutcome.approved,
          remoteNote: 'This request was already resolved from another client.',
        ),
      );

      expect(find.text('Device Authorized'), findsOneWidget);
      expect(find.text('You can close this page.'), findsOneWidget);
      expect(
        find.text('This request was already resolved from another client.'),
        findsOneWidget,
      );
    });

    testWidgets('reports a declined request', (tester) async {
      await _pump(
        tester,
        const AuthResolvedPanel(outcome: AuthConsentOutcome.declined),
      );

      expect(find.text('Request Denied'), findsOneWidget);
      expect(find.text('The device request was denied.'), findsOneWidget);
    });

    testWidgets('reports an expired code and invokes onClose', (tester) async {
      var closed = false;
      await _pump(
        tester,
        AuthResolvedPanel(
          outcome: AuthConsentOutcome.expired,
          onClose: () => closed = true,
        ),
      );

      expect(find.text('Code Expired'), findsOneWidget);
      expect(
        find.text('This code has expired. Request a new one from your device.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(closed, isTrue);
    });
  });

  group('platform labels', () {
    testWidgets('maps client platform codes to localized names', (
      tester,
    ) async {
      await _pump(
        tester,
        Column(
          children: [
            Text(authPlatformName(kAuthPlatformIos)),
            Text(authPlatformName(kAuthPlatformAndroid)),
            Text(authPlatformName(kAuthPlatformWindows)),
            Text(authPlatformName(kAuthPlatformWeb)),
            Text(authPlatformName(null)),
          ],
        ),
      );

      expect(find.text('iOS'), findsOneWidget);
      expect(find.text('Android'), findsOneWidget);
      expect(find.text('Windows'), findsOneWidget);
      expect(find.text('Web'), findsOneWidget);
      expect(find.text('Unknown'), findsOneWidget);
    });
  });
}
