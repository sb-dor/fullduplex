import 'dart:convert';
import 'dart:io';

Future<void> server() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print('listening: ${server.address.address}:${server.port}');

  final sub = server.listen((request) async {
    request.response.write('Hello from dart http server!');
    await request.response.close();
  });

  // close then (for testing)
  Future.delayed(const Duration(seconds: 10), () async {
    await sub.cancel();
    await server.close();
  });
}

Future<void> client() async {
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse('http://localhost:8080'));
  final response = await request.close();
  await response.map(utf8.decode).forEach(print);
}
