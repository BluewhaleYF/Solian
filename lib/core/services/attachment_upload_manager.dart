import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// A single attachment upload that is currently in flight.
///
/// Entries are created by [AttachmentUploadManager.start] and live until the
/// upload settles (or is cancelled). Their [completer] can be awaited by any
/// number of callers, which is what lets the send/publish flow take over an
/// upload that was started automatically when the file was picked instead of
/// uploading the same file a second time.
class AttachmentUploadEntry {
  AttachmentUploadEntry(this.file) : cancelToken = CancelToken();

  /// The attachment being uploaded. Used as the registry key, so equal
  /// attachments (same data, type and link flag) share one upload.
  final UniversalFile file;

  /// Cancels the upload. In-flight requests using it are aborted by dio;
  /// steps that cannot be interrupted stop at their next checkpoint.
  final CancelToken cancelToken;

  /// Completes with the uploaded cloud file, or with an error when the upload
  /// failed or was cancelled.
  final Completer<SnCloudFile?> completer = Completer<SnCloudFile?>();

  /// Progress sink of whichever flow currently consumes this upload: the
  /// composer while the user is editing, and the message/post send process
  /// after the progress is handed over. Always report through this field —
  /// see [adoptProgress].
  void Function(double? progress)? onProgress;

  bool get isCancelled => cancelToken.isCancelled;

  bool _adopted = false;

  /// True once a send/publish flow took this upload over; that flow then owns
  /// the progress display and the error reporting for it.
  bool get isAdopted => _adopted;

  /// Hands the progress reporting over to [sink].
  ///
  /// Called by the send/publish flow so the progress bar moves from the
  /// composer's attachment list to the message or post being sent.
  void adoptProgress(void Function(double? progress)? sink) {
    _adopted = true;
    onProgress = sink;
  }

  void cancel() {
    if (cancelToken.isCancelled) return;
    cancelToken.cancel('attachment upload cancelled');
    // Unblock everyone waiting on this upload right away; the transfer itself
    // stops at the uploader's next checkpoint (or when dio aborts it).
    if (!completer.isCompleted) {
      completer.completeError(uploadCancelledError());
    }
  }

  /// Reports progress through the current sink, ignoring cancelled uploads.
  void report(double? progress) {
    if (isCancelled) return;
    onProgress?.call(progress);
  }
}

/// Tracks the attachment uploads that are running right now.
///
/// Two behaviours depend on it:
///  * auto upload — attachments start uploading as soon as they are picked
///    (gated by the `autoUploadAttachments` setting), and
///  * hand-off — publishing a post or sending a message joins the uploads that
///    are already running and adopts their progress, instead of starting a
///    duplicate upload for the same file.
class AttachmentUploadManager {
  final Map<UniversalFile, AttachmentUploadEntry> _entries = {};

  /// The running upload for [file], or null when there is none.
  AttachmentUploadEntry? entryFor(UniversalFile file) => _entries[file];

  bool get hasActiveUploads => _entries.isNotEmpty;

  /// Returns the running entry for [file], starting [upload] when none exists.
  ///
  /// [upload] is called at most once per attachment and receives the entry so
  /// it can read [AttachmentUploadEntry.cancelToken] and report progress
  /// through [AttachmentUploadEntry.report].
  AttachmentUploadEntry start(
    UniversalFile file, {
    required Future<SnCloudFile?> Function(AttachmentUploadEntry entry) upload,
    void Function(double? progress)? onProgress,
  }) {
    final existing = _entries[file];
    if (existing != null) return existing;

    final entry = AttachmentUploadEntry(file)..onProgress = onProgress;
    _entries[file] = entry;

    // A cancelled or failed upload is not an application error: callers that
    // never await the entry (the auto upload path) must not leak the error.
    unawaited(entry.completer.future.catchError((Object _) => null));

    unawaited(() async {
      try {
        final result = await upload(entry);
        if (!entry.completer.isCompleted) entry.completer.complete(result);
      } catch (error, stackTrace) {
        if (!entry.completer.isCompleted) {
          entry.completer.completeError(error, stackTrace);
        }
      } finally {
        if (identical(_entries[file], entry)) _entries.remove(file);
      }
    }());
    return entry;
  }

  /// Cancels the running upload for [file], if any.
  ///
  /// The entry is dropped immediately so the caller can start a fresh upload
  /// (for example when the user sends the file after cancelling). Uploads that
  /// a send/publish flow already took over are owned by that flow and are left
  /// alone.
  void cancel(UniversalFile file) {
    final entry = _entries[file];
    if (entry == null || entry.isAdopted) return;
    _entries.remove(file);
    entry.cancel();
  }

  /// Cancels running uploads for every attachment that is not in [kept].
  void cancelMissing(Iterable<UniversalFile> kept) {
    final keep = kept.toSet();
    for (final file in _entries.keys.toList()) {
      if (keep.contains(file)) continue;
      cancel(file);
    }
  }
}

final attachmentUploadManagerProvider = Provider<AttachmentUploadManager>(
  (ref) => AttachmentUploadManager(),
);
