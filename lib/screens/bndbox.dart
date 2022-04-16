import 'dart:async';
import 'package:drushti/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';
import 'dart:math' as math;
import 'models.dart';
import 'package:tflite/tflite.dart';

class BndBox extends StatefulWidget {
  final List<dynamic> results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;
  final String model;
  final String detection;

  String language = "", voice = "", abb = "";

  BndBox(this.results, this.previewH, this.previewW, this.screenH, this.screenW,
      this.model, this.detection, {Key? key}) : super(key: key);

  @override
  _BndBox createState() => _BndBox();
}

class _BndBox extends State<BndBox> {
  final FlutterTts flutterTts = FlutterTts();
  final translator = GoogleTranslator();
  dynamic _timer;

  String? speak = "";
  String? prevString;
  String language = "";
  String voice = "";
  String abb = "";

  @override
  void initState() {

    super.initState();
    loadModel().then((val) {
      setState(() {
        //_busy = false;
      });
    });
    checkLanguage();
    _timer = Timer.periodic(
        const Duration(seconds: 3), (Timer timer) => _speak());
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop().then((value) => _timer.cancel());
  }

  stop() async {
   await flutterTts.stop().then((value) => null);
  }

  loadModel() async {
    Tflite.close();
    String? res = await Tflite.loadModel(
      model: widget.detection == "object"
          ? objectModelFileName
          : cashModelFileName,
      labels: widget.detection == "object"
          ? objectLabelFileName
          : cashLabelFileName,
    );
  }

  Future<void> checkLanguage() async {
    // await flutterTts.getVoices.then((print));
    // await flutterTts.getLanguages.then((print));
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("language") == null) {
      sharedPreferences.setString("language", engLanguage);
      language = (sharedPreferences.getString("language"))!;
    }
    if (sharedPreferences.getString("voice") == null) {
      sharedPreferences.setString("voice", engVoice);
      voice = (sharedPreferences.getString("voice"))!;
    }
    if (sharedPreferences.getString("abbreviation") == null) {
      sharedPreferences.setString("abbreviation", engAbbreviation);
      abb = (sharedPreferences.getString("abbreviation"))!;
      flutterTts
          .setLanguage(sharedPreferences.getString("language").toString())
          .then((value) {
        flutterTts.setVoice({
          sharedPreferences.getString("voice").toString().toString():
          sharedPreferences.getString("language").toString().toString()
        }).then((value) {
          print;
        });
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _renderBoxes() {
      return widget.results.map((re) {
        var _x = re["rect"]["x"];
        var _w = re["rect"]["w"];
        var _y = re["rect"]["y"];
        var _h = re["rect"]["h"];
        dynamic scaleW, scaleH, x, y, w, h;

        if (widget.screenH / widget.screenW >
            widget.previewH / widget.previewW) {
          scaleW = widget.screenH / widget.previewH * widget.previewW;
          scaleH = widget.screenH;
          var difW = (scaleW - widget.screenW) / scaleW;
          x = (_x - difW / 2) * scaleW;
          w = _w * scaleW;
          if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
          y = _y * scaleH;
          h = _h * scaleH;
        } else {
          scaleH = widget.screenW / widget.previewW * widget.previewH;
          scaleW = widget.screenW;
          var difH = (scaleH - widget.screenH) / scaleH;
          x = _x * scaleW;
          w = _w * scaleW;
          y = (_y - difH / 2) * scaleH;
          h = _h * scaleH;
          if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
        }

        speak = re["detectedClass"];

        return Positioned(
          left: math.max(0, x),
          top: math.max(0, y),
          width: w,
          height: h,
          child: Container(
            padding: const EdgeInsets.only(top: 5.0, left: 5.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromRGBO(37, 213, 253, 1.0),
                width: 3.0,
              ),
            ),
            child: Text(
              "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
              style: const TextStyle(
                color: Color.fromRGBO(37, 213, 253, 1.0),
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList();
    }

    List<Widget> _renderStrings() {
      double offset = -10;
      return widget.results.map((re) {
       // print(re.toString());
        offset = offset + 14;
        //print(re["label"]);
        if (re["confidence"] > 0.95) {
          speak = re["label"];
        }
        return Positioned(
          top: 50,
          left: 20,
          //top: 100,
          width: widget.screenW,
          height: widget.screenH,
          child: Text(
            "\n${re["label"]} ${(re["confidence"] * 100).toStringAsFixed(0)} %\n\n",
            style: const TextStyle(
              color: Color.fromRGBO(37, 213, 253, 1.0),
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList();
    }

    return Stack(
      children: widget.model == mobilenet ? _renderStrings() : _renderBoxes(),
    );
  }

  Future _speak() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await flutterTts.setLanguage(sp.getString("language").toString());
    translator
        .translate(speak!, to: sp.getString("abbreviation").toString())
        .then((value) {
      if(speak != null && speak != prevString ) {
        prevString = speak;
        flutterTts.speak(value.toString()).then(print);
      }
      else {
        null;
      }
    });
  }
}
