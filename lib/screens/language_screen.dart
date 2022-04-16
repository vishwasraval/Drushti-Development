import 'package:drushti/widgets/laguage_item.dart';
import 'package:flutter/material.dart';
import 'package:drushti/utils/constants.dart';

class LanguageSelection {
  Future<void> optionsDialogBox(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(

            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                //  const Padding(
                  //  padding: EdgeInsets.all(8.0),
                 // ),
                  LanguageRow(LanguageRowModel(
                      selected: true,
                      abbreviation: hindiAbbreviation,
                      language: hindiLanguage,
                      voice: hindiVoice,
                      title: "Hindi")),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  LanguageRow(LanguageRowModel(
                      selected: false,
                      abbreviation: gujaratiAbbreviation,
                      language: gujaratiLanguage,
                      voice: gujaratiVoice,
                      title: "Gujarati")),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  LanguageRow(LanguageRowModel(
                      selected: false,
                      abbreviation: bengaliAbbreviation,
                      language: bengaliLanguage,
                      voice: bengaliVoice,
                      title: "Bengali")),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  LanguageRow(LanguageRowModel(
                      selected: false,
                      abbreviation: kannadaAbbreviation,
                      language: kannadaLanguage,
                      voice: kannadaVoice,
                      title: "Kannada")),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  LanguageRow(LanguageRowModel(
                      selected: false,
                      abbreviation: tamilAbbreviation,
                      language: tamilLanguage,
                      voice: tamilVoice,
                      title: "Tamil")),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  LanguageRow(LanguageRowModel(
                      selected: false,
                      abbreviation: teleguAbbreviation,
                      language: teleguLanguage,
                      voice: teleguVoice,
                      title: "Telegu")),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  LanguageRow(LanguageRowModel(
                      selected: false,
                      abbreviation: engAbbreviation,
                      language: engLanguage,
                      voice: engVoice,
                      title: "English")),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  LanguageRow(LanguageRowModel(
                      selected: false,
                      abbreviation: malayalamAbbreviation,
                      language: malayalamLanguage,
                      voice: malayalamVoice,
                      title: "Malayalam")),
                ],
              ),
            ),
          );
        });
  }
}
