import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/services/attachment_upload_manager.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

UniversalFile _file(String name) =>
    UniversalFile(data: 'bytes-of-$name', type: UniversalFileType.file);

SnCloudFile _cloudFile(String id) => SnCloudFile.fromJson({
  'id': id,
  'name': id,
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

void main() {
  test('starts one upload per attachment and joins the running one', () async {
    final manager = AttachmentUploadManager();
    final attachment = _file('a');
    var uploads = 0;

    final first = manager.start(
      attachment,
      upload: (entry) async {
        uploads++;
        await Future<void>.delayed(Duration.zero);
        return _cloudFile('a');
      },
    );
    final second = manager.start(
      attachment,
      upload: (entry) async {
        uploads++;
        return _cloudFile('ignored');
      },
    );

    expect(identical(first, second), isTrue);
    expect(uploads, 1);
    await expectLater(second.completer.future, completion(isNotNull));
    // The settled upload is forgotten so the file can be uploaded again.
    expect(manager.entryFor(attachment), isNull);
  });

  test('progress is handed over to the flow that adopts it', () async {
    final manager = AttachmentUploadManager();
    final attachment = _file('b');
    final composerProgress = <double?>[];
    final sendProgress = <double?>[];
    final complete = Completer<SnCloudFile?>();

    final entry = manager.start(
      attachment,
      onProgress: composerProgress.add,
      upload: (entry) async {
        entry.report(0.25);
        return complete.future;
      },
    );

    // The send process joins and takes the progress over.
    final sendEntry = manager.entryFor(attachment)!;
    expect(identical(sendEntry, entry), isTrue);
    sendEntry.adoptProgress(sendProgress.add);
    expect(sendEntry.isAdopted, isTrue);

    entry.report(0.5);
    expect(composerProgress, [0.25]);
    expect(sendProgress, [0.5]);

    complete.complete(_cloudFile('b'));
    await entry.completer.future;
  });

  test('cancelling aborts the upload and allows a fresh one', () async {
    final manager = AttachmentUploadManager();
    final attachment = _file('c');
    final token = Completer<void>();

    final entry = manager.start(
      attachment,
      upload: (entry) async {
        await token.future;
        return _cloudFile('c');
      },
    );

    manager.cancel(attachment);
    expect(entry.isCancelled, isTrue);
    expect(manager.entryFor(attachment), isNull);
    await expectLater(entry.completer.future, throwsA(anything));

    // A cancelled attachment can be uploaded again (for example by the
    // publish flow after the user cancelled).
    final restarted = manager.start(
      attachment,
      upload: (entry) async => _cloudFile('c2'),
    );
    expect(restarted.isCancelled, isFalse);
    await expectLater(restarted.completer.future, completion(isNotNull));
    token.complete();
  });

  test('uploads taken over by a send survive composer cancellation', () async {
    final manager = AttachmentUploadManager();
    final kept = _file('kept');
    final removed = _file('removed');
    final keptUpload = Completer<void>();
    final removedUpload = Completer<void>();

    final keptEntry = manager.start(
      kept,
      upload: (entry) async {
        await keptUpload.future;
        return _cloudFile('kept');
      },
    );
    final removedEntry = manager.start(
      removed,
      upload: (entry) async {
        await removedUpload.future;
        return _cloudFile('removed');
      },
    );
    keptEntry.adoptProgress((_) {});

    // Both attachments are still in the composer: nothing is cancelled.
    manager.cancelMissing([kept, removed]);
    expect(keptEntry.isCancelled, isFalse);
    expect(removedEntry.isCancelled, isFalse);

    // The composer drops `removed`: only its upload stops.
    manager.cancelMissing([kept]);
    expect(manager.entryFor(kept), isNotNull);
    expect(removedEntry.isCancelled, isTrue);
    await expectLater(removedEntry.completer.future, throwsA(anything));

    // The send's own upload is not touched when the composer clears.
    manager.cancel(kept);
    expect(keptEntry.isCancelled, isFalse);

    keptUpload.complete();
    await expectLater(keptEntry.completer.future, completion(isNotNull));
    removedUpload.complete();
  });

  test('a failed upload surfaces through the entry only', () async {
    final manager = AttachmentUploadManager();
    final attachment = _file('d');

    final entry = manager.start(
      attachment,
      upload: (entry) async => throw StateError('boom'),
    );

    await expectLater(entry.completer.future, throwsA(isA<StateError>()));
    // The error was delivered to the caller and the entry was released.
    expect(manager.entryFor(attachment), isNull);
  });
}
