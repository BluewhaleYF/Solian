import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

bool showsOnlinePresence(SnAccountStatus? status) {
  if (status == null) return false;
  return status.isOnline && !status.isInvisible;
}

String getStatusTypeLabel(BuildContext context, SnAccountStatus? status) {
  if (status == null) {
    return 'offline'.tr();
  }

  if (status.isIdleOrOnline) {
    return 'idle'.tr();
  }

  return switch (status.type) {
    SnAccountStatusType.busy => 'statusBusy'.tr(),
    SnAccountStatusType.doNotDisturb => 'statusNotDisturb'.tr(),
    SnAccountStatusType.invisible => 'statusInvisible'.tr(),
    _ => status.isOnline ? 'online'.tr() : 'offline'.tr(),
  };
}

String getStatusDisplayLabel(BuildContext context, SnAccountStatus? status) {
  final label = status?.label.trim();
  if (label != null && label.isNotEmpty) {
    return label;
  }
  return getStatusTypeLabel(context, status);
}

/// The display name of the device the account is currently online from, or
/// null when no device presence is known (e.g. the status predates the
/// online-devices field).
String? getStatusOnlineDeviceLabel(SnAccountStatus? status) {
  if (status == null || !status.isOnline) return null;
  final devices = status.onlineDevices;
  if (devices.isEmpty) return null;
  return devices.first.displayName;
}

String? getStatusDisplaySymbol(SnAccountStatus? status) {
  final symbol = status?.symbol?.trim();
  if (symbol == null || symbol.isEmpty) return null;
  return symbol;
}

/// Presence tint for a status type, matching [getStatusIndicatorColor] for an
/// account that is currently online.
Color statusTypeIndicatorColor(int type) {
  return switch (type) {
    SnAccountStatusType.busy => Colors.orange,
    SnAccountStatusType.doNotDisturb => Colors.deepOrange,
    SnAccountStatusType.invisible => Colors.grey,
    _ => Colors.green,
  };
}

/// The presence glyph is always a dot: what changes between statuses is its
/// color and fill, not its shape, so the same mark reads the same everywhere.
IconData getStatusIndicatorIcon(SnAccountStatus? status) {
  return Symbols.circle_rounded;
}

double getStatusIndicatorFill(SnAccountStatus? status) {
  if (status?.isIdleOrOnline ?? false) return 1;
  return (status?.isOnline ?? false) ? 1 : 0;
}

Color getStatusIndicatorColor(SnAccountStatus? status) {
  if (status == null) {
    return Colors.grey;
  }

  if (status.isIdleOrOnline) {
    return Colors.amber;
  }

  if (status.type == SnAccountStatusType.defaultType) {
    return status.isOnline ? Colors.green : Colors.grey;
  }

  return statusTypeIndicatorColor(status.type);
}
