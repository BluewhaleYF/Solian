import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/accounts/widgets/friend_status_toast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/notification.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

SnAccount _account(String id, {String? nick}) {
  final now = DateTime.utc(2026);
  return SnAccount(
    id: id,
    name: id,
    nick: nick ?? id,
    language: 'en',
    isSuperuser: false,
    automatedId: null,
    profile: SnAccountProfile(
      id: 'profile-$id',
      experience: 0,
      level: 1,
      levelingProgress: 0.0,
      picture: null,
      background: null,
      verification: null,
      createdAt: now,
      updatedAt: now,
      deletedAt: null,
    ),
    perkSubscription: null,
    badges: [],
    contacts: [],
    activatedAt: now,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
}

SnPresenceActivity _activity({String? title, String? subtitle}) {
  final now = DateTime.utc(2026);
  return SnPresenceActivity(
    id: 'activity-1',
    type: 'gaming',
    manualId: 'steam',
    title: title,
    subtitle: subtitle,
    caption: null,
    titleUrl: null,
    subtitleUrl: null,
    smallImage: null,
    largeImage: null,
    meta: null,
    leaseMinutes: 5,
    leaseExpiresAt: now.add(const Duration(hours: 1)),
    accountId: 'alice',
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
}

Widget _app(
  FriendStatusChangeEvent event,
  SharedPreferences prefs, {
  bool dismissed = false,
}) {
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: EasyLocalization(
      supportedLocales: const [Locale('en', 'US')],
      path: 'assets/i18n',
      saveLocale: false,
      child: Builder(
        builder: (context) => MaterialApp(
          locale: const Locale('en', 'US'),
          supportedLocales: const [Locale('en', 'US')],
          localizationsDelegates: context.localizationDelegates,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: FriendStatusToast(
                event: event,
                dismissed: dismissed,
                onDismiss: () {},
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Strings come from the real locale bundle, which loads from disk.
Future<void> _pump(
  WidgetTester tester,
  FriendStatusChangeEvent event,
  SharedPreferences prefs, {
  bool dismissed = false,
}) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(_app(event, prefs, dismissed: dismissed));
    // The locale bundle loads through the asset bundle asynchronously; without
    // real async time the first `tr()` in the tree would run against nothing.
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pump();
}

/// The capsule itself, not the full-width lane it is aligned in.
Finder _capsule() => find.descendant(
  of: find.byType(FriendStatusToast),
  matching: find.byType(InkWell),
);

/// Runs the delayed unfold to completion.
Future<void> _settleUnfold(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('pairs the name with the event verb in one capsule', (
    tester,
  ) async {
    await _pump(
      tester,
      FriendStatusChangeEvent(
        account: _account('alice', nick: 'Alice'),
        changeType: FriendStatusChangeType.online,
      ),
      prefs,
    );

    expect(find.text('Alice came online', findRichText: true), findsOneWidget);
    // No card, eyebrow or close button: the capsule is the whole notice.
    expect(find.byType(Card), findsNothing);
    expect(find.byIcon(Icons.close), findsNothing);
  });

  testWidgets('activity capsule names the activity instead of the category', (
    tester,
  ) async {
    await _pump(
      tester,
      FriendStatusChangeEvent(
        account: _account('alice', nick: 'Alice'),
        activities: [
          _activity(
            title: 'Dyson Sphere Program',
            subtitle: 'Playing Dyson Sphere Program',
          ),
        ],
        changeType: FriendStatusChangeType.activityStarted,
      ),
      prefs,
    );

    expect(
      find.text('Alice started Dyson Sphere Program', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('a status message rides in the tooltip, not a second line', (
    tester,
  ) async {
    final now = DateTime.utc(2026);
    await _pump(
      tester,
      FriendStatusChangeEvent(
        account: _account('alice', nick: 'Alice'),
        status: SnAccountStatus(
          id: 'status-1',
          attitude: 2,
          isOnline: true,
          isCustomized: true,
          type: 1,
          label: 'In a meeting',
          symbol: null,
          meta: null,
          clearedAt: null,
          appIdentifier: null,
          isAutomated: false,
          accountId: 'alice',
          createdAt: now,
          updatedAt: now,
          deletedAt: null,
        ),
        changeType: FriendStatusChangeType.busy,
      ),
      prefs,
    );

    expect(find.text('Alice is now busy', findRichText: true), findsOneWidget);
    expect(find.text('In a meeting'), findsNothing);
    expect(find.byType(Tooltip), findsOneWidget);
  });

  testWidgets('starts as a bare avatar and unfolds the sentence', (
    tester,
  ) async {
    await _pump(
      tester,
      FriendStatusChangeEvent(
        account: _account('alice', nick: 'Alice'),
        changeType: FriendStatusChangeType.online,
      ),
      prefs,
    );

    // Nothing but the avatar is inside the pill the moment it lands.
    final collapsed = tester.getSize(_capsule());
    expect(collapsed.height, collapsed.width);

    await _settleUnfold(tester);
    final expanded = tester.getSize(_capsule());
    expect(expanded.width, greaterThan(collapsed.width));
    expect(expanded.height, collapsed.height);
    expect(find.text('Alice came online', findRichText: true), findsOneWidget);
  });

  testWidgets('retracts to the avatar when dismissed, then leaves', (
    tester,
  ) async {
    await _pump(
      tester,
      FriendStatusChangeEvent(
        account: _account('alice', nick: 'Alice'),
        changeType: FriendStatusChangeType.online,
      ),
      prefs,
    );
    await _settleUnfold(tester);
    final expanded = tester.getSize(_capsule());
    expect(expanded.width, greaterThan(expanded.height));

    await _pump(
      tester,
      FriendStatusChangeEvent(
        account: _account('alice', nick: 'Alice'),
        changeType: FriendStatusChangeType.online,
      ),
      prefs,
      dismissed: true,
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Same silhouette the entrance showed: a circle, not a shrinking pill.
    final retracted = tester.getSize(_capsule());
    expect(retracted.width, retracted.height);
    expect(retracted.width, lessThan(expanded.width));
  });

  testWidgets('friend-status items declare their own chrome and slot', (
    tester,
  ) async {
    final item = NotificationItem.friendStatus(
      event: FriendStatusChangeEvent(
        account: _account('alice'),
        changeType: FriendStatusChangeType.online,
      ),
      index: 0,
    );

    expect(item.selfSurfaced, isTrue);
    expect(item.stackAdvance, greaterThan(0));
  });
}
