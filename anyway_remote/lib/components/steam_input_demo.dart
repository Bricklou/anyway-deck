import 'dart:ffi';
import 'dart:io';

import 'package:anyway_remote/constants.dart';
import 'package:anyway_remote/steamworks/steamworks.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';

class SteamInputDemo extends StatefulWidget {
  const SteamInputDemo({Key? key}) : super(key: key);

  @override
  _SteamInputDemoState createState() => _SteamInputDemoState();
}

class _SteamInputDemoState extends State<SteamInputDemo> {
  @override
  void initState() {
    super.initState();
    // print current working dir
    print(Directory.current.path);
    try {
      SteamClient.init(appId: STEAM_APP_ID);
    } catch (e) {
      print(e);
      rethrow;
    }

    var client = SteamClient.instance;

    var input = client.steamInput;
    input.init(false);

    Pointer<UnsignedLongLong> inputHandles =
        calloc.allocate<UnsignedLongLong>(128);

    var inputHandle = input.getConnectedControllers(inputHandles);
    print("inputHandle");
    print(inputHandle);
    var actionSetHandle = input.getActionSetHandle("AnywayDeck".toNativeUtf8());
    input.activateActionSet(inputHandle, actionSetHandle);

    calloc.free(inputHandles);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text("Steam Input Demo"),
    );
  }
}
