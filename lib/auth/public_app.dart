import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/auth/web_auth/web_auth_app_info.dart';
import 'package:island/core/network.dart';

/// Public app profile for a client slug (`GET /develop/apps/{slug}`).
///
/// The auth endpoints only return the bare client payload (name, icon, scopes).
/// The consent surfaces use this to add the provenance the web pages show —
/// publisher, verification mark and home page — so a user can tell a verified
/// first-party client apart from an unrecognised one before approving.
///
/// Best effort: a missing or malformed profile resolves to `null` and the
/// consent UI simply renders without the extra evidence rather than failing.
final publicAppProvider = FutureProvider.autoDispose
    .family<WebAuthAppInfo?, String>((ref, slug) async {
      final trimmed = slug.trim();
      if (trimmed.isEmpty) return null;

      final dio = ref.watch(solarNetworkClientProvider).dio;
      try {
        final response = await dio.get(
          '/develop/apps/${Uri.encodeComponent(trimmed)}',
        );
        final data = response.data;
        if (data is! Map) return null;
        return WebAuthAppInfo.fromJson(Map<String, dynamic>.from(data));
      } catch (_) {
        return null;
      }
    });
