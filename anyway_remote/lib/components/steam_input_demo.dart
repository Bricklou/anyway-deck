import 'dart:ffi';
import 'dart:io';
import 'dart:async';

import 'package:anyway_remote/constants.dart';
import 'package:anyway_remote/models/input_controls_handler.dart';
import 'package:anyway_remote/steamworks/steamworks.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SteamInputDemo extends StatefulWidget {
  const SteamInputDemo({Key? key}) : super(key: key);

  @override
  _SteamInputDemoState createState() => _SteamInputDemoState();
}

R poll<R, F extends Function>(SteamClient client, int interval_ms, F f) {
  while (true) {
    final r = f();
    if (r != null) {
      return r;
    }

    sleep(Duration(milliseconds: interval_ms));
    client.runFrame();
  }
}

class _SteamInputDemoState extends State<SteamInputDemo> {
  Timer? timer;
  late AllDeckControls allDeckControls;
  late InputHandle inputHandle;

  @override
  void initState() {
    super.initState();

    _initSteamInput();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _initSteamInput() {
    print("Init Steam Input");
    SteamClient.init(appId: STEAM_APP_ID);
    var client = SteamClient.instance;
    var input = client.steamInput;
    input.init(false);

    allDeckControls = poll(SteamClient.instance, 100, () {
      try {
        return AllDeckControls.create(input);
      } catch (e) {
        print("Error: $e");
        return null;
      }
    });

    final inputHandles = _pollInputHandles(input);
    inputHandle = inputHandles[0];

    input.activateActionSet(inputHandle, allDeckControls.handle);

    timer = Timer.periodic(
        const Duration(seconds: 2), (Timer t) => _updateInputs());
  }

  List<InputHandle> _pollInputHandles(Pointer<ISteamInput> input) {
    return poll(SteamClient.instance, 100, () {
      Pointer<UnsignedLongLong> inputHandles =
          calloc.allocate<UnsignedLongLong>(128);
      final handlesCount = input.getConnectedControllers(inputHandles);
      final List<InputHandle> handlesList = List.empty();

      for (var i = 0; i < handlesCount; i++) {
        final handle = inputHandles.elementAt(i).value;
        handlesList.add(handle);
        print("Handle: $handle");
      }

      return handlesList;
    });
  }

  void _updateInputs() {
    print("Update Steam Inputs");

    allDeckControls.update(SteamClient.instance.steamInput, inputHandle);

    allDeckControls.repo.actions.forEach((element) {
      print("Data: ${element.toString()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text("Steam Input Demo"),
    );
  }
}
