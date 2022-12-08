
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locker/flutter_locker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:cryptography/cryptography.dart' as cry;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'dart:convert' as convert;

import 'package:top_snackbar_flutter/top_snack_bar.dart';

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

  static Future generateIv() async
  {
    final _storage = const FlutterSecureStorage();
    final iv = enc.IV.fromSecureRandom(16);
    
    await _storage.write(key: 'IV', value: iv.base64);
    
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

  static Future<bool> hasNote() async
  {
    final _storage = const FlutterSecureStorage();
    return await _storage.containsKey(key: "notes");
  }

  static Future encryptWithHash(String toEncrypt, String hash) async {
    final _storage = const FlutterSecureStorage();
    final key = enc.Key.fromBase64(hash);
    final iv = enc.IV.fromSecureRandom(16);

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ctr));

    print("IV: ${iv.base64}");
    print("Key: ${key.base64}");

    await _storage.write(key: 'IV', value: iv.base64);

    if (toEncrypt != '')
    {
      final encrypted = encrypter.encrypt(toEncrypt, iv: iv);
      await _storage.write(key: 'notes', value: encrypted.base64);

      return encrypted.base64;  
    }
    else
    {
      if (await _storage.containsKey(key: 'notes'))
        await _storage.delete(key: 'notes');
      return '';
    }

    
  }


  static Future<String> decryptWithHash (final toDecrypt, String hash) async {
    final _storage = const FlutterSecureStorage();
    print("decode_in");
    if (await _storage.containsKey(key: "IV") && ((await _storage.read(key: "IV"))!.isNotEmpty) && await _storage.containsKey(key: "notes") && ((await _storage.read(key: "notes"))!.isNotEmpty))
    {
      final iv_in = (await _storage.read(key: "IV"))!;
      final iv = enc.IV.fromBase64(iv_in);
      print("decode_code");

      final key = enc.Key.fromBase64(hash);

      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ctr));
      final encrypted = enc.Encrypted.fromBase64(toDecrypt);


      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      return decrypted;

    }
    else
    {
      print("decode_nocode");
      return '';
    }
  }

  static Future<bool> verifyCredentials(String log, String pas) async
  {
    final _storage = const FlutterSecureStorage();
    String digest = '';
    var bytes = utf8.encode(log[0]+pas+log+pas[1]); // data being hashed
    digest = sha256.convert(bytes).toString();
    digest = await stretch(digest,0);
    
    try {
      if (await _storage.containsKey(key: "IV") && ((await _storage.read(key: "IV"))!.isNotEmpty) && await hasNote())
      {
        final iv_in = (await _storage.read(key: "IV"))!;
        final iv = enc.IV.fromBase64(iv_in);
        print("decode_code");
        final key = enc.Key.fromBase64(digest);

        final toDecrypt = (await _storage.read(key: "notes"))!;

        final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ctr));
        final encrypted = enc.Encrypted.fromBase64(toDecrypt);

        return true;
      }
      else
      {
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<String> makeHash(String log, String pas) async
  {
    var bytes = utf8.encode(log[0]+pas+log+pas[1]); // data being hashed
    String digest = sha256.convert(bytes).toString();
    digest = await stretch(digest,0);
    return digest;
  }

  static Future<String> makeHash1(String log, String pas) async
  {
    var bytes = utf8.encode(log[0]+pas+log+pas[1]); // data being hashed
    String digest = sha256.convert(bytes).toString();
    digest = await stretch(digest,1);
    return digest;
  }

  static void snack(context, msg, mode)
  {
    if (mode == "top_red")
    {
      showTopSnackBar(
        context,
        CustomSnackBar.info(
          message:
              msg,
          backgroundColor: Color.fromARGB(255, 221, 22, 22),
        ),
        animationDuration: Duration(milliseconds: 800),
        displayDuration: Duration(milliseconds: 600)
      );
    } 
    else if (mode == "top_lightred")
    {
      showTopSnackBar(
        context,
        CustomSnackBar.info(
          message:
              msg,
          backgroundColor: Colors.redAccent,
        ),
        animationDuration: Duration(milliseconds: 800),
        displayDuration: Duration(milliseconds: 600)
      );
    }
    else if (mode == "top_lightgreen")
    {
      showTopSnackBar(
        context,
        CustomSnackBar.info(
          message:
              msg,
          backgroundColor: Colors.greenAccent,
          ),
        animationDuration: Duration(milliseconds: 800),
        displayDuration: Duration(milliseconds: 600)
      );
    }
    else if (mode == "bottom_green")
    {
      final snackBar = SnackBar(
        content: Text(msg),
        action: SnackBarAction(
          label: 'X',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    else if (mode == "bottom_red")
    {
      final snackBar = SnackBar(
        content: Text(msg),
        action: SnackBarAction(
          label: 'X',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    else 
    {
      final snackBar = SnackBar(
        content: Text(msg),
        action: SnackBarAction(
          label: 'X',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        )
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  static Future combo_generateIv() async
  {
    final _storage = const FlutterSecureStorage();
    final iv = enc.IV.fromSecureRandom(16);
    
    await _storage.write(key: 'combo_IV', value: iv.base64);
    
  }


  static Future combo_stretch(var input, int mode ) async {
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
    if (await _storage.containsKey(key: "combo_SALT") && mode == 0) 
    {
      nonce = base64Decode((await _storage.read(key: "combo_SALT"))!);
    }
    else
    {
      nonce = secureRandom(16);
      await _storage.write(key: 'combo_SALT', value: base64Encode(nonce));
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

  static Future<String> combo_makeHash(String log, String pas) async
  {
    var bytes = utf8.encode(log[0]+pas+log+pas[1]); // data being hashed
    String digest = sha256.convert(bytes).toString();
    digest = await combo_stretch(digest,0);
    return digest;
  }

  static Future<String> combo_makeHash1(String log, String pas) async
  {
    var bytes = utf8.encode(log[0]+pas+log+pas[1]); // data being hashed
    String digest = sha256.convert(bytes).toString();
    digest = await combo_stretch(digest,1);
    return digest;
  }

  static Future combo_encrypt(String toEncrypt) async {
    final _storage = const FlutterSecureStorage();
    final key = enc.Key.fromSecureRandom(32);
    final iv = enc.IV.fromSecureRandom(16);

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ctr));

    print("IV: ${iv.base64}");
    print("Key: ${key.base64}");

    await _storage.write(key: 'combo_IV', value: iv.base64);
    await _storage.write(key: 'combo_key', value: key.base64);

    if (toEncrypt != '')
    {
      final encrypted = encrypter.encrypt(toEncrypt, iv: iv);
      await _storage.write(key: 'combo_notes', value: encrypted.base64);

      return encrypted.base64;  
    }
    else
    {
      if (await _storage.containsKey(key: 'combo_notes'))
        await _storage.delete(key: 'combo_notes');
      return '';
    }

    
  }

  static Future<String> combo_decrypt(final toDecrypt) async
  {
    final _storage = FlutterSecureStorage();
    if (await _storage.containsKey(key: "combo_IV") && ((await _storage.read(key: "combo_IV"))!.isNotEmpty) && await _storage.containsKey(key: "combo_notes") && ((await _storage.read(key: "combo_notes"))!.isNotEmpty) && await _storage.containsKey(key: "combo_key") && ((await _storage.read(key: "combo_key"))!.isNotEmpty) )
    {
      final iv_in = (await _storage.read(key: "combo_IV"))!;
      final iv = enc.IV.fromBase64(iv_in);
      print("decode_code");

      final key = enc.Key.fromBase64((await _storage.read(key: "combo_key"))!);

      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ctr));
      final encrypted = enc.Encrypted.fromBase64(toDecrypt);


      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      return decrypted;

    }
    else
    {
      print("decode_nocode");
      return '';
    }
  }

  static Future<bool> combo_checkData(debug) async {
    final _storage = FlutterSecureStorage();
    if (debug) {
      print("CHECKED HASH: ${await _storage.read(key: 'combo_hash')}");
    }
    

    if (await _storage.containsKey(key: "combo_hash") && ((await _storage.read(key: "combo_hash"))!.isNotEmpty)) {
      return true;
    }
    else
    {
      return false;
    }
  }

  static Future<bool> combo_verifyCredentials(String log, String pas) async {
    final _storage = FlutterSecureStorage();
    String digest = '';
    String fromStorage = '';

    
    if (await _storage.containsKey(key: "combo_hash") && ((await _storage.read(key: "combo_hash"))!.isNotEmpty)) {
      digest = await combo_makeHash(log, pas);
      fromStorage = (await _storage.read(key: "combo_hash"))!;
    }


    if(digest == fromStorage)
    {
      await _storage.write(key: "login", value: log);
      return true;
    }
    else {
      return false;
    }
  }
}