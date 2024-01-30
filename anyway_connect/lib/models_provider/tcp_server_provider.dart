import 'dart:io';
import 'dart:typed_data';

import 'package:anyway_connect/models/TcpPacket.dart';
import 'package:anyway_connect/models/packet_id.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

class TcpServerProvider with ChangeNotifier {
  ServerSocket? _serverSocket;
  String? _address;

  get isRunning => _serverSocket != null;

  String? get address => _address;
  int? get port => _serverSocket?.port;

  Future<void> enable() async {
    if (_serverSocket == null) {
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 4835);

      _address = await NetworkInfo().getWifiIP();

      // Do stuff
      print(
          'Server started on port ${_serverSocket!.address.host}:${_serverSocket!.port}');
    }
    notifyListeners();
  }

  void disable() {
    _serverSocket?.close();
    _serverSocket = null;

    notifyListeners();
  }

  @override
  void dispose() {
    disable();
    super.dispose();
  }

  void listen(Future<void> Function(TcpPacket data, Socket socket) callback) {
    _serverSocket?.listen((socket) {
      print('Client connected from ${socket.remoteAddress.address}:${socket.remotePort}');

      socket.listen((data) async {
        final TcpPacket packet = _processPacket(data);
        callback(packet, socket);
      });
    });
  }

  void broadcast(TcpPacket packet) {
    _serverSocket?.forEach((socket) {
      socket.add(packet.toBytes());
      socket.flush();
    });
  }

  T _processPacket<T extends TcpPacket>(Uint8List packet) {
    // Check if the packet is valid
    if (packet.isEmpty) {
      throw Exception('Invalid packet');
    }

    // Get the packet type
    final int index = packet[0];
    // Ensure the index is valid
    if (index < 0 || index >= PacketId.values.length) {
      throw Exception('Invalid packet');
    }

    // Get the packet type
    final PacketId packetId = PacketId.values[index];

    // Parse the packet
    switch (packetId) {
      case PacketId.initConnection:
        print('InitConnectionPacket');
        return InitConnectionPacket.fromBytes(packet) as T;
      case PacketId.iceCandidate:
        print('IceCandidatePacket');
        return IceCandidatePacket.fromBytes(packet) as T;
      case PacketId.sdpDescription:
        print('SdpDescriptionPacket');
        return SdpDescriptionPacket.fromBytes(packet) as T;
      default:
        throw Exception('Invalid packet');
    }
  }
}
