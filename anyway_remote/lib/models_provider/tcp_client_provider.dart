import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import '../models/client_packets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RemoteClient {
  final String ip;
  final int port;

  RemoteClient(this.ip, this.port);

  static fromMap(Map<String, dynamic> map) {
    return RemoteClient(map['ip'], map['port']);
  }
}

class DatedRemoteClient extends RemoteClient {
  final DateTime date;

  DatedRemoteClient(super.ip, super.port, this.date);

  static fromMap(Map<String, dynamic> map) {
    return DatedRemoteClient(map['ip'], map['port'],
        DateTime.fromMillisecondsSinceEpoch(map['date']));
  }

  Map<String, dynamic> toMap() {
    return {
      'ip': ip,
      'port': port,
      'date': date.millisecondsSinceEpoch,
    };
  }
}

class TcpClientProvider with ChangeNotifier {
  SharedPreferences? _prefs;
  Socket? _socket;

  get isConnected => _socket != null;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    disconnect();
    _prefs = null;
    super.dispose();
  }

  Future<void> connect(RemoteClient remoteClient) async {
    disconnect();

    // Save the remote client to history
    await _saveEntryToHistory(remoteClient);
    // Connect to server
    _socket = await Socket.connect(remoteClient.ip, remoteClient.port)
        .catchError((e) {
      print(e);
      throw Exception('Failed to connect to server');
    });

    print("socket: $_socket");
  }

  void send<T extends TcpPacket>(T packet) {
    // Send packet
    _socket?.add(packet.toBytes());
  }

  void disconnect() {
    _socket?.close();
    _socket = null;
  }

  Future<void> _saveEntryToHistory(RemoteClient client) async {
    final entry = {
      'ip': client.ip,
      'port': client.port,
      'date': DateTime.now().millisecondsSinceEpoch,
    };

    final previousHistory = await listHistory();

    // Remove the entry if it already exists
    previousHistory.removeWhere((element) => element.ip == client.ip && element.port == client.port);
    // Add the entry to the list
    previousHistory.add(DatedRemoteClient.fromMap(entry));

    await _prefs!.setStringList(
        "history", previousHistory.map(_mapEntryToString).toList());

    notifyListeners();
  }

  String _mapEntryToString(DatedRemoteClient entry) {
    // Convert the entry to a JSON string
    return jsonEncode(entry.toMap());
  }

  Future<List<DatedRemoteClient>> listHistory() async {
    final history = _prefs!.getStringList("history");

    if (history == null) {
      return [];
    }

    // Map the data to a list of DatedRemoteClient
    final List<DatedRemoteClient> historyList =
        history.map<DatedRemoteClient>((element) {
      // Convert the JSON string to a map
      final Map<String, dynamic> entryMap = jsonDecode(element);
      // Convert the map to a RemoteClient
      return DatedRemoteClient.fromMap(entryMap);
    }).toList();

    // Sort the list by date
    historyList.sort((a, b) => b.date.compareTo(a.date));

    return historyList;
  }

  Future<void> deleteHistory() async {
    await _prefs!.remove('history');
    notifyListeners();
  }

  Future<void> deleteHistoryEntry(DatedRemoteClient entry) async {
    final previousHistory = await listHistory();

    previousHistory.removeWhere((element) => element.ip == entry.ip && element.port == entry.port);
    await _prefs!.setStringList(
        "history", previousHistory.map(_mapEntryToString).toList());

    notifyListeners();
  }
}
