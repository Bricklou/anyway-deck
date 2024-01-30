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
  void initState() {
    super.initState();

    final tcpClientProvider = context.read<TcpClientProvider>();
    tcpClientProvider.init();
  }
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
            onTap: () => _connectToItem(connection),
            hoverColor: Colors.black12,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            title: Text("${connection.ip}:${connection.port}",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            subtitle: Text("${connection.date}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () {
                      final tcpClientProvider =
                          context.read<TcpClientProvider>();
                      tcpClientProvider.deleteHistoryEntry(connection);
                      setState(() {});
                    },
                    icon: const Icon(Icons.delete))
              ],
            ));
      },
    );
  }

  void _connectToItem(DatedRemoteClient connection) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            MainPage(connection: connection)));
  }
}
