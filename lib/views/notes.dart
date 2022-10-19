import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  bool _isLoading = true;

  void getlogin() async {
    if (await _storage.containsKey(key: "login")) {
      login = (await _storage.read(key: "login"))!;
    }
    
  }

  void getnotes() async {
    if(await _storage.containsKey(key: "notes"))
      notepad = decode((await _storage.read(key: "notes"))!);
    setState(() {
      notepadTextControl.text = notepad;
    });
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
  void initState() {
    super.initState();
    getlogin();
    getnotes();

    setState(() {
      _isLoading = false;
    });
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
      body:  _isLoading 
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
                        notepad = encode(notepad);
                        _storage.write(key: "notes", value: notepad);
                        setState(() {
                          notepadTextControl.text = notepad;
                        });
                        //print(notepad);
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