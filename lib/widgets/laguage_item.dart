import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageRowModel {
  bool selected;
  String title;
  String voice;
  String language;
  String abbreviation;

  LanguageRowModel(
      {required this.selected,
      required this.title,
      required this.voice,
      required this.language,
      required this.abbreviation});
}

class LanguageRow extends StatelessWidget {
  final LanguageRowModel model;
  final FlutterTts _flutterTts = new FlutterTts();

  LanguageRow(this.model, {Key? key}) : super(key: key);

  void changeLangugae() async {
    SharedPreferences _sharedPreferences =
    await SharedPreferences.getInstance();
    await _sharedPreferences.setString("language", model.language);
    await _sharedPreferences.setString("voice", model.voice);
    await _sharedPreferences
        .setString("abbreviation", model.abbreviation)
        .then((value) {
      _flutterTts.setLanguage(model.language.toString()).then((value) {
        _flutterTts.setVoice({model.voice: model.language}).then((value) {
          _flutterTts.speak("Language changed to ${model.title}");
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only( top: 3.0, bottom: 3.0),
      child: ListTile(
// I have used my own CustomText class to customise TextWidget.
        title: Text(
          model.title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          changeLangugae();
          model.selected = !model.selected;
        },
      ),
    );
  }
}
