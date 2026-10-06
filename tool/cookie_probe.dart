import 'dart:io';
import 'package:dio/dio.dart';

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final base = 'http://127.0.0.1:${server.port}';
  server.listen((req) {
    final cookie = req.headers.value('cookie');
    req.response.headers.add('Set-Cookie', 'RefreshToken=abc123; Path=/; SameSite=Lax');
    req.response.write('cookieHeader=${cookie ?? "NONE"}');
    req.response.close();
  });
  final dio = Dio(BaseOptions(baseUrl: base));
  final r1 = await dio.get('/one');
  final r2 = await dio.get('/two');
  print('r1: ${r1.data}');
  print('r2: ${r2.data}');
  await server.close(force: true);
}
