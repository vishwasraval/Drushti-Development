import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:vibration/vibration.dart';


class ObjectPage {
  static XFile ? currImage;
  static BuildContext ?context;

  static List _output=[];

  static late String language,voice,abb;
  static final FlutterTts flutterTts = FlutterTts();

  static void objectDetect(BuildContext buildContext, XFile img) {
    loadModel().then((value) {
      // setState(() {});
    });
    context = buildContext;
    currImage = img;
    speakCurrencyValue();
  }

  static classifyObject(XFile image) async {
    // SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    // language=( sharedPreferences.getString("language"))!;
    // voice=( sharedPreferences.getString("voice"))!;
    // abb=( sharedPreferences.getString("abbreviation"))!;

    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 7,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    // print("This is the $output");
    // print("This is the ${output![0]['label']}");
    dynamic label;
    for(int i=0;i<output!.length;i++) {
      label+= output[i]['label'];
    }
    //print(label.runtimeType);
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(amplitude: 500, duration: 200);
    }
    _speak(label);
    _output = output;
    showCaptionDialog(label, image);
  }

  static loadModel() async {
    await Tflite.loadModel(
      model: 'assets/ssd_mobilenet.tflite',
      labels: 'assets/ssd_mobilenet.txt',
    );
  }

  static speakCurrencyValue() {
    classifyObject(currImage!);
  }

  static Future _speak(String output) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(amplitude: 500, duration: 200);
    }
    final translator=GoogleTranslator();
    // await flutterTts.speak(speak);
    var res=await translator.translate(output); //from: 'en',to:abb
    await flutterTts.speak(res.toString());
  }

  static Future<void> showCaptionDialog(String text, XFile picture) async {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: const Text('Object Identification'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                       SizedBox(
                        width: 300.0,
                        height: 420.0,
                        //decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16.0))),
                        child: ElevatedButton(
                          onPressed: () {
                            _speak(text);
                          },style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(10.0),
                          primary: HexColor('e56b6f'),
                          elevation: 5.0,
                          shape:  RoundedRectangleBorder(
                              borderRadius:  BorderRadius.circular(16.0)),
                        ),

                          child: const Text(
                            'Replay',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),

                        ),
                      ),
                       const SizedBox(
                        width: 300.0,
                        height: 20,
                      ),
                       Image.file(File(picture.path)),
                      const SizedBox(width: 20),
                       Text(text),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context!,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

  static Future<void> _stopTts() async {
    await flutterTts.stop();
  }
}

