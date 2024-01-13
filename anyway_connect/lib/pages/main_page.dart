import 'package:anyway_connect/components/webrtc_cart.dart';
import 'package:anyway_connect/components/bluetooth_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';

import '../models_provider/bluetooth_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  @override
  void initState() {
    super.initState();

    context.read<BluetoothProvider>().init();
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
      body: SafeArea(child: renderBody(context)),
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
      child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 15),
        IntrinsicHeight(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BluetoothCard(),
            SizedBox(width: 10),
            WebRtcCard(),
          ],
        ))
      ]),
    );
  }
}
