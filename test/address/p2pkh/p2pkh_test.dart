import 'package:blockchain_utils/bip/address/p2pkh_addr.dart';
import '../../quick_hex.dart';
import 'package:blockchain_utils/binary/utils.dart';
import 'package:test/test.dart';

import 'comperesed_test_vector.dart' show compresedTestVector;
import 'uncompresed_test_vector.dart' show uncompressedTestVector;

void main() {
  test("p2pkh address test", () {
    for (final i in compresedTestVector) {
      final params = Map<String, dynamic>.from(i["params"]);
      params["pub_key_mode"] = PubKeyModes.compressed;
      params["net_ver"] = BytesUtils.fromHexString(params["net_ver"]);
      final z = P2PKHAddrEncoder()
          .encodeKey(BytesUtils.fromHexString(i["public"]), params);
      expect(z, i["address"]);
      final decode = P2PKHAddrDecoder().decodeAddr(z, params);
      expect(decode.toHex(), i["decode"]);
    }
  });
  test("p2pkh uncompressed publickey address test", () {
    for (final i in uncompressedTestVector) {
      final params = Map<String, dynamic>.from(i["params"]);
      params["pub_key_mode"] = PubKeyModes.uncompressed;
      params["net_ver"] = BytesUtils.fromHexString(params["net_ver"]);
      final z = P2PKHAddrEncoder()
          .encodeKey(BytesUtils.fromHexString(i["public"]), params);
      expect(z, i["address"]);
      final decode = P2PKHAddrDecoder().decodeAddr(z, params);
      expect(decode.toHex(), i["decode"]);
    }
  });
}
