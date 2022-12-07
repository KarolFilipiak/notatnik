import 'package:flutter/material.dart';
import 'package:flutter_locker/flutter_locker.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:notatnik/functions.dart';

class Fingerpad extends StatefulWidget {
  Fingerpad({Key? key}) : super(key: key);

  @override
  State<Fingerpad> createState() => _FingerpadState();
}

class _FingerpadState extends State<Fingerpad> {
  final notepadTextControl = TextEditingController();
  String notepad = '';
  bool _isLoading = true;

  Future<void> _saveSecret() async {
    try {
      if (notepad != '')
      {
        try {
          await FlutterLocker.save(
            SaveSecretRequest(
                key: 'notes',
                secret: notepad,
                androidPrompt: AndroidPrompt(
                    title: 'Authenticate',
                    cancelLabel: 'Cancel',
                    descriptionLabel: 'Please authenticate to save note')),
          );

          F.snack(context, "Note saved successfully", "top_lightgreen");
          
        } on LockerException catch(e) {
          if(e.reason == LockerExceptionReason.authenticationFailed || e.reason == LockerExceptionReason.authenticationCanceled) {
            F.snack(context, "Saving failed", "top_red");
          }
        } on Exception catch (e) {
          F.snack(context, "Saving failed", "top_red");
        } catch(e) {
          F.snack(context, "Saving failed", "top_red");
        }
      }
      else 
      {
        try {
          await FlutterLocker.save(
            SaveSecretRequest(
                key: 'notes',
                secret: 'notepad',
                androidPrompt: AndroidPrompt(
                    title: 'Authenticate',
                    cancelLabel: 'Cancel',
                    descriptionLabel: 'Please authenticate to save note')),
          );
          await FlutterLocker.delete('notes');

          F.snack(context, "Note saved successfully", "top_lightgreen");

        } on LockerException catch (e) {
          if (e.reason == LockerExceptionReason.secretNotFound){}
          else 
          {
            F.snack(context, "Saving failed", "top_red");
          }
        } on Exception catch (e) {
          F.snack(context, "Saving failed", "top_red");
        } catch (e) {
          F.snack(context, "Saving failed", "top_red");
        } 
      }
    } on Exception catch (exception) {
      F.snack(context, "Saving interrupted", "top_red");
    }
  }

  Future<void> _retrieveSecret() async {
    try {
      final retrieved = await FlutterLocker.retrieve(RetrieveSecretRequest(
          key: 'notes',
          androidPrompt: AndroidPrompt(
              title: 'Authenticate',
              cancelLabel: 'Cancel',
              descriptionLabel: 'Please authenticate to get note'),
          iOsPrompt: IOsPrompt(touchIdText: 'Authenticate')));

      setState(() {
        notepad = retrieved;
        notepadTextControl.text = retrieved;
      });
      
    } on LockerException catch(e) {
      if (e.reason == LockerExceptionReason.secretNotFound) {
        try {
          await FlutterLocker.save(
            SaveSecretRequest(
                key: 'notes',
                secret: 'notepad',
                androidPrompt: AndroidPrompt(
                    title: 'Authenticate',
                    cancelLabel: 'Cancel',
                    descriptionLabel: 'Please authenticate to save note')),
          );
          await FlutterLocker.delete('notes');
          clear_input();
        } on LockerException catch (e) {
          if (e.reason == LockerExceptionReason.authenticationFailed || e.reason == LockerExceptionReason.authenticationCanceled)
          {
            F.snack(context, "Loading failed", "top_red");
          }
        }
      }
      else {
        F.snack(context, "Loading failed", "top_red");
      }
    } 
    on Exception catch (e) {
      F.snack(context, "Loading failed", "top_red");
    } catch (e) {
      F.snack(context, "Loading failed", "top_red");
    }
  }

  void clear_input()
  {
    setState(()  {
      notepadTextControl.clear();
      notepad = '';
    });
  }


  @override
  void initState() {
    super.initState();
    _retrieveSecret();
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
      body:  (_isLoading) 
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Your notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40)),
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
                        await _saveSecret();
                      },
                      style: ElevatedButton.styleFrom(

                        primary: const Color.fromARGB(255, 241, 69, 247),
                      ), 
                      child: const Text('SAVE', style: TextStyle(color: Color.fromARGB(200, 255, 255, 255)),)
                    ),
                    SizedBox(width: MediaQuery.of(context).size.width*0.01),
                    ElevatedButton(
                      onPressed: () async {
                        await _retrieveSecret();
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