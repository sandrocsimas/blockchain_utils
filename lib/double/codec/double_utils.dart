import 'dart:typed_data';

/// Utility class for encoding and decoding double values.
class DoubleCoder {
  /// Converts a double value to bytes.
  ///
  /// - [value] : The double value to encode.
  /// - [byteOrder] (optional): The byte order for encoding. Defaults to big endian.
  static List<int> toBytes(double value, {Endian byteOrder = Endian.big}) {
    final ByteData byteData = ByteData(8);
    byteData.setFloat64(0, value, byteOrder);
    return byteData.buffer.asUint8List();
  }

  /// Converts bytes to a double value.
  ///
  /// - [bytes] : The bytes to decode.
  /// - [byteOrder] (optional): The byte order for decoding. Defaults to big endian.
  static double fromBytes(List<int> bytes, {Endian byteOrder = Endian.big}) {
    final ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    return byteData.getFloat64(0, byteOrder);
  }
}
