import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/config.dart';
import 'package:island/discovery/widgets/pill_app_bar.dart';
import 'package:island/posts/widgets/post_detail_content.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class _UserInfoGuest extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

SnPost _post({String? content}) => SnPost.fromJson({
  'id': 'post-1',
  'type': 0,
  'title': 'A post with a headline',
  'content': content ?? ('body text. ' * 400),
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
});

late SharedPreferences _prefs;

Widget _wrap(Widget child) => EasyLocalization(
  supportedLocales: const [Locale('en', 'US')],
  path: 'assets/i18n',
  saveLocale: false,
  child: Builder(
    builder: (context) => mui.MaterialApp(
      locale: const Locale('en', 'US'),
      supportedLocales: const [Locale('en', 'US')],
      localizationsDelegates: context.localizationDelegates,
      theme: mui.ThemeData(
        colorScheme: mui.ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(_prefs),
          userInfoProvider.overrideWith(_UserInfoGuest.new),
        ],
        child: mui.Material(child: child),
      ),
    ),
  ),
);

/// The fade value the page hands its header builder.
ValueNotifier<double>? _seenFade;

Widget _content(
  SnPost post, {
  bool withHeader = true,
  double topInset = 0,
}) => PostDetailContent(
  postId: post.id,
  post: post,
  topInset: topInset,
  onRefresh: () async {},
  onUpdate: (_) {},
  onReplyPosted: () {},
  interactionsSection: const SliverToBoxAdapter(child: SizedBox.shrink()),
  actionBuilder: (context, onTranslate) => const SizedBox.shrink(),
  headerSliverBuilder: withHeader
      ? (context, fade) {
          _seenFade = fade as ValueNotifier<double>;
          return PillSliverAppBar(
            fade: fade,
            statusTop: MediaQuery.paddingOf(context).top,
            child: const Text('header'),
          );
        }
      : null,
);

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(_wrap(child));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
    await EasyLocalization.ensureInitialized();
  });

  setUp(() => _seenFade = null);

  testWidgets('the page header is the shared glass pill', (tester) async {
    await _pump(tester, _content(_post()));

    expect(find.byType(PillSliverAppBar), findsOneWidget);
    expect(find.byType(PillBarSurface), findsOneWidget);
  });

  // The bar's material only exists once content is under it: the fade is what
  // hands the pill its glass, so a page that never feeds it would leave the
  // capsule permanently invisible.
  testWidgets('scrolling the post drives the pill fade', (tester) async {
    await _pump(tester, _content(_post()));

    expect(_seenFade, isNotNull);
    expect(_seenFade!.value, 0.0);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -160));
    await tester.pumpAndSettle();

    expect(
      _seenFade!.value,
      greaterThan(0.5),
      reason: 'the post sliding under the bar must surface its glass',
    );
  });

  testWidgets('an embedded body carries no bar of its own', (tester) async {
    // Attention modals and the wide side pane supply their own chrome.
    await _pump(tester, _content(_post(), withHeader: false));

    expect(find.byType(PillSliverAppBar), findsNothing);
  });

  // The glass only exists if content passes under it. When the host reserves
  // the bar's band *outside* the scroll view the pane's rows stop at the
  // capsule and the material has nothing to refract.
  testWidgets('rows scroll under the pill rather than stopping at it', (
    tester,
  ) async {
    await _pump(
      tester,
      _content(_post(), topInset: 44 + kPillAppBarHeight),
    );

    final capsule = tester.getRect(find.byType(PillBarSurface));
    final firstRow = find.textContaining('body text.', findRichText: true);
    expect(firstRow, findsWidgets);
    expect(
      tester.getTopLeft(firstRow.first).dy,
      greaterThan(capsule.bottom),
      reason: 'the post starts below the capsule',
    );

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -260));
    await tester.pumpAndSettle();

    // Something is now behind the capsule: that is what it samples.
    final moved = find.textContaining('body text.', findRichText: true);
    expect(
      tester.getTopLeft(moved.first).dy,
      lessThan(capsule.bottom),
      reason: 'the post must travel under the glass',
    );
  });
}
