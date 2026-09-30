import 'dart:io';

import 'package:protocol_handler_platform_interface/protocol_handler_platform_interface.dart';
import 'package:win32_registry/win32_registry.dart';

class ProtocolHandlerWindows extends MethodChannelProtocolHandler {
  ProtocolHandlerWindows() : super();

  static void registerWith() {
    ProtocolHandlerPlatform.instance = ProtocolHandlerWindows();
  }

  @override
  Future<void> register(String scheme) async {
    final appPath = Platform.resolvedExecutable;

    final protocolRegKey = 'Software\\Classes\\$scheme';
    const protocolCmdRegKey = 'shell\\open\\command';

    final regKey = RegistryKey.openCurrentUser(
      RegistryAccess.readWrite,
    ).create(protocolRegKey);
    regKey.setValue('URL Protocol', const RegistryValue.string(''));
    regKey
        .create(protocolCmdRegKey)
        .setValue('', RegistryValue.string('$appPath "%1"'));
  }
}
