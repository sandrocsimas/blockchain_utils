import 'dart:typed_data';

import 'package:blockchain_utils/binary/utils.dart';
import 'package:blockchain_utils/numbers/bigint_utils.dart';
import 'package:blockchain_utils/crypto/crypto/cdsa/utils/ed25519_utils.dart';
import 'package:blockchain_utils/crypto/crypto/schnorrkel/strobe/strobe.dart';
import 'package:blockchain_utils/binary/binary_operation.dart';

/// A transcript object for the Merlin cryptographic protocol.
///
/// The `MerlinTranscript` class provides a convenient way to create and manage a transcript for the Merlin cryptographic protocol.
/// It is initialized with an application label and uses a Strobe instance for cryptographic operations.
///
/// Parameters:
/// - `appLabel`: A string representing the application label to differentiate different transcripts.
///
/// Usage:
/// ```dart
/// String appLabel = "MyApp";
/// MerlinTranscript transcript = MerlinTranscript(appLabel);
/// // Create a transcript for the "MyApp" application.
/// ```
///
/// This class simplifies the process of managing transcripts for cryptographic protocols and is commonly used for secure communication and cryptographic operations.
class MerlinTranscript {
  static const String merlinVersion = "Merlin v1.0";
  const MerlinTranscript.fromStrobe(this.strobe);

  /// The Strobe instance used for cryptographic operations.
  factory MerlinTranscript(String label) {
    final transcript = MerlinTranscript.fromStrobe(
        Strobe(merlinVersion, StrobeSecParam.sec128));
    transcript.additionalData("dom-sep".codeUnits, label.codeUnits);
    return transcript;
  }
  MerlinTranscript clone() {
    return MerlinTranscript.fromStrobe(strobe.clone());
  }

  final Strobe strobe;

  /// Appends additional data to the transcript for the Merlin cryptographic protocol.
  ///
  /// This method allows you to include additional data in the transcript,
  ///  which is often used in cryptographic protocols to provide context or metadata for the protocol's operation.
  /// It appends a label and a message to the transcript.
  ///
  /// Parameters:
  /// - `label`: A list of integers representing the label for the additional data.
  /// - `message`: A list of integers representing the actual additional data message.
  ///
  /// Usage:
  /// ```dart
  /// MerlinTranscript transcript = MerlinTranscript("MyApp");
  /// transcript.additionalData("user-id".codeUnits, "Alice".codeUnits);
  /// // Include additional data in the transcript with the label "user-id" and the message "Alice."
  /// ```
  ///
  /// This method ensures that the additional data is properly formatted and included in the transcript,
  /// making it available for cryptographic operations
  void additionalData(List<int> label, List<int> message) {
    final size = List.filled(4, 0);
    writeUint32LE(message.length, size);
    List<int> labelSize = [...label, ...size];
    strobe.additionalData(true, labelSize);
    strobe.additionalData(false, message);
  }

  /// Generates pseudo-random bytes based on the current transcript state.
  ///
  /// This method produces pseudo-random bytes using the current state of the transcript.
  /// The generated bytes can be used for various cryptographic purposes.
  /// It takes a label and an output length as parameters and appends the label to the transcript.
  ///
  /// Parameters:
  /// - `label`: A list of integers representing the label for the pseudo-random data.
  /// - `outLen`: The length of the pseudo-random data to generate, specified as an integer.
  ///
  /// Returns:
  /// A `List<int>` containing the pseudo-random bytes of the specified length.
  ///
  /// Usage:
  /// ```dart
  /// MerlinTranscript transcript = MerlinTranscript("MyApp");
  /// List<int> randomBytes = transcript.toBytes("nonce".codeUnits, 16);
  /// // Generate 16 bytes of pseudo-random data with the label "nonce."
  /// ```
  ///
  /// This method appends the label to the transcript,
  /// ensuring that it influences the generation of pseudo-random bytes.
  /// The generated data is suitable for cryptographic operations.
  List<int> toBytes(List<int> label, int outLen) {
    final len = List.filled(4, 0);
    writeUint32LE(outLen, len);
    List<int> labelSize = [...label, ...len];
    strobe.additionalData(true, labelSize);

    List<int> outBytes = strobe.pseudoRandomData(outLen);
    return BytesUtils.toBytes(outBytes);
  }

  /// Generates pseudo-random bytes and reduces them using scalar reduction.
  ///
  /// This method generates pseudo-random bytes based on the current transcript state and applies scalar
  /// reduction to the output. Scalar reduction ensures that the result is a valid scalar value used in cryptographic operations.
  /// It takes a label and an output length as parameters and appends the label to the transcript.
  ///
  /// Parameters:
  /// - `label`: A list of integers representing the label for the pseudo-random data.
  /// - `outLen`: The length of the pseudo-random data to generate, specified as an integer.
  ///
  /// Returns:
  /// A `List<int>` containing the pseudo-random bytes of the specified length after scalar reduction.
  ///
  /// Usage:
  /// ```dart
  /// MerlinTranscript transcript = MerlinTranscript("MyApp");
  /// List<int> randomScalar = transcript.toBytesWithReduceScalar("scalar".codeUnits, 32);
  /// // Generate 32 bytes of pseudo-random data with the label "scalar," and reduce the result to a valid scalar value.
  /// ```
  ///
  /// This method is particularly useful for generating random scalars used in cryptographic operations.
  List<int> toBytesWithReduceScalar(List<int> label, int outLen) {
    return Ed25519Utils.scalarReduce(toBytes(label, outLen));
  }

  /// Converts pseudo-random bytes into a `BigInt` with scalar reduction.
  ///
  /// This method generates pseudo-random bytes using the `toBytesWithReduceScalar` method and then converts
  ///  those bytes into a `BigInt`. It's commonly used to obtain a random scalar value suitable for cryptographic operations.
  ///
  /// Parameters:
  /// - `label`: A list of integers representing the label for the pseudo-random data.
  /// - `outLen`: The length of the pseudo-random data to generate, specified as an integer.
  ///
  /// Returns:
  /// A `BigInt` obtained from the pseudo-random bytes after scalar reduction.
  ///
  /// Usage:
  /// ```dart
  /// MerlinTranscript transcript = MerlinTranscript("MyApp");
  /// BigInt randomScalar = transcript.toBigint("scalar".codeUnits, 32);
  /// // Generate 32 bytes of pseudo-random data with the label "scalar," reduce the result, and convert it into a BigInt.
  /// ```
  ///
  /// This method is useful for obtaining random scalar values for cryptographic applications.
  BigInt toBigint(List<int> label, int outLen) {
    return BigintUtils.fromBytes(toBytesWithReduceScalar(label, outLen),
        byteOrder: Endian.little);
  }
}
