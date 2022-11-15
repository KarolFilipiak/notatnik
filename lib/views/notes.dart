import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:encrypt/encrypt.dart' as enc;

class Notepad extends StatefulWidget {

  const Notepad({Key? key}) : super(key: key);

  @override
  State<Notepad> createState() => _NotepadState();
}

class _NotepadState extends State<Notepad> {
  final notepadTextControl = TextEditingController();
  final _storage = const FlutterSecureStorage();
  String notepad = '';
  String login = '';
  bool _isLoading1 = true;
  bool _isLoading2 = true;

  void getlogin() async {
    if (await _storage.containsKey(key: "login")) {
      login = (await _storage.read(key: "login"))!;
    }

    setState(() {
      _isLoading1 = false;
    });
    
  }

  void getnotes() async {
    if(await _storage.containsKey(key: "notes"))
      notepad = await decode((await _storage.read(key: "notes"))!);
    setState(() {
      notepadTextControl.text = notepad;
      _isLoading2 = false;
    });
  }

  Future decode(final ciphertext) async{
    //String plaintext = '';
    print("decode_in: ${ciphertext}");
    if (await _storage.containsKey(key: "IV") && ((await _storage.read(key: "IV"))!.isNotEmpty) && await _storage.containsKey(key: "KEY") && ((await _storage.read(key: "KEY"))!.isNotEmpty) && (ciphertext != ''))
    {
      final iv_in = (await _storage.read(key: "IV"))!;
      final iv = enc.IV.fromBase64(iv_in);
      print("decode_code");

      final key_in = (await _storage.read(key: "KEY"))!;
      final key = enc.Key.fromBase64(key_in);

      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ctr));
      final encrypted = enc.Encrypted.fromBase64(ciphertext);


      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      return decrypted;

    }
    else
    {
      print("decode_nocode");
      return '';
    }
    //if (ciphertext.isNotEmpty)
    //  plaintext = ciphertext + ''; //TODO: deszyfracja szyfrogramu
    //return plaintext;
  }

  Future encode(String plaintext) async {
    print("encode_in");
    if (await _storage.containsKey(key: "IV") && ((await _storage.read(key: "IV"))!.isNotEmpty) && await _storage.containsKey(key: "KEY") && ((await _storage.read(key: "KEY"))!.isNotEmpty) && (plaintext != ''))
    {
      final iv_in = (await _storage.read(key: "IV"))!;
      final iv = enc.IV.fromBase64(iv_in);
    
      print("encode_code");
      final key_in = (await _storage.read(key: "KEY"))!;
      final key = enc.Key.fromBase64(key_in);

      final encrypter = enc.Encrypter(enc.AES(key, mode: enc.AESMode.ctr));

      final encrypted = encrypter.encrypt(plaintext, iv: iv);

      return encrypted.base64;
    }
    else
    {
      print("encode_nocode");
      return '';
    }
    // String ciphertext = '';
    // if (plaintext.isNotEmpty)
    //   ciphertext = plaintext + '';  //TODO: szyfracja tekstu jawnego
    // return ciphertext;
  }

  @override
  void initState() {
    super.initState();
    getlogin();
    getnotes();

    
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
            const Text("Edit note"),
            const SizedBox(width: 10),
            const Icon(Icons.note_add),
            const SizedBox(width: 60)
          ],
        ),
        backgroundColor: Color.fromARGB(255, 89, 7, 121),
      ),
      backgroundColor: Color.fromARGB(255, 224, 157, 245),
      body:  (_isLoading1 || _isLoading2) 
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Your notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
              Text('Logged as: $login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 20),
              SizedBox(
                  width: MediaQuery.of(context).size.width*0.95,
                  height: MediaQuery.of(context).size.height*0.6,
                  child: TextField(
                    onChanged: (var value) {
                      setState(() {
                        notepad = value;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Your notes will appear here",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(
                        left: 8, right: 8, bottom: 8
                      )
                    ),
                    controller: notepadTextControl,
                    maxLines: null,
                    expands: true,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      
                      onPressed: () async {
                        notepad = await encode(notepad);
                        _storage.write(key: "notes", value: notepad);
                        notepad = await decode(notepad);
                        setState(() {
                          notepadTextControl.text = notepad;
                        });
                        //print(notepad);

                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                                "Note saved successfully",
                            backgroundColor: Colors.greenAccent,
                            ),
                        );
                      },
                      style: ElevatedButton.styleFrom(

                        primary: const Color.fromARGB(255, 241, 69, 247),
                      ), 
                      child: const Text('SAVE', style: TextStyle(color: Color.fromARGB(200, 255, 255, 255)),)
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*0.01),
                    ElevatedButton(
                      onPressed: () async {
                        getnotes();
                        //print(notepad);
                      }, 
                      style: ElevatedButton.styleFrom(

                        primary: const Color.fromARGB(255, 241, 69, 247),
                      ),
                      child: const Text('RESTORE', style: TextStyle(color: Color.fromARGB(200, 255, 255, 255)))
                      
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*0.01),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          notepadTextControl.clear();
                          notepad = '';
                        });
                      }, 
                      style: ElevatedButton.styleFrom(

                        primary: const Color.fromARGB(255, 241, 69, 247),
                      ),
                      child: const Text('CLEAR', style: TextStyle(color: Color.fromARGB(200, 255, 255, 255)))
                    )
                    
                    
                    
                  ],
                ),
            ],
          )
        ),
    );
  }
}