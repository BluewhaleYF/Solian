import 'package:easy_localization/easy_localization.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:island/core/network.dart';

/// Workspace context the Drive needs: the registry entry, its storage
/// snapshot, and the two providers that fetch them.
///
/// Workspace *management* (the registry screen, the per-workspace console,
/// members, plans, mail and Flywheel administration) lives in the SolWatt app,
/// not here. These few types stay because the Drive browser selects among the
/// account's workspaces and shows their storage usage.
///
/// The endpoints come from Valve's workspace registry:
/// - `GET /valve/workspaces` — the account's workspaces.
/// - `GET /valve/workspaces/{slug}/quota/storage` — storage snapshot.

/// Registry entry for one workspace, as the Drive's workspace picker needs it.
class WorkspaceSummary {
  final String id;
  final String slug;
  final String name;
  final String description;
  final int type;
  final String ownerAccountId;
  final int plan;
  final bool isBundled;

  /// Cloud file id of the workspace avatar, if the server provided one.
  final String? pictureId;

  /// Cloud file id of the workspace banner, if the server provided one.
  final String? backgroundId;

  const WorkspaceSummary({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.type,
    required this.ownerAccountId,
    required this.plan,
    required this.isBundled,
    this.pictureId,
    this.backgroundId,
  });

  bool get isIndividual => type == 0;

  String get planLabel => switch (plan) {
    1 => 'workspacePlanPro'.tr(),
    2 => 'workspacePlanEnterprise'.tr(),
    _ => 'workspacePlanFree'.tr(),
  };

  factory WorkspaceSummary.fromJson(dynamic value) {
    final json = Map<String, dynamic>.from(value as Map);
    return WorkspaceSummary(
      id: _string(json['id']),
      slug: _string(json['slug']),
      name: _string(json['name']),
      description: _string(json['description']),
      type: _enumValue(json['type'], individual: 0, organization: 1),
      ownerAccountId: _string(json['owner_account_id']),
      plan: _enumValue(json['plan'], free: 0, pro: 1, enterprise: 2),
      isBundled: json['is_bundled'] == true,
      pictureId: _referenceId(json['picture']),
      backgroundId: _referenceId(json['background']),
    );
  }

  static String _string(dynamic value) => value?.toString() ?? '';

  /// The id of a `SnCloudFileReferenceObject`-shaped payload, or null.
  static String? _referenceId(dynamic value) {
    if (value is! Map) return null;
    return value['id']?.toString();
  }

  static int _enumValue(
    dynamic value, {
    int individual = 0,
    int organization = 0,
    int free = 0,
    int pro = 0,
    int enterprise = 0,
  }) {
    if (value is num) return value.toInt();
    final normalized = value?.toString().toLowerCase();
    return switch (normalized) {
      'organization' => organization,
      'pro' => pro,
      'enterprise' => enterprise,
      'individual' => individual,
      _ => int.tryParse(normalized ?? '') ?? free,
    };
  }
}

/// Converts Valve service identifiers into user-facing localized names.
String localizedWorkspaceServiceName(String serviceName) {
  final key = switch (serviceName.trim().toLowerCase()) {
    'drive' => 'workspaceServiceDrive',
    'postal' => 'workspaceServicePostal',
    'distribution' => 'workspaceServiceDistribution',
    'flywheel' => 'workspaceServiceFlywheel',
    _ => null,
  };
  return key == null ? serviceName : key.tr();
}

/// Storage usage retained in a workspace snapshot by Valve.
///
/// Consumers localize [name] through [localizedWorkspaceServiceName];
/// `toJson` keeps the server identifier intact.
class WorkspaceStorageServiceUsage {
  final String name;
  final int usedBytes;

  const WorkspaceStorageServiceUsage({
    required this.name,
    required this.usedBytes,
  });

  factory WorkspaceStorageServiceUsage.fromJson(dynamic value) {
    final json = Map<String, dynamic>.from(value as Map);
    return WorkspaceStorageServiceUsage(
      name: json['name']?.toString() ?? '',
      usedBytes: (json['used_bytes'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'used_bytes': usedBytes};
}

/// Effective workspace storage quota and the latest per-service snapshot.
class WorkspaceStorageQuota {
  final int usedBytes;
  final int limitBytes;
  final int remainingBytes;
  final String? calculatedAt;
  final List<WorkspaceStorageServiceUsage> services;

  const WorkspaceStorageQuota({
    required this.usedBytes,
    required this.limitBytes,
    required this.remainingBytes,
    required this.calculatedAt,
    required this.services,
  });

  factory WorkspaceStorageQuota.fromJson(dynamic value) {
    final json = Map<String, dynamic>.from(value as Map);
    final usedBytes = (json['used_bytes'] as num?)?.toInt() ?? 0;
    final limitBytes = (json['limit_bytes'] as num?)?.toInt() ?? 0;
    final remainingBytes =
        (json['remaining_bytes'] as num?)?.toInt() ??
        (limitBytes - usedBytes).clamp(0, limitBytes).toInt();
    final services = (json['services'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(WorkspaceStorageServiceUsage.fromJson)
        .toList(growable: false);
    return WorkspaceStorageQuota(
      usedBytes: usedBytes,
      limitBytes: limitBytes,
      remainingBytes: remainingBytes,
      calculatedAt: json['calculated_at']?.toString(),
      services: services,
    );
  }

  /// Adapts the workspace snapshot to the drive usage view's data contract.
  Map<String, dynamic> toUsageMap() => {
    'total_usage_bytes': usedBytes,
    'total_file_count': 0,
    'total_quota': limitBytes ~/ (1024 * 1024),
    'used_quota': usedBytes / (1024 * 1024),
    'used_bytes': usedBytes,
    'limit_bytes': limitBytes,
    'total_bytes': limitBytes,
    'remaining_bytes': remainingBytes,
    'calculated_at': calculatedAt,
    'service_usages': [for (final service in services) service.toJson()],
  };
}

final workspaceListProvider =
    FutureProvider.autoDispose<List<WorkspaceSummary>>((ref) async {
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get('/valve/workspaces');
      if (response.data is! List) {
        throw StateError('Workspace list returned an invalid response.');
      }
      return (response.data as List)
          .map(WorkspaceSummary.fromJson)
          .toList(growable: false);
    });

final workspaceStorageQuotaProvider = FutureProvider.autoDispose
    .family<WorkspaceStorageQuota?, String?>((ref, slug) async {
      if (slug == null || slug.isEmpty) return null;
      final client = ref.read(solarNetworkClientProvider);
      final response = await client.dio.get(
        '/valve/workspaces/${Uri.encodeComponent(slug)}/quota/storage',
      );
      if (response.data is! Map) {
        throw StateError(
          'Workspace storage quota returned an invalid response.',
        );
      }
      return WorkspaceStorageQuota.fromJson(response.data);
    });
