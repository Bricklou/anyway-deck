import 'package:anyway_connect/pages/bluetooth_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

import '../models_provider/bluetooth_provider.dart';

class BluetoothCard extends StatefulWidget {
  const BluetoothCard({super.key});

  @override
  State<StatefulWidget> createState() => _BluetoothCard();
}

class _BluetoothCard extends State<BluetoothCard> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 180),
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
                  top: 55,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Center(
                          child: Icon(Icons.bluetooth,
                              size: 50,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.8))),
                      Consumer<BluetoothProvider>(
                          builder: (context, bluetoothProvider, _) =>
                              renderBtButton(bluetoothProvider)),
                    ]))
          ],
        ),
      ),
    );
  }

  Widget renderBtButton(BluetoothProvider bluetoothProvider) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      // If bluetooth is not enabled
      if (!bluetoothProvider.state.isEnabled) {
        return ElevatedButton(
          child: const Text('Enable Bluetooth'),
          onPressed: () async {
            await bluetoothProvider.requestEnable();
            setState(() {});
          },
        );
      }

      const textStyle = TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black54);

      // If there is no pending connection
      if (!bluetoothProvider.isConnected ||
          !bluetoothProvider.isDeviceSelected) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 14.0),
          child: Center(
              child: Text('No device selected',
                  textAlign: TextAlign.center, style: textStyle)),
        );
      }

      // Otherwise, if there is a connection
      final device = bluetoothProvider.connectedDevice!;
      return Center(
          child: Text('Connected to ${device.name ?? device.address}',
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
      // Connect to the selected device
      final bluetoothProvider = context.read<BluetoothProvider>();
      bluetoothProvider.connect(selectedDevice);
    });
  }
}
