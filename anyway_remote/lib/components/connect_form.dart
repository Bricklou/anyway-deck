import 'package:flutter/material.dart';

import '../models_provider/tcp_client_provider.dart';
import '../pages/main.dart';

class ConnectForm extends StatefulWidget {
  const ConnectForm({super.key});

  @override
  State<ConnectForm> createState() => _ConnectFormState();
}

class _ConnectFormState extends State<ConnectForm> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _ipController.text = '';
    _portController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _ipController,
                decoration: const InputDecoration(
                    labelText: 'IP',
                    hintText: '',
                    helperText: ' ',
                    border: OutlineInputBorder(),
                    constraints: BoxConstraints(minWidth: 200)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter IP';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              fit: FlexFit.tight,
              child: TextFormField(
                controller: _portController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Port',
                    hintText: '',
                    border: const OutlineInputBorder(),
                    hoverColor: Theme.of(context).colorScheme.primary,
                    constraints: const BoxConstraints(maxWidth: 30),
                    contentPadding: const EdgeInsets.all(10)),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null) {
                    return 'Please enter Port';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  surfaceTintColor:
                      Theme.of(context).colorScheme.tertiaryContainer,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final remoteClient = _getRemoteClient();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            MainPage(connection: remoteClient)));
                  }
                },
                child: const Text('Connect'),
              ),
            )
          ],
        ));
  }

  RemoteClient _getRemoteClient() {
    final ip = _ipController.text;
    final port = int.parse(_portController.text);
    return RemoteClient(ip, port);
  }
}
