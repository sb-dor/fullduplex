import 'dart:async';
import 'dart:convert';
import 'dart:io';

typedef JsonMap = Map<String, Object?>;

final codec = (
  encoder: JsonEncoder().fuse<List<int>>(Utf8Encoder()),
  decoder: Utf8Decoder().fuse(JsonDecoder()).cast<Object?, JsonMap>(),
);

Future<Future<void> Function()> server(InternetAddress address, int port) async {
  final server = await ServerSocket.bind(address, port);
  print('Server started on ${server.address.address}:${server.port}');

  final sub = server.listen((client) {
    print('Client connected: ${client.remoteAddress.address}:${client.remotePort}');

    client.listen(
      (bytes) {
        final request = codec.decoder.convert(bytes);
        final <String, Object?>{'id': id, 'message': message} = request;
        print('> message: $message');

        final responseBytes = codec.encoder.convert(<String, Object?>{
          'id': id,
          'message': 'Hello client #$id, I am a server!',
        });

        client.add(responseBytes);
      },
      onDone: () {
        print('client disconnected: ${client.remoteAddress.address}:${client.remotePort}');
        client.close();
      },
    );
  }, cancelOnError: false);

  return () async {
    await sub.cancel();
    await server.close();
    print('server is closed');
  };
}

Future<void> client(final int id) async {
  final socket = await Socket.connect('127.0.0.1', 8080);

  final requestBytes = codec.encoder.convert(<String, Object?>{
    'id': id,
    'message': 'Hello, server!. I am a client $id',
  });
  socket.add(requestBytes);

  final completer = Completer<JsonMap>();
  final sub = socket.map(codec.decoder.convert).listen(completer.complete);
  final response = await completer.future;
  print('< ${response['message']}');

  await sub.cancel();
  await socket.close();
  socket.destroy();
}
