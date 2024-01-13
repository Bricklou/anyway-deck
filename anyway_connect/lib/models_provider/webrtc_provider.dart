import 'package:flutter/material.dart';

class WebRtcProvider with ChangeNotifier {
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  void setConnected(bool isConnected) {
    _isConnected = isConnected;
    notifyListeners();
  }

  void init() {
  }

  Future<void> enable() async {}

  Future<void> disable() async {}
}