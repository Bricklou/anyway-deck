import 'dart:typed_data';

import 'package:anyway_remote/models/packets_id.dart';

abstract class TcpPacket {
  late PacketId id;

  Uint8List toBytes();
}

class InitConnectionPacket implements TcpPacket {
  InitConnectionPacket._();

  @override
  PacketId id = PacketId.initConnection;

  static InitConnectionPacket fromBytes(Uint8List bytes) {
    // Check if the packet is valid
    if (bytes.length != 1) {
      throw Exception('Invalid packet');
    }

    // Return the packet type
    return InitConnectionPacket._();
  }

  @override
  Uint8List toBytes() {
    // TODO: implement toBytes
    throw UnimplementedError();
  }
}