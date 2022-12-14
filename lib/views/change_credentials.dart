// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:notatnik/functions.dart';

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
  String hash = '';
  
  @override
  void initState() {
    super.initState();
    hash = widget.curr_hash;
  }

  void clear_input()
  {
    setState(()  {
      loginTextControl.clear();
      passwordTextControl.clear();
      login = '';
      pass = '';
    });
  }

  Future<String> decryptWithHash (final toDecrypt, String hash) async {
    print("decode_in");
    if (await _storage.containsKey(key: "IV", aOptions: O.getAndroidOptions()) && ((await _storage.read(key: "IV", aOptions: O.getAndroidOptions()))!.isNotEmpty) && await _storage.containsKey(key: "KEY", aOptions: O.getAndroidOptions()) && ((await _storage.read(key: "KEY", aOptions: O.getAndroidOptions()))!.isNotEmpty))
    {
      final iv_in = (await _storage.read(key: "IV", aOptions: O.getAndroidOptions()))!;
      final iv = enc.IV.fromBase64(iv_in);
      print("decode_code");

      final key_in = (await _storage.read(key: "KEY", aOptions: O.getAndroidOptions()))!;
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
    final key = enc.Key.fromBase64(hash);
    final iv = enc.IV.fromSecureRandom(16);
    final macValue = Uint8List.fromList(utf8.encode(hash));

    final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ctr));

    final encrypted = encrypter.encrypt(toEncrypt, iv: iv);

    print("IV: ${iv.base64}");
    print("Key: ${key.base64}");

    await _storage.write(key: 'IV', value: iv.base64, aOptions: O.getAndroidOptions());
    await _storage.write(key: 'notes', value: encrypted.base64, aOptions: O.getAndroidOptions());
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
                        F.snack(context, "Please type your login", "top_lightred");
                      }
                      else if (login.length < 2) {
                        F.snack(context, "Login consists of at least 2 letters", "top_lightred");
                      }
                      else if (pass.isEmpty) {
                        F.snack(context, "Please type your password", "top_lightred");
                      }
                      else if (pass.length < 2) {
                        F.snack(context, "Password consists of at least 2 letters", "top_lightred");
                      }
                      else {
                        String note = '';
                        
                        
                        if (await _storage.containsKey(key: "notes", aOptions: O.getAndroidOptions()) && ((await _storage.read(key: "notes", aOptions: O.getAndroidOptions()))!.isNotEmpty) && ((await _storage.read(key: "notes", aOptions: O.getAndroidOptions()))! != ''))
                        {
                          note = (await _storage.read(key: "notes", aOptions: O.getAndroidOptions()))!;
                          note = await F.decryptWithHash(note,hash);
                        }

                        String digest = await F.makeHash1(login, pass);
                        print("Stretched: ${digest}");
                        var toSecSt = await F.stretch(digest,0);
                        await _storage.write(key: 'hash', value: toSecSt, aOptions: O.getAndroidOptions());
                        setState(() {
                          hash = digest;
                        });


                        if (note != '')
                        {
                          await F.encryptWithHash(note, digest);
                        }
                        else 
                        {
                          F.generateIv();
                        }

                        if (await _storage.containsKey(key: "combo_notes", aOptions: O.getAndroidOptions()) && ((await _storage.read(key: "combo_notes", aOptions: O.getAndroidOptions()))!.isNotEmpty) && ((await _storage.read(key: "combo_notes", aOptions: O.getAndroidOptions()))! != ''))
                        {
                          note = (await _storage.read(key: "combo_notes", aOptions: O.getAndroidOptions()))!;
                          note = await F.combo_decrypt(note);
                        }
                        digest = await F.combo_makeHash1(login, pass);
                        print("Stretched: ${digest}");
                        toSecSt = await F.combo_stretch(digest,0);
                        await _storage.write(key: 'combo_hash', value: toSecSt, aOptions: O.getAndroidOptions());
                        if (note != '')
                        {
                          await F.combo_encrypt(note);
                        }
                        else 
                        {
                          F.combo_generateIv();
                        }

                        clear_input();

                        F.snack(context, "Credentials changed successfully", "top_lightgreen");
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