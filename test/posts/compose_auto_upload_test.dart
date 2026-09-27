import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/services/attachment_upload_manager.dart';
import 'package:island/drive/screens/file_pool.dart';
import 'package:island/posts/widgets/compose/compose_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Records every upload request and lets the test decide when it settles.
/// Cancelling the passed token aborts it, like the real uploader does.
class FakeUploader extends FileUploader {
  FakeUploader(super.ref);

  final List<UniversalFile> uploadedFiles = [];
  final List<CancelToken> tokens = [];
  final List<Completer<SnCloudFile?>> completers = [];

  @override
  Completer<SnCloudFile?> createCloudFile({
    required UniversalFile fileData,
    String? poolId,
    String? parentId,
    String? path,
    String? workspaceId,
    String? encryptPassword,
    FileUploadMode? mode,
    String? usage,
    String? applicationType,
    bool? imageCompressionEnabled,
    int? imageCompressionQuality,
    Function(double? progress, Duration estimate)? onProgress,
    CancelToken? cancelToken,
  }) {
    final completer = Completer<SnCloudFile?>();
    uploadedFiles.add(fileData);
    tokens.add(cancelToken ?? CancelToken());
    completers.add(completer);

    onProgress?.call(null, Duration.zero);
    cancelToken?.whenCancel.then((_) {
      if (!completer.isCompleted) {
        completer.completeError(uploadCancelledError());
      }
    });
    return completer;
  }

  void finishUpload(int index) {
    completers[index].complete(_cloudFile('cloud-${index + 1}'));
  }

  void Function(double? progress, Duration estimate)? lastProgress;
}

SnCloudFile _cloudFile(String id) => SnCloudFile.fromJson({
  'id': id,
  'name': '$id.bin',
  'account_id': 'account-1',
  'indexed': false,
  'is_folder': false,
  'is_marked_recycle': false,
  'object': null,
  'object_id': null,
  'parent_id': null,
  'resource_identifier': id,
  'storage_id': null,
  'storage_url': null,
  'mime_type': 'application/octet-stream',
  'sensitive_marks': <int>[],
  'file_meta': <String, dynamic>{},
  'user_meta': <String, dynamic>{},
  'children': <dynamic>[],
  'updated_at': '2026-01-01T00:00:00Z',
  'created_at': '2026-01-01T00:00:00Z',
  'deleted_at': null,
});

UniversalFile _localFile(String name) => UniversalFile(
  displayName: name,
  data: Uint8List.fromList(List<int>.filled(4, 1)),
  type: UniversalFileType.file,
);

late WidgetRef capturedRef;
late FakeUploader uploader;

class _RefCapture extends ConsumerWidget {
  const _RefCapture();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    capturedRef = ref;
    return const SizedBox.shrink();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpHost(
    WidgetTester tester, {
    Map<String, Object> prefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(prefs);
    final sharedPreferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en', 'US')],
        path: 'assets/i18n',
        saveLocale: false,
        child: ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            driveFileUploaderProvider.overrideWith(
              (ref) => uploader = FakeUploader(ref),
            ),
            poolsProvider.overrideWith((ref) async => <SnFilePool>[]),
          ],
          child: const MaterialApp(home: _RefCapture()),
        ),
      ),
    );
    await tester.pump();
    capturedRef.read(driveFileUploaderProvider);
  }

  testWidgets('auto upload starts on pick and publish joins it', (
    tester,
  ) async {
    await pumpHost(tester);

    final state = ComposeLogic.createState();
    state.currentPublisher.value = SnPublisher.fromJson({
      'id': 'publisher-1',
      'type': 0,
      'name': 'tester',
      'nick': 'Tester',
      'created_at': '2026-01-01T00:00:00Z',
      'updated_at': '2026-01-01T00:00:00Z',
    });
    state.attachments.value = [_localFile('pick.bin')];

    await tester.runAsync(() async {
      ComposeLogic.autoUploadAttachments(capturedRef, state);
      // The upload starts without the user asking for it (the progress entry
      // is written synchronously, the request follows the pool lookup).
      expect(state.attachmentProgress.value.containsKey(0), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(uploader.uploadedFiles, hasLength(1));

      // Publishing joins the running upload instead of starting a second one.
      final publishUpload = ComposeLogic.uploadAttachment(
        capturedRef,
        state,
        0,
      );
      expect(uploader.uploadedFiles, hasLength(1));

      uploader.finishUpload(0);
      await publishUpload;
      await Future<void>.delayed(Duration.zero);
    });

    final attached = state.attachments.value.single;
    expect(attached.isOnCloud, isTrue);
    expect(attached.data.id, 'cloud-1');
    expect(state.attachmentProgress.value, isEmpty);
    expect(
      capturedRef.read(attachmentUploadManagerProvider).hasActiveUploads,
      isFalse,
    );
  });

  testWidgets('cancelling an upload stops it and keeps the file attached', (
    tester,
  ) async {
    await pumpHost(tester);

    final state = ComposeLogic.createState();
    state.attachments.value = [_localFile('cancel.bin')];

    await tester.runAsync(() async {
      ComposeLogic.autoUploadAttachments(capturedRef, state);
      await Future<void>.delayed(Duration.zero);
      expect(uploader.uploadedFiles, hasLength(1));

      ComposeLogic.cancelAttachmentUpload(capturedRef, state, 0);
      expect(uploader.tokens.single.isCancelled, isTrue);
      await Future<void>.delayed(Duration.zero);
    });

    // The attachment is still there, still local, and not uploading anymore.
    expect(state.attachments.value.single.isOnCloud, isFalse);
    expect(state.attachmentProgress.value, isEmpty);
    expect(
      capturedRef.read(attachmentUploadManagerProvider).hasActiveUploads,
      isFalse,
    );

    // Cancelling never surfaces an error alert; the composer is still usable
    // and a later publish uploads the file again (a fresh request).
    await tester.runAsync(() async {
      final upload = ComposeLogic.uploadAttachment(capturedRef, state, 0);
      await Future<void>.delayed(Duration.zero);
      expect(uploader.uploadedFiles, hasLength(2));
      uploader.finishUpload(1);
      await upload;
      await Future<void>.delayed(Duration.zero);
    });
    expect(state.attachments.value.single.isOnCloud, isTrue);
  });

  testWidgets('auto upload stays off when the setting is disabled', (
    tester,
  ) async {
    await pumpHost(tester, prefs: {kAppAutoUploadAttachments: false});

    final state = ComposeLogic.createState();
    state.attachments.value = [_localFile('manual.bin')];
    ComposeLogic.autoUploadAttachments(capturedRef, state);
    await tester.pump();

    expect(uploader.uploadedFiles, isEmpty);
    expect(state.attachmentProgress.value, isEmpty);
  });
}
