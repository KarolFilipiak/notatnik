import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:notatnik/views/notes.dart';
import 'package:notatnik/views/change_credentials.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  Future<bool> verifyCredentials(String log, String pas) async {
    String digest = '';
    String fromStorage = '';

    var bytes = utf8.encode(login[0]+pass+login+pass[1]); // data being hashed
    
    if (await _storage.containsKey(key: "hash") && ((await _storage.read(key: "hash"))!.isNotEmpty)) {
      digest = sha256.convert(bytes).toString();
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text('Welcome! Please input your login and password and press one of the buttons to continue', maxLines: null, style: TextStyle(),),
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
                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                                "Please type your login",
                            backgroundColor: Colors.redAccent,
                            ),
                        );
                      }
                      else if (login.length < 2) {
                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                                "Login consists of at least 2 letters",
                            backgroundColor: Colors.redAccent,
                            ),
                        );
                      }
                      else if (pass.isEmpty) {
                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                                "Please type your password",
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                      else if (pass.length < 2) {
                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                                "Password consists of at least 2 letters",
                            backgroundColor: Colors.redAccent,
                            ),
                        );
                      }
                      else {

                        final bool verification = await verifyCredentials(login, pass);
                        
                        
                        if(verification){
                          setState(()  {  
                              loginTextControl.clear();
                              passwordTextControl.clear();
                              login = '';
                              pass = '';
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Notepad(),
                                )
                                
                              );
                            }
                          );
                          }
                          else {
                            showTopSnackBar(
                            context,
                            CustomSnackBar.info(
                              message:
                                  "Wrong credentials",
                              backgroundColor: Colors.redAccent,
                            ),
                            );
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
                      setState(() {
                        loginTextControl.clear();
                        passwordTextControl.clear();
                        login = '';
                        pass = '';
                      });
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
                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                                "Please type your login",
                            backgroundColor: Colors.redAccent,
                            ),
                        );
                      }
                      else if (login.length < 2) {
                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                                "Login consists of at least 2 letters",
                            backgroundColor: Colors.redAccent,
                            ),
                        );
                      }
                      else if (pass.isEmpty) {
                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                                "Please type your password",
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                      else if (pass.length < 2) {
                        showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                                "Password consists of at least 2 letters",
                            backgroundColor: Colors.redAccent,
                            ),
                        );
                      }
                      else {
                        final bool verification = await verifyCredentials(login, pass);
                        
                        if(verification){
                          setState(()  {
                            String l = login;
                            loginTextControl.clear();
                            passwordTextControl.clear();
                            login = '';
                            pass = '';
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Credentials(curr_hash: l,),
                              )
                              
                            );
                          });
                        }
                        else {
                          showTopSnackBar(
                          context,
                          CustomSnackBar.info(
                            message:
                                "Wrong credentials",
                            backgroundColor: Colors.redAccent,
                          ),
                          );
                        }
                      }
                    }, 
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 241, 69, 247),
                    ),
                    child: const Text('CHANGE PASSWORD')
                ),
            ]
            ),
          )
        ),
    );
  }
}