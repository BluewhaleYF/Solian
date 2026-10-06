import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

/// Builds a JWT-shaped string whose payload carries `iat`/`exp` (seconds).
/// The client only base64-decodes the payload, so the signature is irrelevant.
String _token({required int iat, required int exp, String marker = ''}) {
  String b64(Map<String, dynamic> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${b64({'alg': 'RS256'})}.${b64({'iat': iat, 'exp': exp, 'marker': marker})}.sig';
}

String _pairJson({
  required String token,
  required String refreshToken,
  required DateTime accessExpiresAt,
  required DateTime refreshExpiresAt,
}) => jsonEncode({
  'token': token,
  'refresh_token': refreshToken,
  'expires_at': accessExpiresAt.toUtc().toIso8601String(),
  'refresh_expires_at': refreshExpiresAt.toUtc().toIso8601String(),
});

void main() {
  test('getValidAuthToken uses a pair rotated out of band instead of the '
      'stale in-memory one', () async {
    final now = DateTime.now();
    final staleExpiry = now.subtract(const Duration(minutes: 2));
    final freshExpiry = now.add(const Duration(minutes: 5));
    final refreshExpiry = now.add(const Duration(days: 20));

    final staleToken = _token(
      iat: now.subtract(const Duration(minutes: 10)).millisecondsSinceEpoch ~/ 1000,
      exp: staleExpiry.millisecondsSinceEpoch ~/ 1000,
      marker: 'stale',
    );
    final freshToken = _token(
      iat: now.millisecondsSinceEpoch ~/ 1000,
      exp: freshExpiry.millisecondsSinceEpoch ~/ 1000,
      marker: 'fresh',
    );

    SharedPreferences.setMockInitialValues({
      kTokenPairStoreKey: _pairJson(
        token: staleToken,
        refreshToken: 'stale-refresh',
        accessExpiresAt: staleExpiry,
        refreshExpiresAt: refreshExpiry,
      ),
      // Unroutable: a refresh attempt must fail fast, so the test observes the
      // client's choice rather than a live rotation.
      kNetworkServerStoreKey: 'http://127.0.0.1:9',
    });
    final prefs = await SharedPreferences.getInstance();

    // Another engine (iOS native token refresh / desktop call-window engine)
    // rotates the pair straight into the shared store. The Dart
    // SharedPreferences cache keeps the pre-rotation values until reload().
    await SharedPreferencesStorePlatform.instance.setValue(
      'String',
      'flutter.$kTokenPairStoreKey',
      _pairJson(
        token: freshToken,
        refreshToken: 'fresh-refresh',
        accessExpiresAt: freshExpiry,
        refreshExpiresAt: refreshExpiry,
      ),
    );

    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    final tokenFuture = FutureProvider<String?>((ref) => getValidAuthToken(ref));

    final resolved = await container.read(tokenFuture.future);

    expect(
      resolved,
      freshToken,
      reason: 'the freshly rotated token must win over the cached, now-stale one',
    );
  });
}
