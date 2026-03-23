import 'dart:io';

import 'package:fullduplex/tcpip.dart';

void main(List<String> arguments) async {
  Future sleep() => Future.delayed(const Duration(seconds: 1));

  final close = await server(InternetAddress.anyIPv4, 8080);

  print('server created');
  await sleep();

  for (int i = 0; i < 3; i++) {
    await client(i + 1);
    await sleep();
    print('-----');
  }

  await sleep();

  await close();
}
