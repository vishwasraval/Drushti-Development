import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class sosDialog {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();

  Future<void> sosDialogBox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title:
                  const Text("Enter phone numbers you would like to contact"),
              content: SingleChildScrollView(
                  child: ListBody(children: <Widget>[
                TextFormField(
                  controller: _controller4,
                  decoration: const InputDecoration(
                    labelText: 'Enter your name:',
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _controller1,
                  decoration: const InputDecoration(
                    labelText: 'Enter phone number 1:',
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _controller2,
                  decoration: const InputDecoration(
                    labelText: 'Enter phone number 2:',
                  ),
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _controller3,
                  decoration: const InputDecoration(
                    labelText: 'Enter phone number 3:',
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setNumbers((_controller1.text), (_controller2.text),
                        (_controller3.text), _controller4.text, context);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: HexColor('eaac8b'),
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                  ),
                  child: const Text(
                    "Save Information",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                )
              ])));
        });
  }

  Future<void> setNumbers(
      String n1, String n2, String n3, String n, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // print(n1);
    // print(n2);
    // print(n3);
    await prefs.setString('n1', n1);
    await prefs.setString('n2', n2);
    await prefs.setString('n3', n3);
    await prefs.setString('name', n).then((value) => Navigator.pop(context));
  }
}
