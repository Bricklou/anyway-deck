import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routeName = '/';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      appBar: _renderAppBar(context),
      body: _renderBody(),
    );
  }

  AppBar _renderAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text('Anyway Connect',
          style: TextStyle(
              fontSize: 20,
              color: Colors.black45,
              fontWeight: FontWeight.w600)),
    );
  }

  Widget _renderBody() {
    return const Center(
      child: Text('Home Page'),
    );
  }
}
