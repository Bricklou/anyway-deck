import 'package:anyway_connect/pages/bluetooth_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothCard extends StatefulWidget {
  const BluetoothCard(
      {super.key, this.bluetoothConnection, required this.onConnectionChange});

  final void Function(BluetoothConnection?) onConnectionChange;
  final BluetoothConnection? bluetoothConnection;

  @override
  State<StatefulWidget> createState() => _BluetoothCard();
}

class _BluetoothCard extends State<BluetoothCard> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothDevice? _device;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 5))
            ]),
        child: Stack(
          children: [
            const Positioned(
                top: 15,
                left: 15,
                child: Text('Bluetooth',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54))),
            Positioned(
                top: 3,
                right: -5,
                child: ElevatedButton(
                    onPressed: () async {
                      _showDeviceList(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(0),
                      shadowColor: Colors.transparent,
                    ),
                    child: Icon(Icons.settings,
                        color: Theme.of(context).colorScheme.secondary))),
            Container(
                padding: const EdgeInsets.all(10).copyWith(
                  top: 45,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Center(
                              child: Icon(Icons.bluetooth,
                                  size: 50,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withOpacity(0.8)))),
                      const SizedBox(height: 10),
                      renderBtButton(),
                    ]))
          ],
        ),
      ),
    );
  }

  Widget renderBtButton() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      if (!_bluetoothState.isEnabled) {
        return ElevatedButton(
          child: const Text('Enable Bluetooth'),
          onPressed: () async {
            await FlutterBluetoothSerial.instance.requestEnable();
            setState(() {});
          },
        );
      }

      const textStyle = TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black54);

      // If there is no pending connection
      if (widget.bluetoothConnection == null ||
          !widget.bluetoothConnection!.isConnected ||
          _device == null) {
        return const Center(
            child: Text('No device selected',
                textAlign: TextAlign.center, style: textStyle));
      }

      // Otherwise, if there is a connection
      return Center(
          child: Text('Connected to ${_device!.name ?? _device!.address}',
              textAlign: TextAlign.center, style: textStyle));
    });
  }

  void _showDeviceList(BuildContext context) async {
    final BluetoothDevice? selectedDevice = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const BluetoothSettingsPage()));

    if (selectedDevice == null) {
      // User has cancelled selection, do nothing
      return;
    }

    setState(() {
      _device = selectedDevice;
    });

    BluetoothConnection.toAddress(selectedDevice.address).then((connection) {
      widget.onConnectionChange(connection);
    });
  }
}
