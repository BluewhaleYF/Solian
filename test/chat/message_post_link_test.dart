import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/chat/widgets/message_content.dart';
import 'package:island/core/config.dart';
import 'package:island/posts/screens/post_detail.dart';
import 'package:island/posts/widgets/post_link_embed.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

const _postId = '0198f0c2-1d4e-7a3b-9c6d-2f5e8a1b4c7d';
const _postLink = 'https://solian.app/posts/$_postId';

/// The widest a message bubble gets, from `MessageContent`'s own layout: the
/// preview has to fit what chat gives a message.
const double _bubbleWidth = 280;

SnPost _linkedPost() => SnPost.fromJson({
  'id': _postId,
  'title': 'A Quiet Wednesday',
  'content': 'the body of the linked post',
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
  'publisher': {
    'id': 'pub-1',
    'type': 0,
    'name': 'the_author',
    'nick': 'The Author',
  },
});

SnChatMember _member() {
  final now = DateTime.utc(2026);
  final profile = SnAccountProfile(
    id: 'profile-1',
    experience: 0,
    level: 1,
    levelingProgress: 0,
    picture: null,
    background: null,
    verification: null,
    createdAt: now,
    updatedAt: now,
    deletedAt: null,
  );
  final account = SnAccount(
    id: 'account-1',
    name: 'test-user',
    nick: 'Test User',
    language: 'en',
    isSuperuser: false,
    automatedId: null,
    profile: profile,
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
    id: 'member-room-1',
    chatRoomId: 'room-1',
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

SnChatMessage _message({String? content}) {
  final now = DateTime.utc(2026);
  final sender = _member();
  return SnChatMessage(
    createdAt: now,
    updatedAt: now,
    id: 'message-1',
    content: content,
    senderId: sender.id,
    sender: sender,
    chatRoomId: 'room-1',
  );
}

/// A signed-out viewer: the picture widget resolves its server URL, and that
/// needs preferences and an account state, but nothing here needs a session.
class _UserInfoGuest extends UserInfoNotifier {
  @override
  Future<SnAccount?> build() async => null;
}

/// Pumps [item] as chat would, with the post the link points at stubbed out.
Future<void> _pumpMessage(WidgetTester tester, SnChatMessage item) async {
  final preferences = await SharedPreferences.getInstance();
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
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            ),
            home: ProviderScope(
              overrides: [
                sharedPreferencesProvider.overrideWithValue(preferences),
                userInfoProvider.overrideWith(_UserInfoGuest.new),
                postProvider(
                  _postId,
                ).overrideWith((ref) async => _linkedPost()),
              ],
              child: Scaffold(
                body: Align(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _bubbleWidth),
                    child: MessageContent(item: item),
                  ),
                ),
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('a message that is only a post link carries the post', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpMessage(tester, _message(content: _postLink));

    expect(find.text('A Quiet Wednesday'), findsOneWidget);
    expect(
      tester.getSize(find.byType(PostLinkEmbed)).width,
      lessThanOrEqualTo(_bubbleWidth),
    );
    expect(find.textContaining(_postLink, findRichText: true), findsNothing);
  });
}
