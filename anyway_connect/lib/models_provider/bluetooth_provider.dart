import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothProvider with ChangeNotifier {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothConnection? _bluetoothConnection;
  BluetoothDevice? _device;

  /*
   * GETTERS
   */
  BluetoothState get state => _bluetoothState;

  BluetoothConnection? get connection => _bluetoothConnection;

  bool get isConnected => _bluetoothConnection != null;
  bool get isDeviceSelected => _device != null;

  BluetoothDevice? get connectedDevice => _device;

  /*
   * SETTERS
   */
  void setBluetoothState(BluetoothState state) {
    _bluetoothState = state;
    notifyListeners();
  }

  void setBluetoothConnection(BluetoothConnection? connection) {
    _bluetoothConnection = connection;
    notifyListeners();
  }

  void setDevice(BluetoothDevice? device) {
    _device = device;
    notifyListeners();
  }

  void init() {
    // Get the current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setBluetoothState(state);
    });

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setBluetoothState(state);
    });
  }

  Future<void> requestEnable() async {
    await FlutterBluetoothSerial.instance.requestEnable();
  }

  @override
  void dispose() {
    if (_bluetoothConnection != null) {
      _bluetoothConnection!.close();
    }
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  void connect(BluetoothDevice device) async {
    setDevice(device);
    setBluetoothConnection(await BluetoothConnection.toAddress(device.address));
  }

  void disconnect() async {
    if (_bluetoothConnection != null) {
      await _bluetoothConnection!.close();
      setBluetoothConnection(null);
    }
  }
}
