import 'package:anyway_remote/components/steam_input_demo.dart';
import 'package:anyway_remote/components/connect_form.dart';
import 'package:anyway_remote/components/past_connections.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _renderAppBar(context),
      body: _renderBody(),
    );
  }

  AppBar _renderAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      elevation: 0,
      title: const Text('Anyway Connect',
          style: TextStyle(
              fontSize: 20,
              color: Colors.black45,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _renderBody() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _renderHeaderCard(),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Past Connections',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Expanded(child: PastConnections()),
          const Expanded(child: SteamInputDemo())
        ])
      ],
    );
  }

  Widget _renderHeaderCard() {
    return Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.surfaceVariant,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),
            Container(
              height: 70,
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              child: const ConnectForm(),
            ),
          ],
        ));
  }
}
