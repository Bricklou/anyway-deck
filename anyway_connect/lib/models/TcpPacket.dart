import 'dart:typed_data';

import 'package:anyway_connect/models/packet_id.dart';

abstract class TcpPacket {
  late PacketId id;

  Uint8List toBytes();
  TcpPacket fromBytes(Uint8List bytes);
}

class InitConnectionPacket implements TcpPacket {
  @override
  PacketId id = PacketId.initConnection;

  @override
  InitConnectionPacket fromBytes(Uint8List bytes) {
    // Check if the packet is valid
    if (bytes.length != 1) {
      throw Exception('Invalid packet');
    }

    // Return the packet type
    return InitConnectionPacket();
  }
  @override
  Uint8List toBytes() {
    // TODO: implement toBytes
    throw UnimplementedError();
  }
}