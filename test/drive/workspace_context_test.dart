import 'package:flutter_test/flutter_test.dart';
import 'package:island/drive/workspace_context.dart';

/// The workspace storage snapshot the Drive reads. The registry, member and
/// management models this file used to cover moved to the SolWatt app along
/// with the workspace console; the localized service legend stays covered by
/// `test/drive/usage_overview_test.dart`.
void main() {
  test('parses workspace storage snapshots and preserves service usage', () {
    final quota = WorkspaceStorageQuota.fromJson({
      'used_bytes': 734003200,
      'limit_bytes': 1073741824,
      'remaining_bytes': 340787624,
      'calculated_at': '2026-08-19T00:20:00Z',
      'services': [
        {'name': 'drive', 'used_bytes': 524288000},
        {'name': 'postal', 'used_bytes': 209715200},
        {'name': 'flywheel', 'used_bytes': 1024},
      ],
    });

    expect(quota.usedBytes, 734003200);
    expect(quota.limitBytes, 1073741824);
    expect(quota.remainingBytes, 340787624);
    expect(quota.calculatedAt, '2026-08-19T00:20:00Z');
    expect(quota.services.map((service) => service.name), [
      'drive',
      'postal',
      'flywheel',
    ]);
    expect(quota.services.first.usedBytes, 524288000);
    expect(quota.toUsageMap()['used_bytes'], 734003200);
    expect(quota.toUsageMap()['limit_bytes'], 1073741824);
    expect(quota.toUsageMap()['service_usages'] as List, [
      {'name': 'drive', 'used_bytes': 524288000},
      {'name': 'postal', 'used_bytes': 209715200},
      {'name': 'flywheel', 'used_bytes': 1024},
    ]);
  });

  test('falls back to the limit when the snapshot omits a remainder', () {
    final quota = WorkspaceStorageQuota.fromJson({
      'used_bytes': 1000,
      'limit_bytes': 4096,
    });

    expect(quota.remainingBytes, 3096);
    expect(quota.services, isEmpty);
    expect(quota.calculatedAt, isNull);
  });
}
