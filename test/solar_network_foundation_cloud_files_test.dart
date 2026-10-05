import 'package:flutter_test/flutter_test.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';

void main() {
  group('cloudFileUrl', () {
    test('adds a workspace query parameter', () {
      expect(
        cloudFileUrl(
          serverUrl: 'https://api.example.com',
          id: 'file-1',
          workspaceId: 'workspace-1',
        ),
        'https://api.example.com/drive/files/file-1?workspace_id=workspace-1',
      );
    });

    test('preserves existing storage URL query parameters', () {
      expect(
        cloudFileUrl(
          serverUrl: 'https://api.example.com',
          id: 'file-1',
          storageUrl: 'https://storage.example.com/file-1?signature=abc',
          original: true,
          workspaceId: 'workspace-1',
        ),
        'https://storage.example.com/file-1?signature=abc&original=true&workspace_id=workspace-1',
      );
    });
  });

  group('cloudFileReferenceUrl', () {
    test('serves external references from their storage url', () {
      // Fediverse avatars arrive as a file reference with an empty id and the
      // image hosted on the remote instance.
      expect(
        cloudFileReferenceUrl(
          serverUrl: 'https://api.example.com',
          id: '',
          storageUrl: 'https://files.mastodon.social/a.png',
        ),
        'https://files.mastodon.social/a.png',
      );
      expect(
        cloudFileReferenceUrl(
          serverUrl: 'https://api.example.com',
          storageUrl: 'https://files.mastodon.social/a.png',
        ),
        'https://files.mastodon.social/a.png',
      );
    });

    test('serves local cloud files from the drive endpoint', () {
      expect(
        cloudFileReferenceUrl(
          serverUrl: 'https://api.example.com',
          id: 'file-1',
        ),
        'https://api.example.com/drive/files/file-1',
      );
    });

    test('keeps the workspace parameter for external references', () {
      expect(
        cloudFileReferenceUrl(
          serverUrl: 'https://api.example.com',
          id: '',
          storageUrl: 'https://storage.example.com/a.png',
          workspaceId: 'workspace-1',
        ),
        'https://storage.example.com/a.png?workspace_id=workspace-1',
      );
    });

    test('returns null when the reference has nothing to load', () {
      expect(
        cloudFileReferenceUrl(
          serverUrl: 'https://api.example.com',
          id: '',
        ),
        isNull,
      );
      expect(
        cloudFileReferenceUrl(serverUrl: 'https://api.example.com'),
        isNull,
      );
    });
  });
}
