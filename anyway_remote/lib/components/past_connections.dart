import 'package:anyway_remote/models_provider/tcp_client_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/main.dart';

class PastConnections extends StatefulWidget {
  const PastConnections({super.key});

  @override
  State<PastConnections> createState() => _PastConnectionsState();
}

class _PastConnectionsState extends State<PastConnections> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TcpClientProvider>(
      builder: (context, tcpClientProvider, child) {
        return FutureBuilder(
          future: tcpClientProvider.listHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildList(context, snapshot));
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );
      },
    );
  }

  Widget _buildList(
      BuildContext context, AsyncSnapshot<List<DatedRemoteClient>> snapshot) {
    final pastConnections = snapshot.data;

    if (pastConnections == null || pastConnections.isEmpty) {
      return const Center(
        child: Text('No past connections'),
      );
    }

    return ListView.builder(
      itemCount: pastConnections.length,
      itemBuilder: (context, index) {
        final connection = pastConnections[index];

        return ListTile(
          leading: const Icon(Icons.devices),
          hoverColor: Colors.black,
          title: Text("${connection.ip}:${connection.port}"),
          subtitle: Text("${connection.date}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MainPage(connection: connection)));
                  },
                  icon: const Icon(Icons.link)),
              IconButton(
                  onPressed: () {
                    final tcpClientProvider = context.read<TcpClientProvider>();
                    tcpClientProvider.deleteHistoryEntry(connection);
                    setState(() {});
                  },
                  icon: const Icon(Icons.delete))
            ],
          )
        );
      },
    );
  }
}
