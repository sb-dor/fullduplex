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
