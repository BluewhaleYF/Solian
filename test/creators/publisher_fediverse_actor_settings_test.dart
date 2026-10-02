import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Captures the outgoing request so the test can assert the exact wire
/// contract of the publisher actor settings endpoint.
class _CapturingAdapter implements HttpClientAdapter {
  RequestOptions? lastRequest;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? _,
    Future<void>? _,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      jsonEncode({
        'enabled': true,
        'follower_count': 0,
        'actor_uri': 'https://sphere.test/activitypub/actors/alice',
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

/// Keys the fediverse actor settings UI reads. Every locale must define them,
/// otherwise the sheet renders a raw key instead of a label.
const _actorSettingsKeys = <String>[
  'publisherFediverseSettings',
  'publisherFediverseActorType',
  'publisherFediverseActorTypeHint',
  'publisherFediverseActorTypePerson',
  'publisherFediverseActorTypeService',
  'publisherFediverseActorTypeGroup',
  'publisherFediverseActorTypeOrganization',
  'publisherFediverseActorTypeApplication',
  'publisherFediverseLocked',
  'publisherFediverseLockedHint',
  'publisherFediverseDiscoverable',
  'publisherFediverseDiscoverableHint',
  'publisherFediverseSettingsSaved',
  'publisherFediverseSettingsFailed',
  'publisherFediverseRemoteRequest',
  'publisherFediverseRemoteFollower',
];

void main() {
  group('SphereApi.updatePublisherActor', () {
    late _CapturingAdapter adapter;
    late SphereApi api;

    setUp(() {
      adapter = _CapturingAdapter();
      api = SphereApi(Dio()..httpClientAdapter = adapter);
    });

    test(
      'PATCHes the publisher fediverse endpoint with changed fields',
      () async {
        await api.updatePublisherActor(
          'alice',
          actorType: 'Service',
          isLocked: true,
        );

        final request = adapter.lastRequest!;
        expect(request.method, 'PATCH');
        expect(request.path, '/sphere/publishers/alice/fediverse');
        expect(request.data, {'actor_type': 'Service', 'is_locked': true});
      },
    );

    test('omits untouched settings so the server keeps their values', () async {
      await api.updatePublisherActor('alice', isDiscoverable: false);

      expect(adapter.lastRequest!.data, {'is_discoverable': false});
    });

    test('parses the returned actor status', () async {
      final status = await api.updatePublisherActor('alice', isLocked: true);

      expect(status.enabled, isTrue);
      expect(status.actorUri, 'https://sphere.test/activitypub/actors/alice');
    });

    test('reads actor status from the same endpoint', () async {
      await api.getPublisherActor('alice');

      expect(adapter.lastRequest!.method, 'GET');
      expect(adapter.lastRequest!.path, '/sphere/publishers/alice/fediverse');
    });
  });

  group('SnActorStatusResponse actor fields', () {
    test('parses the settings the fediverse sheet renders', () {
      final status = SnActorStatusResponse.fromJson({
        'enabled': true,
        'follower_count': 3,
        'actor_uri': 'https://sphere.test/activitypub/actors/alice',
        'actor': {
          'id': 'actor-1',
          'name': 'alice',
          'nick': 'Alice',
          'actor_type': 'Service',
          'is_locked': true,
          'is_discoverable': false,
          'created_at': '2026-01-01T00:00:00Z',
          'updated_at': '2026-01-01T00:00:00Z',
        },
      });

      expect(status.actor?.actorType, 'Service');
      expect(status.actor?.isLocked, isTrue);
      expect(status.actor?.isDiscoverable, isFalse);
    });

    test('defaults locked to false and discoverable to true when absent', () {
      final status = SnActorStatusResponse.fromJson({
        'enabled': true,
        'actor': {
          'id': 'actor-1',
          'name': 'alice',
          'created_at': '2026-01-01T00:00:00Z',
          'updated_at': '2026-01-01T00:00:00Z',
        },
      });

      expect(status.actor?.isLocked, isFalse);
      expect(status.actor?.isDiscoverable, isTrue);
    });
  });

  group('fediverse actor settings localizations', () {
    test('every locale defines every settings key', () {
      final files = Directory('assets/i18n')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();

      expect(files, isNotEmpty, reason: 'no locale files found');

      for (final file in files) {
        final data =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final missing = _actorSettingsKeys
            .where((key) => (data[key] as String?)?.isNotEmpty != true)
            .toList();
        expect(missing, isEmpty, reason: '${file.path} is missing $missing');
      }
    });
  });
}
