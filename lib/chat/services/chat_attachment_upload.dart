import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/chat/pods/chat_room.dart';
import 'package:island/core/config.dart';
import 'package:island/core/services/attachment_upload_manager.dart';
import 'package:island/drive/screens/file_pool.dart';
import 'package:island/e2ee/mls_message_handler.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Attachment uploads of one chat room, shared by the room composer, the
/// thread composer and the message send flow.
///
/// Every upload goes through [AttachmentUploadManager] keyed by the attachment
/// instance, so a file that started uploading when it was picked (auto upload)
/// is joined — not uploaded a second time — when the message is sent, and its
/// progress is handed over to the pending message bubble.
class ChatAttachmentUploads {
  ChatAttachmentUploads(this._ref, this.roomId);

  final Ref _ref;
  final String roomId;

  AttachmentUploadManager get manager =>
      _ref.read(attachmentUploadManagerProvider);

  /// Whether the "auto upload attachments" setting is on.
  bool get autoUploadEnabled =>
      _ref.read(appSettingsProvider).autoUploadAttachments;

  /// The file encryption key of an E2EE room, null otherwise.
  String? get fileEncryptKey {
    final room = _ref.read(chatRoomProvider(roomId)).value;
    return room != null && room.encryptionMode == 3
        ? deriveE2eeFileEncryptKey(roomId)
        : null;
  }

  /// Auto upload only runs once the room is loaded: an E2EE room must be
  /// identified before its files are uploaded, unencrypted.
  bool get canAutoUpload =>
      autoUploadEnabled && _ref.read(chatRoomProvider(roomId)).value != null;

  /// Starts (or joins) the upload of [attachment].
  AttachmentUploadEntry start(
    UniversalFile attachment, {
    String? poolId,
    bool? imageCompressionEnabled,
    int? imageCompressionQuality,
    String? encryptKey,
    void Function(double? progress)? onProgress,
  }) {
    return manager.start(
      attachment,
      onProgress: onProgress,
      upload: (entry) => _upload(
        entry,
        poolId: poolId,
        imageCompressionEnabled: imageCompressionEnabled,
        imageCompressionQuality: imageCompressionQuality,
        encryptKey: encryptKey,
      ),
    );
  }

  /// Cancels the running upload of [attachment] (a no-op when the send flow
  /// already took it over).
  void cancel(UniversalFile attachment) => manager.cancel(attachment);

  /// Cancels uploads of attachments that are no longer in [kept].
  void cancelMissing(Iterable<UniversalFile> kept) =>
      manager.cancelMissing(kept);

  /// Hands the progress of [attachment]'s upload over to [sink].
  void adoptProgress(
    UniversalFile attachment,
    void Function(double? progress) sink,
  ) {
    manager.entryFor(attachment)?.adoptProgress(sink);
  }

  Future<SnCloudFile?> _upload(
    AttachmentUploadEntry entry, {
    String? poolId,
    bool? imageCompressionEnabled,
    int? imageCompressionQuality,
    String? encryptKey,
  }) async {
    final attachment = entry.file;
    final pools = await _ref.read(poolsProvider.future);
    final settings = _ref.read(appSettingsProvider);

    final cloudFile = await _ref
        .read(driveFileUploaderProvider)
        .createCloudFile(
          fileData: attachment,
          poolId: poolId ?? resolveDefaultPoolId(settings, pools),
          encryptPassword: encryptKey ?? fileEncryptKey,
          usage: 'chat_message',
          mode: attachment.type == UniversalFileType.file
              ? FileUploadMode.generic
              : FileUploadMode.mediaSafe,
          imageCompressionEnabled: imageCompressionEnabled,
          imageCompressionQuality: imageCompressionQuality,
          cancelToken: entry.cancelToken,
          onProgress: (progress, _) => entry.report(progress),
        )
        .future;

    if (cloudFile == null) {
      throw ArgumentError('Failed to upload the file...');
    }
    return cloudFile;
  }
}

final chatAttachmentUploadsProvider =
    Provider.family<ChatAttachmentUploads, String>(
      (ref, roomId) => ChatAttachmentUploads(ref, roomId),
    );
