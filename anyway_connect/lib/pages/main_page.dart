import 'dart:typed_data';

import 'package:anyway_connect/components/action_card.dart';
import 'package:anyway_connect/components/bluetooth_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothConnection? _bluetoothConnection;

  @override
  void initState() {
    super.initState();

    // Get the current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    // Listen for further state changes
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
    return Scaffold(
      appBar: renderAppBar(context),
      body: renderBody(context),
    );
  }

  PreferredSizeWidget renderAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      elevation: 0,
      title: const Text('Anyway Connect',
          style: TextStyle(
              fontSize: 20,
              color: Colors.black45,
              fontWeight: FontWeight.w600)),
      actions: [
        ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(0),
              shadowColor: Colors.transparent,
            ),
            child: Icon(Icons.settings,
                color: Theme.of(context).colorScheme.secondary)),
        const SizedBox(width: 10)
      ],
    );
  }

  Widget renderBody(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _renderHeaderCard(),
            const SizedBox(height: 20),
            const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text('Your devices',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black45,
                        fontWeight: FontWeight.w600))),
            /*BodyCard()*/
          ],
        )
      ],
    );
  }

  Widget _renderHeaderCard() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 15),
        IntrinsicHeight(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BluetoothCard(
                bluetoothConnection: _bluetoothConnection,
                onConnectionChange: _onBluetoothConnectionChange),
            const SizedBox(width: 10),
            ActionCard(
              'WebRTC server',
              onStateChanged: (bool state) => {},
            ),
          ],
        ))
      ]),
    );
  }

  void _onBluetoothConnectionChange(BluetoothConnection? connection) {
    setState(() {
      _bluetoothConnection = connection;
    });

    if (_bluetoothConnection != connection) {
      _bluetoothConnection?.close();
      _bluetoothConnection = connection;
    }

    if (_bluetoothConnection == null) {
      return;
    }

    _bluetoothConnection?.input!.listen(_onDataReceived).onDone(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _onDataReceived(Uint8List data) {

  }
}
