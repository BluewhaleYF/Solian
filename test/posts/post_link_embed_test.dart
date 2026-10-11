import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/services/deeplink_service.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:island/posts/widgets/post_link_embed.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:markdown/markdown.dart' as markdown;
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const _id = '0198f0c2-1d4e-7a3b-9c6d-2f5e8a1b4c7d';
const _webLink = 'https://solian.app/posts/$_id';
const _schemeLink = 'solian://posts/$_id';

/// The post the link points at, as the server would serve it.
SnPost _linkedPost({String? content}) => SnPost.fromJson({
  'id': _id,
  'title': 'A Quiet Wednesday',
  'content':
      content ??
      'the body of the linked post, which the preview reduces to prose',
  'content_type': 0,
  'published_at': DateTime.now().toIso8601String(),
  'replies_count': 3,
  'publisher': {
    'id': 'pub-1',
    'type': 0,
    'name': 'the_author',
    'nick': 'The Author',
  },
});

/// A signed-out viewer: the picture widget resolves its server URL, and that
/// needs preferences and an account state, but nothing here needs a session.
class _UserInfoGuest extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

late SharedPreferences _prefs;

/// Renders [child] in the app's real localization, theme and provider scope,
/// with the post the link points at stubbed out; [hasPost] is false when it
/// cannot be read.
Future<void> _pump(
  WidgetTester tester, {
  required Widget child,
  bool hasPost = true,
  String? linkedContent,
}) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(
      EasyLocalization(
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
                postProvider(_id).overrideWith(
                  (ref) async => hasPost ? _linkedPost(content: linkedContent) : null,
                ),
              ],
              child: mui.Material(
                child: SingleChildScrollView(child: child),
              ),
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

Future<void> _pumpMarkdown(
  WidgetTester tester, {
  required String content,
  bool hasPost = true,
  bool embedPostLinks = true,
  String? linkedContent,
}) => _pump(
  tester,
  hasPost: hasPost,
  linkedContent: linkedContent,
  child: MarkdownTextContent(
    content: content,
    embedPostLinks: embedPostLinks,
  ),
);

/// Renders [content] as a post body would, through the same widget the feed and
/// the detail screen use. The linking post is not the linked one, so the card
/// it draws is unmistakable.
Future<void> _pumpBody(WidgetTester tester, {required String content}) => _pump(
  tester,
  child: PostBody(
    item: _linkedPost().copyWith(
      id: 'outer-post',
      title: 'The linking post',
      content: content,
    ),
    isFullPost: true,
  ),
);

/// The attributes of every post-embed block [source] parses into, in order,
/// wherever it sits — a link that is a whole list item or quote embeds there.
List<Map<String, String>> _embeds(String source) {
  final embeds = <Map<String, String>>[];

  void walk(List<markdown.Node> nodes) {
    for (final node in nodes) {
      if (node is! markdown.Element) continue;
      if (node.tag == postLinkEmbedTag) embeds.add(node.attributes);
      walk(node.children ?? const []);
    }
  }

  walk(
    markdown.Document(
      blockSyntaxes: const [PostLinkEmbedSyntax()],
      extensionSet: markdown.ExtensionSet.gitHubFlavored,
    ).parse(source),
  );
  return embeds;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
    await EasyLocalization.ensureInitialized();
  });

  group('parsePostLinkId', () {
    test('reads the id out of every post link shape', () {
      for (final value in [
        _webLink,
        '$_webLink/',
        'http://solian.app/posts/$_id',
        'https://www.solian.app/posts/$_id',
        _schemeLink,
        'solian:///posts/$_id',
      ]) {
        expect(parsePostLinkId(Uri.parse(value)), _id, reason: value);
      }
    });

    test('rejects links that are not posts', () {
      for (final value in [
        'https://solian.app/posts',
        'https://solian.app/chat/someone/room',
        'solian://chat/someone/room',
        'https://example.com/posts/$_id',
        'https://api.solian.app/posts/$_id',
      ]) {
        expect(parsePostLinkId(Uri.parse(value)), isNull, reason: value);
      }
    });

    test('reads whatever follows /posts, leaving vetting to the caller', () {
      // Taps follow the link the way the app always has, and only the embed
      // asks for a UUID before it fetches.
      expect(
        parsePostLinkId(Uri.parse('https://solian.app/posts/categories')),
        'categories',
      );
    });
  });

  group('PostLinkEmbedSyntax', () {
    test('embeds a bare post link standing on its own', () {
      for (final link in [_webLink, _schemeLink]) {
        expect(_embeds(link), [
          {'post-id': _id, 'href': link},
        ], reason: link);

        expect(_embeds('before\n\n$link\n\nafter'), [
          {'post-id': _id, 'href': link},
        ], reason: link);
      }
    });

    test('embeds a link whose label repeats its URL', () {
      expect(_embeds('[$_webLink]($_webLink)'), [
        {'post-id': _id, 'href': _webLink},
      ]);
    });

    test('keeps a labelled link and a link sharing a sentence', () {
      // The label carries the meaning the card would drop.
      expect(_embeds('[看看这篇]($_webLink)'), isEmpty);
      // A URL sharing a paragraph is part of a sentence, not a post on its own.
      expect(_embeds('look at $_webLink'), isEmpty);
      expect(_embeds('look at this\n$_webLink'), isEmpty);
      expect(_embeds('$_webLink\nlook at this'), isEmpty);
      // Four spaces of indentation is a code block, not a paragraph.
      expect(_embeds('    $_webLink'), isEmpty);
    });

    test('embeds a link that is all of a list item or a quote', () {
      // Nested blocks parse their own lines, where the link is once more the
      // whole paragraph.
      expect(_embeds('- $_webLink').length, 1);
      expect(_embeds('> $_webLink').length, 1);
    });

    test('keeps links to things that are not posts', () {
      expect(_embeds('https://solian.app/posts/categories'), isEmpty);
      expect(_embeds('https://solian.app/chat/someone/room'), isEmpty);
      expect(_embeds('https://example.com/posts/$_id'), isEmpty);
      // A post id is a UUID; anything else is not a post this can fetch.
      expect(_embeds('https://solian.app/posts/not-a-uuid'), isEmpty);
    });
  });

  group('PostLinkEmbed', () {
    testWidgets('draws the linked post, not the link', (tester) async {
      await _pumpMarkdown(
        tester,
        content: 'read this\n\n$_webLink\n\n(and that)',
      );

      expect(find.text('A Quiet Wednesday'), findsOneWidget);
      expect(find.textContaining('the_author'), findsOneWidget);
      expect(
        find.textContaining(
          'the body of the linked post',
          findRichText: true,
        ),
        findsOneWidget,
      );
      expect(find.textContaining(_webLink, findRichText: true), findsNothing);
    });

    testWidgets('draws the link itself when the post cannot be read', (
      tester,
    ) async {
      await _pumpMarkdown(tester, content: _webLink, hasPost: false);

      expect(find.text(_webLink), findsOneWidget);
      expect(find.text('A Quiet Wednesday'), findsNothing);
    });

    testWidgets('leaves post links alone on surfaces that opt out', (
      tester,
    ) async {
      await _pumpMarkdown(tester, content: _webLink, embedPostLinks: false);

      expect(find.text('A Quiet Wednesday'), findsNothing);
      expect(find.textContaining(_webLink, findRichText: true), findsOneWidget);
    });

    testWidgets('a post body draws the preview for a link it is only', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(280, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await _pumpBody(tester, content: _webLink);

      expect(find.text('A Quiet Wednesday'), findsOneWidget);
      // Bubble width: the card has to fit what chat gives a message.
      expect(
        tester.getSize(find.byType(PostLinkEmbed)).width,
        lessThanOrEqualTo(280),
      );
    });

    testWidgets('clips a body too long to preview', (tester) async {
      await _pumpMarkdown(
        tester,
        content: _webLink,
        linkedContent: 'a long body ' * 100,
      );

      final excerpt = tester
          .widgetList<Text>(find.textContaining('…'))
          .map((widget) => widget.data)
          .whereType<String>()
          .single;
      expect(excerpt, startsWith('a long body a long body'));
      expect(excerpt.endsWith('…'), isTrue);
      expect(excerpt.length, lessThanOrEqualTo(PostLinkEmbed.maxExcerptLength));
    });
  });
}
