import 'package:material_ui/material_ui.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// A row of square attachment previews, three at most, with a `+N` badge
/// standing in for the rest.
///
/// Images render as thumbnails; every other file shows its file-type icon and
/// name, so a preview can say "there is a PDF here" without opening it.
class PostAttachmentThumbnails extends StatelessWidget {
  /// How many thumbnails the row draws before it summarises the rest.
  static const int maxVisible = 3;

  final List<IDisplayableCloudFile> attachments;

  const PostAttachmentThumbnails({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    final visible = attachments.take(maxVisible).toList();
    final remainingCount = attachments.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        for (final attachment in visible) _buildThumbnail(context, attachment),
        if (remainingCount > 0) _buildRemainingCountBadge(context, remainingCount),
      ],
    );
  }

  Widget _buildThumbnail(
    BuildContext context,
    IDisplayableCloudFile attachment,
  ) {
    final isImage = attachment.mimeType.startsWith('image');
    final isVideo = attachment.mimeType.startsWith('video');
    final isAudio = attachment.mimeType.startsWith('audio');

    Widget content;
    if (isImage) {
      // Show actual image thumbnail using CloudFileWidget which handles auth properly
      content = ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CloudFileWidget(
          item: attachment,
          fit: BoxFit.cover,
          noBlurhash: true,
        ),
      );
    } else if (isVideo) {
      content = _buildFileTypeIcon(context, attachment, icon: Symbols.videocam);
    } else if (isAudio) {
      content = _buildFileTypeIcon(
        context,
        attachment,
        icon: Symbols.audiotrack,
      );
    } else {
      content = _buildFileTypeIcon(context, attachment);
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
      child: content,
    );
  }

  /// Builds an icon-based representation for non-image files
  Widget _buildFileTypeIcon(
    BuildContext context,
    IDisplayableCloudFile attachment, {
    IconData? icon,
  }) {
    final fileIcon = icon ?? _getFileIcon(attachment.mimeType);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          fileIcon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        if (attachment.name.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              attachment.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }

  /// Gets appropriate icon for MIME type
  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Symbols.insert_drive_file;
    if (mimeType.startsWith('image/')) return Symbols.image;
    if (mimeType.startsWith('video/')) return Symbols.videocam;
    if (mimeType.startsWith('audio/')) return Symbols.audiotrack;
    if (mimeType.startsWith('text/')) return Symbols.description;
    if (mimeType.contains('pdf')) return Symbols.picture_as_pdf;
    if (mimeType.contains('zip') || mimeType.contains('compressed')) {
      return Symbols.folder_zip;
    }
    return Symbols.attach_file;
  }

  /// Builds a badge showing remaining attachment count
  Widget _buildRemainingCountBadge(BuildContext context, int count) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
      child: Center(
        child: Text(
          '+$count',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
