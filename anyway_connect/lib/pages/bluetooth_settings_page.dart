import 'dart:async';

import 'package:anyway_connect/components/bluetooth_device_list_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothSettingsPage extends StatefulWidget {
  const BluetoothSettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _BluetoothSettingsPage();
}

class _BluetoothSettingsPage extends State<BluetoothSettingsPage> {
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = true;

  @override
  void initState() {
    super.initState();
    _startDiscovery();
  }

  void openBtSettings() {
    FlutterBluetoothSerial.instance.openSettings();
  }

  void _restartDiscovery() {
    setState(() {
      results.clear();
      isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        final existingIndex = results.indexWhere(
            (element) => element.device.address == r.device.address);
        if (existingIndex >= 0) {
          results[existingIndex] = r;
        } else {
          results.add(r);
        }
      });
    });

    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and cancel discovery
    _streamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: renderAppBar(context),
      body: renderBody(context),
    );
  }

  AppBar renderAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Bluetooth Settings'),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      actions: [
        isDiscovering
            ? FittedBox(
                child: Container(
                margin: const EdgeInsets.all(16.0),
                width: 24,
                height: 24,
                child: const CircularProgressIndicator(strokeWidth: 2.0),
              ))
            : IconButton(
                icon: const Icon(Icons.replay),
                onPressed: _restartDiscovery,
              ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: openBtSettings,
        ),
      ],
    );
  }

  Widget renderBody(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const ListTile(title: Text('Select a device to connect')),
            Expanded(child: renderDeviceList(context))
          ]),
    );
  }

  Widget renderDeviceList(BuildContext context) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        BluetoothDiscoveryResult result = results[index];
        final device = result.device;
        final address = device.address;

        return BluetoothDeviceListEntry(
          device: device,
          rssi: result.rssi,
          onTap: () {
            // Return the device to connect to
            Navigator.of(context).pop(result.device);
          },
          onLongPress: () async {
            // On long press, display a dialog menu with more options
            try {
              bool bonded = false;
              if (device.isBonded) {
                print('Unbinding from ${device.address}...');
                await FlutterBluetoothSerial.instance
                    .removeDeviceBondWithAddress(address);
                print('Unbinding from ${device.address} has succeed');
              } else {
                print('Binding with ${device.address}...');
                bonded = (await FlutterBluetoothSerial.instance
                    .bondDeviceAtAddress(address))!;
                print(
                    'Binding with ${device.address} has ${bonded ? 'succeed' : 'failed'}.');
              }
              setState(() {
                results[results.indexOf(result)] = BluetoothDiscoveryResult(
                    device: BluetoothDevice(
                      name: device.name ?? '',
                      address: address,
                      type: device.type,
                      bondState: bonded
                          ? BluetoothBondState.bonded
                          : BluetoothBondState.none,
                    ),
                    rssi: result.rssi);
              });
            } catch (ex) {
              if (!context.mounted) return;

              await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Error occurred while bonding'),
                    content: Text(ex.toString()),
                    actions: <Widget>[
                      TextButton(
                        child: const Text("Close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          },
        );
      },
    );
  }
}
