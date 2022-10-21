import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    String hash = widget.curr_hash;
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
                        var bytes = utf8.encode(login[0]+pass+login+pass[1]); // data being hashed
                        String digest = sha256.convert(bytes).toString();
                        print("Digest as hex string: $digest");

                        await _storage.write(key: 'hash', value: digest);

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