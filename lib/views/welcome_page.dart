// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:notatnik/views/notes_credentials.dart';
import 'package:notatnik/views/notes_fingerprint.dart';
import 'package:notatnik/views/notes_combo.dart';
import 'package:notatnik/views/change_credentials.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:notatnik/functions.dart';
import 'package:flutter_locker/flutter_locker.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final loginTextControl = TextEditingController();
  final passwordTextControl = TextEditingController();
  final _storage = const FlutterSecureStorage();
  String login = '';
  String pass = '';
  bool debug = false;

  void clear_input()
  {
    setState(()  {
      loginTextControl.clear();
      passwordTextControl.clear();
      login = '';
      pass = '';
    });
  }

  Future<bool> verifyCredentials(String log, String pas) async {
    String digest = '';
    String fromStorage = '';

    
    if (await _storage.containsKey(key: "hash") && ((await _storage.read(key: "hash"))!.isNotEmpty)) {
      digest = await F.makeHash(login, pass);
      fromStorage = (await _storage.read(key: "hash"))!;
    }

    if (debug) {
      print(await _storage.read(key: 'hash'));
      print(digest);
    }

    if(
      ((log=='aa' && pas=='bb') && debug) ||
      digest == fromStorage
      )
      {
        await _storage.write(key: "login", value: log);
        return true;
      }
    else {
      return false;
    }
  }

  Future<bool> checkData() async {
    if (debug) {
      print("CHECKED HASH: ${await _storage.read(key: 'hash')}");
    }
    setState(() {                  
    });

    if (await _storage.containsKey(key: "hash") && ((await _storage.read(key: "hash"))!.isNotEmpty)) {
      return true;
    }
    else
    {
      return false;
    }
  }

  Future<bool> _canAuthenticate() async {
    try {
      final canAuthenticate = await FlutterLocker.canAuthenticate();
      return canAuthenticate!;
    }
    catch (e) {
      return false;
    }
  }

  Future<void> _getToFingernotes() async {
    try {
      await FlutterLocker.save(SaveSecretRequest(
            key: 'checkfinger', 
            secret: 'x', 
            androidPrompt: AndroidPrompt(
                  title: 'Authenticate',
                  cancelLabel: 'Cancel',
                  descriptionLabel: 'Please authenticate to save note')
          ),);

      setState(() {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Fingerpad(),
          ));
      });
      
    } on LockerException catch (e) {
      if (e.reason == LockerExceptionReason.authenticationCanceled || e.reason == LockerExceptionReason.authenticationFailed)
      {
        F.snack(context, "Authentication failed", "top_red");
      }
    }
    on Exception {
      F.snack(context, "An error occured", "top_red");
    }
  }

  Future<void> _combo_getToFingernotes() async {
    try {
      await FlutterLocker.save(SaveSecretRequest(
            key: 'checkfinger', 
            secret: 'x', 
            androidPrompt: AndroidPrompt(
                  title: 'Authenticate',
                  cancelLabel: 'Cancel',
                  descriptionLabel: 'Please authenticate to save note')
          ),);

      setState(() {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Combopad(),
          ));
      });
      
    } on LockerException catch (e) {
      if (e.reason == LockerExceptionReason.authenticationCanceled || e.reason == LockerExceptionReason.authenticationFailed)
      {
        F.snack(context, "Authentication failed", "top_red");
      }
    }
    on Exception {
      F.snack(context, "An error occured", "top_red");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.note),
          const SizedBox(width: 10),
          GestureDetector(
            child: const Text(
              "WELCOME",
              style: TextStyle(
                  fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
            ),
            onDoubleTap: () async {
              Uri url = Uri.parse("https://youtu.be/dQw4w9WgXcQ");
              if (! await launchUrl(url)) print("link doesnt work");
            },
          ),
          const SizedBox(width: 10),
          const Icon(Icons.note),
        ]),
        backgroundColor: Color.fromARGB(255, 89, 7, 121),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Color.fromARGB(255, 224, 157, 245),
      body: Container(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text(
                          'Welcome! Please input your login and password and press one of the buttons to continue (or use fingerprint)', 
                          maxLines: null,
                          textAlign: TextAlign.center,
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
                      SizedBox(height: 10,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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

                                final bool verification = await verifyCredentials(login, pass);
                                final bool hasHash = await checkData();
                                //final bool hasHash = await F.hasNote();
                                
                                if(hasHash && verification){
                                  String hashed = await F.makeHash(login,pass);
                                  clear_input();
                                  setState(()  {  
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => Notepad(curr_hash: hashed,),
                                        )
                                        
                                      );
                                    }
                                  );
                                  }
                                  else if (!hasHash){
                                    F.snack(context, "Change your credentials first", "top_lightred");
                                  }
                                  else {
                                    F.snack(context, "Wrong credentials", "top_lightred");
                                  }
                              }
                            }, 
                            style: ElevatedButton.styleFrom(
                              primary: const Color.fromARGB(255, 241, 69, 247),
                            ),
                            child: const Text('LOG IN')
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width*0.02),
                          ElevatedButton(
                            onPressed: () async {
                              // setState(() {
                              //   loginTextControl.clear();
                              //   passwordTextControl.clear();
                              //   login = '';
                              //   pass = '';
                              // });
                              clear_input();
                            }, 
                            style: ElevatedButton.styleFrom(
                              primary: const Color.fromARGB(255, 241, 69, 247),
                            ),
                            child: const Text('CLEAR')
                          )
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height*0.001),
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
                              final bool verification = await verifyCredentials(login, pass);
                              
                              if(verification){
                                String hashed = await F.makeHash(login,pass);
                                clear_input();
                                setState(()  {
                                  String l = login;
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Credentials(curr_hash: hashed),
                                    )
                                    
                                  );
                                });
                              }
                              else {
                                F.snack(context, "Wrong credentials", "top_lightred");
                              }
                            }
                          }, 
                          style: ElevatedButton.styleFrom(
                            primary: const Color.fromARGB(255, 241, 69, 247),
                          ),
                          child: const Text('CHANGE PASSWORD')
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.005),
                        Text('OR',style: TextStyle(fontWeight: FontWeight.bold),),
                        SizedBox(height: MediaQuery.of(context).size.height*0.005),
                        IconButton(
                          icon: Icon(Icons.fingerprint), 
                          onPressed: () async {
                            await _canAuthenticate()
                            ? _getToFingernotes()
                            : F.snack(context, "Authentication method unavailable", "top_red");
                          },
                          iconSize: min(MediaQuery.of(context).size.height*0.1, MediaQuery.of(context).size.width*0.1),
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.005),
                        ElevatedButton(
                          onPressed: () async {
                            _storage.deleteAll();
                            try {
                              await FlutterLocker.delete('notes');
                            }
                            catch (e) {}
                            F.snack(context, "Data erased", "top_red");
                            clear_input();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromARGB(255, 240, 8, 8),
                          ),
                          child: const Text('RESET DATA')
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height*0.005),
                        Text('OR',style: TextStyle(fontWeight: FontWeight.bold),),
                        SizedBox(height: MediaQuery.of(context).size.height*0.005),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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

                                  final bool verification = await F.combo_verifyCredentials(login, pass);
                                  final bool hasHash = await F.combo_checkData(debug);
                                  //final bool hasHash = await F.hasNote();
                                  
                                  if(hasHash && verification){
                                    String hashed = await F.combo_makeHash(login,pass);
                                    clear_input();
                                    setState(()  {  
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => Combopad(),
                                          )
                                          
                                        );
                                      }
                                    );
                                  }
                                  else if (!hasHash){
                                    F.snack(context, "Change your credentials first", "top_lightred");
                                  }
                                  else {
                                    F.snack(context, "Wrong credentials", "top_lightred");
                                  }
                                }
                              }, 
                            style: ElevatedButton.styleFrom(
                              primary: const Color.fromARGB(255, 241, 69, 247),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('LOG IN'),
                                const Icon(Icons.lock_open),
                              ],
                            )
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width*0.02),
                          ElevatedButton(
                            onPressed: () async {
                              await _canAuthenticate()
                              ? _combo_getToFingernotes()
                              : F.snack(context, "Authentication method unavailable", "top_red");
                            },
                            style: ElevatedButton.styleFrom(
                              primary: const Color.fromARGB(255, 241, 69, 247),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('LOG IN'),
                                const Icon(Icons.fingerprint),
                              ],
                            ),
                          )
                          
                          ],
                        )
                    ]
                  ),
                ],
              )
          )
        ),
    );
  }
}