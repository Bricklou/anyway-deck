import 'dart:typed_data';

/**
 * A string that can be converted into bytes with length in front and opposite
 */
class VarString {
  final String? value;

  VarString(this.value);

  Uint8List toBytes() {
    var value = Uint8List.fromList(this.value!.codeUnits);
    var valueLength = ByteData(4)..setInt32(0, value.length);

    return Uint8List.fromList([
      // Value size
      ...valueLength.buffer.asUint8List(),
      // Value
      ...value,
    ]);
  }

  static (VarString, int) fromBytes(Uint8List bytes) {
    // Get value length
    var valueLength = bytes.sublist(0, 4);
    var valueLengthData = ByteData.sublistView(valueLength);
    var valueLengthInt = valueLengthData.getInt32(0);

    // Get value
    var value = bytes.sublist(4, 4 + valueLengthInt);
    var valueString = String.fromCharCodes(value);

    return (VarString(valueString), 4 + valueLengthInt);
  }
}
