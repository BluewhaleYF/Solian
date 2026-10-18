import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/core/widgets/content/cloud_file_collection.dart';
import 'package:island/creators/screens/publishers_form.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_shared.dart';
import 'package:material_ui/material_ui.dart' as mui;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// A post whose only payload is one non-media attachment, so the body renders
/// it as a static file card instead of reaching for the network.
SnPost _postWithAttachment() {
  return SnPost.fromJson({
    'id': 'post-with-attachment',
    'type': 0,
    'content': 'caption',
    'chained_posts': const [],
    'publisher': {'id': 'publisher-1', 'name': 'alice', 'nick': 'Alice'},
    'attachments': [
      {
        'id': 'file-1',
        'name': 'report.pdf',
        'mime_type': 'application/pdf',
        'size': 2048,
      },
    ],
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  });
}

SnPost _postWithTwoImages() {
  return SnPost.fromJson({
    'id': 'post-with-two-images',
    'type': 0,
    'content': 'caption',
    'chained_posts': const [],
    'publisher': {'id': 'publisher-1', 'name': 'alice', 'nick': 'Alice'},
    'attachments': [
      {
        'id': 'img-1',
        'name': 'a.png',
        'mime_type': 'image/png',
        'width': 400,
        'height': 300,
      },
      {
        'id': 'img-2',
        'name': 'b.png',
        'mime_type': 'image/png',
        'width': 400,
        'height': 300,
      },
    ],
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-01T00:00:00Z',
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpPostItem(WidgetTester tester, Widget item) async {
    final prefs = await SharedPreferences.getInstance();
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
              home: mui.Material(
                child: ProviderScope(
                  overrides: [
                    sharedPreferencesProvider.overrideWithValue(prefs),
                    publishersManagedProvider.overrideWith(
                      (ref) async => <SnPublisher>[],
                    ),
                    apiClientProvider.overrideWith((ref) => Dio()),
                  ],
                  child: mui.SingleChildScrollView(child: item),
                ),
              ),
              localizationsDelegates: context.localizationDelegates,
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
  }

  testWidgets('renders the attachment of a post by default', (tester) async {
    await pumpPostItem(
      tester,
      PostItem(item: _postWithAttachment(), isTranslatable: false),
    );

    expect(find.text('caption', findRichText: true), findsOneWidget);
    expect(find.text('report.pdf'), findsOneWidget);
  });

  testWidgets('hideAttachments suppresses the post item attachment block', (
    tester,
  ) async {
    await pumpPostItem(
      tester,
      PostItem(
        item: _postWithAttachment(),
        isTranslatable: false,
        hideAttachments: true,
      ),
    );

    // The post itself still renders; only its attachment block is dropped, so
    // layouts that draw the media elsewhere do not repeat it.
    expect(find.text('caption', findRichText: true), findsOneWidget);
    expect(find.text('report.pdf'), findsNothing);
  });

  testWidgets('attachments are inset and rounded inside the post', (
    tester,
  ) async {
    await pumpPostItem(
      tester,
      PostItem(
        item: _postWithAttachment(),
        isTranslatable: false,
        padding: const EdgeInsets.all(12),
      ),
    );

    final attachment = tester.widget<FullBleedSingleAttachment>(
      find.byType(FullBleedSingleAttachment),
    );
    final body = tester.widget<PostBody>(find.byType(PostBody));
    expect(body.renderingPadding, const EdgeInsets.all(12));
    expect(attachment.borderRadius, 16);
    expect(attachment.padding, const EdgeInsets.fromLTRB(12, 8, 12, 8));
  });

  testWidgets('multi-attachment lists stay contained instead of bleeding', (
    tester,
  ) async {
    await pumpPostItem(
      tester,
      PostItem(
        item: _postWithTwoImages(),
        isTranslatable: false,
        padding: const EdgeInsets.all(12),
      ),
    );

    final list = tester.widget<CloudFileList>(find.byType(CloudFileList));
    expect(list.isFullBleed, isFalse);
    expect(list.borderRadius, 16);
    expect(
      list.itemGap,
      kAttachmentCarouselGap,
      reason: 'the gap is declared explicitly, not derived from the gutter',
    );
  });

  testWidgets('a contained carousel gets the whole body gutter, not half', (
    tester,
  ) async {
    await pumpPostItem(
      tester,
      PostItem(
        item: _postWithTwoImages(),
        isTranslatable: false,
        padding: const EdgeInsets.all(12),
      ),
    );

    final list = tester.widget<CloudFileList>(find.byType(CloudFileList));
    // Halving this inset was how the gap used to be kept at 8; it also moved
    // the leading image off the body text column. CloudFileList now splits the
    // gutter itself, so the post hands over the inset its other rows use.
    expect(list.padding, const EdgeInsets.fromLTRB(12, 8, 12, 8));
  });

  testWidgets('an edge-to-edge host keeps its own gutter split', (
    tester,
  ) async {
    await pumpPostItem(
      tester,
      PostItem(
        item: _postWithTwoImages(),
        isTranslatable: false,
        containAttachments: false,
        padding: const EdgeInsets.all(12),
      ),
    );

    final list = tester.widget<CloudFileList>(find.byType(CloudFileList));
    expect(list.isFullBleed, isTrue);
    expect(list.padding!.horizontal, 0);
    expect(
      list.itemGap,
      isNull,
      reason: 'the bleeding strip carries its gap on the cards',
    );
  });
}
