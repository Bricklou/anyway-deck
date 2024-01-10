import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  @override
  void initState() {
    super.initState();

    // Get the current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }

      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Listen for futher state changes
      FlutterBluetoothSerial.instance
          .onStateChanged()
          .listen((BluetoothState state) {
        setState(() {
          _bluetoothState = state;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anyway Connect'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(children: renderMainContent()),
    );
  }

  List<Widget> renderMainContent() {
    if (!_bluetoothState.isEnabled) {
      return [
        const ListTile(
          title: Text('Bluetooth is disabled'),
        ),
        ListTile(
          title: ElevatedButton(
            child: const Text('Enable Bluetooth'),
            onPressed: () => {FlutterBluetoothSerial.instance.requestEnable()},
          ),
        )
      ];
    }

    return [
      const ListTile(
        title: Text('Bluetooth is enabled'),
      ),
    ];
  }
}
