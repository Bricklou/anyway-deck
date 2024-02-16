import 'dart:ffi';

import 'package:anyway_remote/steamworks/steamworks.dart';
import 'package:ffi/ffi.dart';

abstract class Action {
  void update(Pointer<ISteamInput> input, InputHandle handler);
  String toString();
}

class AnalogAction extends Action {
  String name;
  InputAnalogActionHandle handle;
  InputAnalogActionData? data;

  AnalogAction._(this.name, this.handle);

  static AnalogAction create(Pointer<ISteamInput> input, String name) {
    final handle = input.getAnalogActionHandle(name.toNativeUtf8());
    if (handle == 0) {
      throw Exception("Action not found");
    }

    return AnalogAction._(name, handle);
  }

  @override
  void update(Pointer<ISteamInput> input, InputHandle inputHandle) {
    data = input.getAnalogActionData(inputHandle, handle);
  }

  @override
  String toString() {
    return "$name: ${data ?? "None"}";
  }
}

class DigitalAction extends Action {
  String name;
  InputDigitalActionHandle handle;
  InputDigitalActionData? data;

  DigitalAction._(this.name, this.handle);

  static DigitalAction create(Pointer<ISteamInput> input, String name) {
    final handle = input.getAnalogActionHandle(name.toNativeUtf8());
    if (handle == 0) {
      throw Exception("Action not found");
    }

    return DigitalAction._(name, handle);
  }

  @override
  void update(Pointer<ISteamInput> input, InputHandle inputHandle) {
    data = input.getDigitalActionData(inputHandle, handle);
  }

  @override
  String toString() {
    return "$name: ${data ?? "None"}";
  }
}

class ActionRepo {
  List<Action> actions = [];

  void push(Action action) {
    this.actions.add(action);
  }

  void update(Pointer<ISteamInput> input, InputHandle inputHandle) {
    for (var action in actions) {
      action.update(input, inputHandle);
    }
  }
}

class AllDeckControls {
  // Action set handle
  InputHandle handle;

  // Actions
  ActionRepo repo;
  DigitalAction btnA;
  DigitalAction btnB;
  DigitalAction btnX;
  DigitalAction btnY;
  DigitalAction btnLB;
  DigitalAction btnRB;
  DigitalAction btnL4;
  DigitalAction btnR4;
  DigitalAction btnL5;
  DigitalAction btnR5;
  DigitalAction btnStart;
  DigitalAction btnSelect;
  AnalogAction lt;
  AnalogAction rt;
  AnalogAction move1;
  AnalogAction move2;
  AnalogAction move3;
  AnalogAction mouse1;
  AnalogAction mouse2;
  AnalogAction mouse3;

  AllDeckControls._(
      this.handle,
      this.repo,
      this.btnA,
      this.btnB,
      this.btnX,
      this.btnY,
      this.btnLB,
      this.btnRB,
      this.btnL4,
      this.btnR4,
      this.btnL5,
      this.btnR5,
      this.btnStart,
      this.btnSelect,
      this.lt,
      this.rt,
      this.move1,
      this.move2,
      this.move3,
      this.mouse1,
      this.mouse2,
      this.mouse3);

  static AllDeckControls? create(Pointer<ISteamInput> input) {
    final repo = ActionRepo();

    final handle = input.getActionSetHandle("AllDeckControls".toNativeUtf8());
    if (handle == 0) {
      throw Exception("Action set not found");
    }

    return AllDeckControls._(
      handle,
      repo,
      DigitalAction.create(input, "btn_a"),
      DigitalAction.create(input, "btn_b"),
      DigitalAction.create(input, "btn_x"),
      DigitalAction.create(input, "btn_y"),
      DigitalAction.create(input, "btn_lb"),
      DigitalAction.create(input, "btn_rb"),
      DigitalAction.create(input, "btn_l4"),
      DigitalAction.create(input, "btn_r4"),
      DigitalAction.create(input, "btn_l5"),
      DigitalAction.create(input, "btn_r5"),
      DigitalAction.create(input, "btn_start"),
      DigitalAction.create(input, "btn_select"),
      AnalogAction.create(input, "lt"),
      AnalogAction.create(input, "rt"),
      AnalogAction.create(input, "move1"),
      AnalogAction.create(input, "move2"),
      AnalogAction.create(input, "move3"),
      AnalogAction.create(input, "mouse1"),
      AnalogAction.create(input, "mouse2"),
      AnalogAction.create(input, "mouse3"),
    );
  }

  void update(Pointer<ISteamInput> input, InputHandle handle) {
    repo.update(input, handle);
  }
}
