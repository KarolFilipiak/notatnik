// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:notatnik/functions.dart';

class Notepad extends StatefulWidget {
  final String curr_hash;

  const Notepad({Key? key, required String this.curr_hash}) : super(key: key);

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
  String hash = '';

  void clear_input()
  {
    setState(()  {
      notepadTextControl.clear();
      notepad = '';
    });
  }

  void getlogin() async {
    if (await _storage.containsKey(key: "login")) {
      login = (await _storage.read(key: "login"))!;
    }

    setState(() {
      _isLoading1 = false;
    });
    
  }

  void getnotes() async {
    setState(() {
      hash = widget.curr_hash;
    });
    if(await _storage.containsKey(key: "notes"))
      notepad = await F.decryptWithHash((await _storage.read(key: "notes"))!,hash);
    setState(() {
      notepadTextControl.text = notepad;
      _isLoading2 = false;
    });
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
                        notepad = await F.encryptWithHash(notepad,hash);
                        notepad = await F.decryptWithHash(notepad,hash);
                        setState(() {
                          notepadTextControl.text = notepad;
                        });
                        //print(notepad);

                        F.snack(context, "Note saved successfully", "top_lightgreen");
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
                        clear_input();
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