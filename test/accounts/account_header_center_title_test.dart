import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/account_screen.dart';
import 'package:island/accounts/badge.dart';
import 'package:island/accounts/check_in.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/activity/activity_rpc.dart';
import 'package:island/core/config.dart';
import 'package:island/core/theme.dart';
import 'package:island/notifications/notification.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

final _account = SnAccount.fromJson({
  'id': 'account-1',
  'name': 'alice',
  'nick': 'Alice',
  'language': 'en-US',
  'is_superuser': false,
  'automated_id': null,
  'profile': {
    'id': 'profile-1',
    'bio': 'hello',
    'experience': 0,
    'level': 0,
    'leveling_progress': 0.0,
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  },
  'perk_subscription': null,
  'activated_at': '2026-01-01T00:00:00Z',
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
  'deleted_at': null,
});

class _SignedInUserInfo extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => _account;
}

/// Skips the real notifier's websocket subscription and network call.
class _UnreadCountStub extends NotificationUnreadCountNotifier {
  @override
  Future<int> build() async => 0;
}

Future<ThemeData> _windowsTheme() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWith((ref) => prefs)],
  );
  final theme = createAppTheme(
    Brightness.light,
    container.read(appSettingsProvider),
  );
  container.dispose();
  return theme.copyWith(platform: TargetPlatform.windows);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  // Regression: the header title lives in a `FlexibleSpaceBar`, which ignores
  // `AppBarTheme.centerTitle` and defaults per platform — left on Windows. The
  // account header must thread `appBarCenterTitle(theme)` into it explicitly.
  testWidgets('account header centers its title on Windows', (tester) async {
    final theme = await _windowsTheme();
    final prefs = await SharedPreferences.getInstance();
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWith((ref) => prefs),
            developerModeProvider.overrideWithValue(false),
            serverUrlProvider.overrideWithValue('https://example.com'),
            userInfoProvider.overrideWith(_SignedInUserInfo.new),
            notificationUnreadCountProvider.overrideWith(_UnreadCountStub.new),
            // The header is all this test inspects; keep the card stack below
            // it from opening sockets, timers, or the local database.
            accountStatusProvider.overrideWith((ref, uname) async => null),
            presenceActivitiesProvider.overrideWith(
              (ref, uname) async => <SnPresenceActivity>[],
            ),
            checkInResultTodayProvider.overrideWith((ref) async => null),
            badgeManifestMapProvider.overrideWithValue(const {}),
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
                theme: theme,
                home: const AccountFeatureWidget(),
              ),
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final header = find.byType(FlexibleSpaceBar);
    expect(header, findsOneWidget);
    final title = find.descendant(of: header, matching: find.byType(Text));
    expect(title, findsOneWidget);

    expect(
      tester.getCenter(title).dx,
      closeTo(tester.getCenter(header).dx, 1.0),
      reason: 'FlexibleSpaceBar title must follow the app-wide centerTitle',
    );

    // Dispose so the presence-refresh timer is cancelled.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
