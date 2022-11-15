
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:cryptography/cryptography.dart' as cry;
import 'dart:convert' as convert;

class F
{
  
  static Future generateIvKey(String digest) async
  {
    final _storage = const FlutterSecureStorage();
    final key = enc.Key.fromBase64(digest);
    final iv = enc.IV.fromSecureRandom(16);
    
    await _storage.write(key: 'IV', value: iv.base64);
    await _storage.write(key: 'KEY', value: key.base64);
  }

  static Uint8List secureRandom(int length) {
    return Uint8List.fromList(
        List.generate(length, (i) => Random.secure().nextInt(256)));
  }

  static Future stretch(var input, int mode ) async {
    final _storage = const FlutterSecureStorage();
    final pbkdf2 = cry.Pbkdf2(
      macAlgorithm: cry.Hmac.sha256(),
      iterations: 100000,
      bits: 256,
    );

    // Password we want to hash
    final secretKey = cry.SecretKey(convert.utf8.encode(input));

    // Salt
    final nonce;
    if (await _storage.containsKey(key: "SALT") && mode == 0) 
    {
      nonce = base64Decode((await _storage.read(key: "SALT"))!);
    }
    else
    {
      nonce = secureRandom(16);
      await _storage.write(key: 'SALT', value: base64Encode(nonce));
    }

    // Calculate a hash that can be stored
    final newSecretKey = await pbkdf2.deriveKey(
      secretKey: secretKey,
      nonce: nonce
    );

    final newSecretKeyBytes = await newSecretKey.extractBytes();
    print('Result: $newSecretKeyBytes');

    return base64Encode(newSecretKeyBytes);
  }
}