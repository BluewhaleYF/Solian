import 'package:solar_network_sdk/solar_network_sdk.dart';

class AuthorizeClientInfo {
  final String clientName;

  /// The client slug. Stargate resolves `client_id` to the slug, which also
  /// keys the public app profile (`/develop/apps/{slug}`).
  final String? clientId;
  final String? homeUri;
  final SnCloudFileReference? picture;
  final SnCloudFileReference? background;
  final List<String> scopes;
  final String? description;

  const AuthorizeClientInfo({
    required this.clientName,
    this.clientId,
    this.homeUri,
    this.picture,
    this.background,
    this.scopes = const [],
    this.description,
  });

  factory AuthorizeClientInfo.fromJson(Map<String, dynamic> json) {
    return AuthorizeClientInfo(
      clientName: (json['client_name'] as String?)?.trim().isNotEmpty == true
          ? (json['client_name'] as String).trim()
          : (json['name'] as String?)?.trim() ?? 'Unknown App',
      clientId:
          _readString(json['client_id']) ??
          _readString(json['clientId']) ??
          _readString(json['client_slug']) ??
          _readString(json['slug']),
      homeUri: (json['home_uri'] as String?)?.trim(),
      picture: json['picture'] is Map<String, dynamic>
          ? SnCloudFileReference.fromJson(
              json['picture'] as Map<String, dynamic>,
            )
          : null,
      background: json['background'] is Map<String, dynamic>
          ? SnCloudFileReference.fromJson(
              json['background'] as Map<String, dynamic>,
            )
          : null,
      scopes:
          (json['scopes'] as List?)?.map((item) => item.toString()).toList() ??
          _readScopeString(json['scope']),
      description: (json['description'] as String?)?.trim(),
    );
  }

  static String? _readString(dynamic raw) {
    if (raw is! String) return null;
    final value = raw.trim();
    return value.isEmpty ? null : value;
  }

  static List<String> _readScopeString(dynamic raw) {
    if (raw is! String || raw.trim().isEmpty) return const [];
    return raw.split(RegExp(r'\s+')).where((item) => item.isNotEmpty).toList();
  }
}
