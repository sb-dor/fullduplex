import 'dart:io';

import 'package:fullduplex/tcpip.dart' as tcpip;
import 'package:fullduplex/htppserver.dart' as httpserver;

Future sleep() => Future.delayed(const Duration(seconds: 1));

void main(List<String> arguments) async {
  // await tcpipFunc();
  await httpServerTest();
}

Future<void> tcpipFunc() async {
  final close = await tcpip.server(InternetAddress.anyIPv4, 8080);

  print('server created');
  await sleep();

  for (int i = 0; i < 3; i++) {
    await tcpip.client(i + 1);
    await sleep();
    print('-----');
  }

  await sleep();

  await close();
}

Future<void> httpServerTest() async {
  await httpserver.server();
  await sleep();
  await httpserver.client();
}
