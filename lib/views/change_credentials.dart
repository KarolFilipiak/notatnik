import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:encrypt/encrypt.dart' as enc;

import 'package:flutter/foundation.dart';
import 'dart:convert' as convert;
import 'dart:math';
import 'package:pointycastle/pointycastle.dart';
import 'package:notatnik/encrypted.dart';

class Credentials extends StatefulWidget {
  final String curr_hash;

  const Credentials({Key? key, required this.curr_hash}) : super(key: key);

  @override
  State<Credentials> createState() => _CredentialsState();
}

class _CredentialsState extends State<Credentials> {
  final loginTextControl = TextEditingController();
  final passwordTextControl = TextEditingController();
  final _storage = const FlutterSecureStorage();
  String login = '';
  String pass = '';
  

  static Uint8List secureRandom(int length) {
    return Uint8List.fromList(
        List.generate(length, (i) => Random.secure().nextInt(256)));
  }

  Future<String> decryptWithHash (final toDecrypt, String hash) async {
    print("decode_in");
    if (await _storage.containsKey(key: "IV") && ((await _storage.read(key: "IV"))!.isNotEmpty) && await _storage.containsKey(key: "KEY") && ((await _storage.read(key: "KEY"))!.isNotEmpty))
    {
      final iv_in = (await _storage.read(key: "IV"))!;
      final iv = enc.IV.fromBase64(iv_in);
      print("decode_code");

      final key_in = (await _storage.read(key: "KEY"))!;
      final key = enc.Key.fromBase64(key_in);

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

  Future<void> encryptWithHash(String toEncrypt, String hash) async {
    // final salt = secureRandom(32);
    // final hashPassword = hash;

    // final key = secureRandom(32);
    // final iv = secureRandom(12);

    // final encrypter = enc.Encrypter(AES(key));

    // String note = '';

    // Encrypted encrypted = Encrypted(
    //     salt: convert.base64.encode(salt),
    //     iv: convert.base64.encode(iv),
    //     note: Encryption.encryptChaCha20Poly1305(
    //         'Enter your message', key, iv));
    
    // await _storage.write(key: 'data', value: Encrypted.serialize(encrypted));
    
    // await _storage.write(key: 'IV', value: convert.base64.encode(iv));
    
    // await _storage.write(key: 'KEY', value: convert.base64.encode(key));
    
    // await _storage.write(key: 'SALT', value: convert.base64.encode(salt));

    final key = enc.Key.fromBase16(hash);
    final iv = enc.IV.fromSecureRandom(16);
    final macValue = Uint8List.fromList(utf8.encode(hash));

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ctr));

    final encrypted = encrypter.encrypt(toEncrypt, iv: iv);

    print("IV: ${iv.base64}");
    print("Key: ${key.base64}");

    await _storage.write(key: 'IV', value: iv.base64);
    await _storage.write(key: 'KEY', value: key.base64);
    await _storage.write(key: 'notes', value: encrypted.base64);
    
  }


  String decode(String ciphertext){
    String plaintext = '';
    if (ciphertext.isNotEmpty)
      plaintext = ciphertext + ''; //TODO: deszyfracja szyfrogramu
    return plaintext;
  }

  String encode(String plaintext){
    String ciphertext = '';
    if (plaintext.isNotEmpty)
      ciphertext = plaintext + '';  //TODO: szyfracja tekstu jawnego
    return ciphertext;
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_add),
            const SizedBox(width: 10),
            const Text("Edit credentials"),
            const SizedBox(width: 10),
            const Icon(Icons.note_add),
            const SizedBox(width: 60)
          ],
        ),
        backgroundColor: Color.fromARGB(255, 89, 7, 121),
      ),
      backgroundColor: Color.fromARGB(255, 224, 157, 245),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                "Change your credentials here and press the button to save changes", 
                maxLines: null,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: 
                  FontWeight.bold, fontSize: 20, 
                  color: Color.fromARGB(255, 125, 125, 125)
                )
              ),
            ),
            const SizedBox(
                height: 20,
            ),
            SizedBox(
                width: 150,
                height: 40,
                child: TextField(
                  onChanged: (var value) {
                    setState(() {
                      login = value;
                    });
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Login",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 8, right: 8, bottom: 8)),
                  controller: loginTextControl,
                ),
              ),
              SizedBox(height: 5,),
              SizedBox(
                width: 150,
                height: 40,
                child: TextField(
                  obscureText: true,
                  onChanged: (var value) {
                    setState(() {
                      pass = value;
                    });
                  },
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Password",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                          left: 8, right: 8, bottom: 8)),
                  controller: passwordTextControl,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.005),
              ElevatedButton(
                    onPressed: () async {
                      if(login.isEmpty) {
                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                                "Please type new login",
                            backgroundColor: Colors.redAccent,
                            ),
                        );
                      }
                      else if (login.length < 2) {
                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                                "Login should consist of at least 2 letters",
                            backgroundColor: Colors.redAccent,
                            ),
                        );
                      }
                      else if (pass.isEmpty) {
                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                                "Please type new password",
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                      else if (pass.length < 2) {
                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                                "Password should consist of at least 2 letters",
                            backgroundColor: Colors.redAccent,
                            ),
                        );
                      }
                      else {
                        String note = '';
                        String hash = '';
                        
                        
                        if(await _storage.containsKey(key: "hash") && ((await _storage.read(key: "hash"))!.isNotEmpty) && ((await _storage.read(key: "hash"))! != ''))
                        {
                          hash = (await _storage.read(key: "hash"))!;
                        }
                        
                        if (await _storage.containsKey(key: "notes") && ((await _storage.read(key: "notes"))!.isNotEmpty) && ((await _storage.read(key: "notes"))! != '') && await _storage.containsKey(key: "hash") && ((await _storage.read(key: "hash"))!.isNotEmpty) && ((await _storage.read(key: "hash"))! != ''))
                        {
                          note = (await _storage.read(key: "notes"))!;
                          note = await decryptWithHash(note,hash);
                        }

                        var bytes = utf8.encode(login[0]+pass+login+pass[1]); // data being hashed
                        String digest = sha256.convert(bytes).toString();
                        print("Digest as hex string: $digest");

                        await _storage.write(key: 'hash', value: digest);

                        if (note != '')
                        {
                          await encryptWithHash(note, digest);
                        }
                        else 
                        {
                          final key = enc.Key.fromBase16(digest);
                          final iv = enc.IV.fromSecureRandom(16);

                          await _storage.write(key: 'IV', value: iv.base64);
                          await _storage.write(key: 'KEY', value: key.base64);

                          print(key.length);

                        }
                        
                        

                        setState(()  {
                            loginTextControl.clear();
                            passwordTextControl.clear();
                            login = '';
                            pass = '';
                          }
                        );

                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                                "Credentials changed successfully",
                            backgroundColor: Colors.greenAccent,
                            ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 241, 69, 247),
                    ), 
                    child: const Text('CHANGE CREDENTIALS')
                  ),
          ],
        ),
      )
      
    );
  }
}