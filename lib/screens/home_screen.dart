import 'dart:async';
import 'package:drushti/screens/camera.dart';
import 'package:drushti/screens/color_detection_screen.dart';
import 'package:drushti/screens/custom_color_detection_screen.dart';
import 'package:drushti/screens/custom_currency_identifier_screen.dart';
import 'package:drushti/screens/custom_text_extraction_screen.dart';
import 'package:drushti/screens/language_screen.dart';
import 'package:drushti/screens/sos_screen.dart';
import 'package:drushti/screens/text_extraction_screen.dart';
import 'package:drushti/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:telephony/telephony.dart';
import 'package:translator/translator.dart';
import 'dart:math' as math;
import 'package:vibration/vibration.dart';
import 'bndbox.dart';
import 'camera.dart';
import 'currency_detection_screen.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const HomePage(this.cameras);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<dynamic> _recognitions = [];
  int _imageHeight = 0;
  int _imageWidth = 0;
  final String _model = "MobileNet";
  String language = "", voice = "", abb = "";

  final FlutterTts flutterTts = FlutterTts();
  final Telephony telephony = Telephony.instance;
  late GoogleTranslator translator = GoogleTranslator();
  final PageController _controller =
      PageController(initialPage: 0, keepPage: false);

  // Future getColorFromImage() async {
  //   final colorImage = await ImagePicker().pickImage(source: ImageSource.camera);
  //   setState(() {
  //   });
  //   if (colorImage != null) {
  //     ColorDetectionPage.colorDetect(context, colorImage);
  //     //ColorPage.currencyDetect(context, currImage);
  //   }
  // }

  Future getCurrFromImage() async {
    final currImage = await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {});
    if (currImage != null) {
      CurrencyDetectionPage.curencyDetect(context, currImage);
    }
  }

  // Future getTextFromImage() async {
  //   final textImage = await ImagePicker().pickImage(source: ImageSource.camera);
  //   setState(() {});
  //   if (textImage != null) {
  //     ocrDialog.openCamera(context, textImage);
  //   }
  // }

  // Future getObjectImage() async {
  //   final objImage = await ImagePicker().pickImage(source: ImageSource.camera);
  //   setState(() {
  //     _currImage = objImage;
  //   });
  //   if (objImage != null) {
  //     ObjectPage.objectDetect(context, objImage);
  //   }
  // }
  Future<void> checklanguage() async {
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
    }
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

  dynamic sosCount = 0;
  dynamic initTime;
  bool showcurr = false;
  bool shoobj = false;
  late bool isOpenForFirstTime = false;

  @override
  void initState() {
    super.initState();
    // loadModel();
    flutterTts.getDefaultEngine.then((value) {
      isAppOpenedFirstTime().then((value) async {
        checklanguage().then((value) {
          //print("labgugae check success");
        });
        SharedPreferences sp = await SharedPreferences.getInstance();
        if (value == false) {
          translator = GoogleTranslator();

          flutterTts
              .setLanguage(sp.getString("language").toString())
              .then((value) {
            flutterTts.setVoice({
              sp.getString("voice").toString().toString():
                  sp.getString("language").toString().toString()
            }).then((value) {
              dynamic speak = "Currency Identifier";
              translator
                  .translate(speak, to: sp.getString("abbreviation").toString())
                  .then((value) {
                flutterTts.speak(value.toString()).then(print);
              });
            });
          });
        } else {
          dynamic speak = "Language Selection";
          translator
              .translate(speak, to: sp.getString("abbreviation").toString())
              .then((value) {
            flutterTts.speak(value.toString()).then(print);
          });
        }
      });
    });

    ShakeDetector detector = ShakeDetector.waitForStart(onPhoneShake: () {
      if (sosCount == 0) {
        initTime = DateTime.now();
        ++sosCount;
      } else {
        if (DateTime.now().difference(initTime).inSeconds < 4) {
          ++sosCount;
          if (sosCount == 3) {
            sendSms();
            sosCount = 0;
          }
          //print(sosCount);
        } else {
          sosCount = 0;
          //print(sosCount);
        }
      }
    });

    detector.startListening();
  }

  void sendSms() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.requestPermission();
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.unableToDetermine) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          return Future.error('Location permissions are denied');
        }
      }
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? n1 = prefs.getString('n1');
    String? n2 = prefs.getString('n2');
    String? n3 = prefs.getString('n3');
    String? name = prefs.getString('name');
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    if (position == null) {
      position = (await Geolocator.getLastKnownPosition())!;
    } else {
      bool? permissionsGranted = await telephony.requestSmsPermissions;
      if (permissionsGranted == true) {
        String lat = (position.latitude).toString();
        String long = (position.longitude).toString();
        String alt = (position.altitude).toString();
        String speed = (position.speed).toString();
        String timestamp = (position.timestamp)!.toIso8601String();

        telephony.sendSms(
            to: n1!,
            message:
                "$name needs your help, last seen at: Latitude: $lat, Longitude: $long, Altitude: $alt, Speed: $speed, Time: $timestamp");
        telephony.sendSms(
            to: n2!,
            message:
                "$name needs your help, last seen at:  Latitude: $lat, Longitude: $long, Altitude: $alt, Speed: $speed, Time: $timestamp");
        telephony.sendSms(
            to: n3!,
            message:
                "$name needs your help, last seen at:  Latitude: $lat, Longitude: $long, Altitude: $alt, Speed: $speed, Time: $timestamp");
      }
      // bool? permissionsGranted = await telephony.requestSmsPermissions;
    }
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  sosDialog sd = sosDialog();
  LanguageSelection ls = LanguageSelection();

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
        body: isOpenForFirstTime == true
            ? showFirstTimePageView(context)
            : showPageView(context));
  }

  Widget showPageView(BuildContext context) {
    return PageView(
      padEnds: false,
      controller: _controller,
      onPageChanged: _speakPage,
      children: <Widget>[
        Container(
            child: Center(
                child: SizedBox.expand(
                    child: TextButton(
                        // onPressed: () => getCurrFromImage(),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>CurrencyIdentifierScreen(camera: widget.cameras.first)),
                        ),
                        child: const Text("Currency Identifier",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 27.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold))))),
            color: HexColor('eccc8b')),

        // showcurr == false
        //     ? Container(
        //     child: Center(
        //         child: SizedBox.expand(
        //             child: TextButton(
        //               // style: TextButton.styleFrom(
        //               //   backgroundColor: Colors.yellow[900],
        //               // ),
        //
        //                 onPressed: () {
        //                   setState(() {
        //                     showcurr = !showcurr;
        //                   });
        //                 },
        //                 child: const Text("Currency Detection",
        //                     textAlign: TextAlign.center,
        //                     style: TextStyle(
        //                         fontSize: 27.0,
        //                         color: Colors.white,
        //                         fontWeight: FontWeight.bold))))),
        //     color: HexColor('eccc8b'))
        //     : cashDetectionDialog(context, widget.cameras),
        shoobj == false
            ? Container(
                child: Center(
                    child: SizedBox.expand(
                        child: TextButton(
                            onPressed: () {
                              setState(() {
                                shoobj = !shoobj;
                              });
                            },
                            child: const Text("Object Detection",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 27.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))))),
                color: HexColor('ebbc8b'))
            : objectDetectionDialog(context, widget.cameras),
        Container(
            child: Center(
                child: SizedBox.expand(
                    child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>ColorIdentifierScreen(camera: widget.cameras.first)),
                            ),
                        child: const Text("Color Identifier",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 27.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold))))),
            color: HexColor('e56b6f')),

        Container(
            child: Center(
                child: SizedBox.expand(
                    child: TextButton(
                        // onPressed: () => getTextFromImage(),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>TextExtractionScreen(camera: widget.cameras.first)),
                        ),
                        child: const Text("Text Extraction from Images",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 27.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold))))),
            color: HexColor('b56576')),

        Container(
            child: Center(
                child: SizedBox.expand(
                    child: TextButton(
                        // highlightColor: Colors.yellow[900],
                        // splashColor: Colors.yellow[500],
                        onPressed: () => sd.sosDialogBox(context),
                        child: const Text("SOS Settings",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 27.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold))))),
            color: HexColor('eaac8b')),

        Container(
            child: Center(
                child: SizedBox.expand(
                    child: TextButton(
                        // highlightColor: HexColor('#A8DEE0'),
                        // splashColor: HexColor('#F9E2AE'),
                        onPressed: () => ls.optionsDialogBox(context),
                        child: const Text("Select Language",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 27.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold))))),
            color: HexColor('6d597a')),

        // Container(
        //     child: Center(
        //         child: SizedBox.expand(
        //             child: FlatButton(
        //                 highlightColor: HexColor('#A8DEE0'),
        //                 splashColor: HexColor('#F5E2AE'),
        //                 onPressed: () =>getObjectImage(),
        //                 child: Text("Object Detection",
        //                     style: TextStyle(
        //                         fontSize: 27.0,
        //                         color: Colors.white,
        //                         fontWeight: FontWeight.bold))))),
        //     color: HexColor('b56576')),

        //////
      ],
      scrollDirection: Axis.horizontal,
      pageSnapping: true,

      // physics: NeverScrollableScrollPhysics(),
    );
  }

  Widget showFirstTimePageView(BuildContext context) {
    return PageView(
      padEnds: false,
      controller: _controller,
      onPageChanged: _speakPage,
      children: <Widget>[
        Container(
            child: Center(
                child: SizedBox.expand(
                    child: TextButton(
                        // highlightColor: HexColor('#A8DEE0'),
                        // splashColor: HexColor('#F9E2AE'),
                        onPressed: () => ls.optionsDialogBox(context),
                        child: const Text("Select Language",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 27.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold))))),
            color: HexColor('6d597a')),
        Container(
            child: Center(
                child: SizedBox.expand(
                    child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>CurrencyIdentifierScreen(camera: widget.cameras.first)),
                        ),
                        child: const Text("Currency Identifier",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 27.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold))))),
            color: HexColor('eccc8b')),
        // showcurr == false
        //     ? Container(
        //     child: Center(
        //         child: SizedBox.expand(
        //             child: TextButton(
        //               // style: TextButton.styleFrom(
        //               //   backgroundColor: Colors.yellow[900],
        //               // ),
        //
        //                 onPressed: () {
        //                   setState(() {
        //                     showcurr = !showcurr;
        //                   });
        //                 },
        //                 child: const Text("Currency Detection",
        //                     textAlign: TextAlign.center,
        //                     style: TextStyle(
        //                         fontSize: 27.0,
        //                         color: Colors.white,
        //                         fontWeight: FontWeight.bold))))),
        //     color: HexColor('eccc8b'))
        //     : cashDetectionDialog(context, widget.cameras),
        shoobj == false
            ? Container(
                child: Center(
                    child: SizedBox.expand(
                        child: TextButton(
                            onPressed: () {
                              setState(() {
                                shoobj = !shoobj;
                              });
                            },
                            child: const Text("Object Detection",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 27.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))))),
                color: HexColor('ebbc8b'))
            : objectDetectionDialog(context, widget.cameras),
        Container(
            child: Center(
                child: SizedBox.expand(
                    child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ColorIdentifierScreen(
                                    camera: widget.cameras.first))),
                        //onPressed: () => getColorFromImage(),
                        child: const Text("Color Identifier",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 27.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold))))),
            color: HexColor('e56b6f')),

        Container(
            child: Center(
                child: SizedBox.expand(
                    child: TextButton(
                        // onPressed: () => getTextFromImage(),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) =>TextExtractionScreen(camera: widget.cameras.first)),
                        ),
                        child: const Text("Text Extraction from Images",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 27.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold))))),
            color: HexColor('b56576')),

        Container(
            child: Center(
                child: SizedBox.expand(
                    child: TextButton(
                        // highlightColor: Colors.yellow[900],
                        // splashColor: Colors.yellow[500],
                        onPressed: () => sd.sosDialogBox(context),
                        child: const Text("SOS Settings",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 27.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold))))),
            color: HexColor('eaac8b')),

        // Container(
        //     child: Center(
        //         child: SizedBox.expand(
        //             child: FlatButton(
        //                 highlightColor: HexColor('#A8DEE0'),
        //                 splashColor: HexColor('#F5E2AE'),
        //                 onPressed: () =>getObjectImage(),
        //                 child: Text("Object Detection",
        //                     style: TextStyle(
        //                         fontSize: 27.0,
        //                         color: Colors.white,
        //                         fontWeight: FontWeight.bold))))),
        //     color: HexColor('b56576')),

        //////
      ],
      scrollDirection: Axis.horizontal,
      pageSnapping: true,

      // physics: NeverScrollableScrollPhysics(),
    );
  }

  Widget objectDetectionDialog(
      BuildContext context, List<CameraDescription> cameras) {
    Size screen = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        flutterTts.speak("Closing Object Detection").then((value) {
          setState(() {
            shoobj = !shoobj;
          });
        });
      },
      child: Stack(
        children: [
          Camera(
            cameras,
            _model,
            setRecognitions,
          ),
          Container(
            alignment: Alignment.bottomLeft,
            child: BndBox(
                _recognitions,
                math.max(_imageHeight, _imageWidth),
                math.min(_imageHeight, _imageWidth),
                screen.height,
                screen.width,
                _model,
                "object"),
          ),
        ],
      ),
    );
  }

  // Widget cashDetectionDialog(
  //     BuildContext context, List<CameraDescription> cameras) {
  //   Size screen = MediaQuery.of(context).size;
  //   return GestureDetector(
  //     onTap: () {
  //       flutterTts.speak("Closing Currency Identifier").then((value) {
  //         setState(() {
  //           showcurr = !showcurr;
  //         });
  //       });
  //     },
  //     child: Stack(
  //       children: [
  //         CashCamera(
  //           cameras,
  //           _model,
  //           setRecognitions,
  //         ),
  //         Container(
  //           alignment: Alignment.bottomLeft,
  //           child: CashBndBox(
  //               _recognitions,
  //               math.max(_imageHeight, _imageWidth),
  //               math.min(_imageHeight, _imageWidth),
  //               screen.height,
  //               screen.width,
  //               _model,
  //               "cash"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Future _stopTts() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(amplitude: 100, duration: 200);
    }
    flutterTts.stop();
  }

  _speakPage(int a) async {
    translator = GoogleTranslator();
    SharedPreferences sp = await SharedPreferences.getInstance();
    flutterTts.setLanguage(sp.getString("language").toString()).then((value) {
      flutterTts.setVoice({
        sp.getString("voice").toString().toString():
            sp.getString("language").toString().toString()
      }).then((value) {
        print;
      });
    });
    await flutterTts.setQueueMode(1);
    var speak = "";
    switch (isOpenForFirstTime) {
      case false:
        if (a == 0) {
          speak = "Currency Identifier";
          translator
              .translate(speak, to: sp.getString("abbreviation").toString())
              .then((value) {
            flutterTts.speak(value.toString()).then(print);
          });
        }
        if (a == 1) {
          speak = "Object Detection";
          translator
              .translate(speak, to: sp.getString("abbreviation").toString())
              .then((value) {
            flutterTts.speak(value.toString()).then(print);
          });
          // await flutterTts.stop();
          // if (await Vibration.hasVibrator()) {
          //   Vibration.vibrate(amplitude: 128, duration: 1800);
          // }

        }
        if (a == 2) {
          // await flutterTts.stop();
          // if (await Vibration.hasVibrator()) {
          //   Vibration.vibrate(amplitude: 128, duration: 1400);
          // }
          speak = "Color Identifier";
          translator
              .translate(speak, to: sp.getString("abbreviation").toString())
              .then((value) {
            flutterTts.speak(value.toString()).then(print);
          });
        }
        if (a == 3) {
          //await flutterTts.stop();
          // if (await Vibration.hasVibrator()) {
          //   Vibration.vibrate(amplitude: 128, duration: 1400);
          // }
          speak = "Text Extraction From Images";
          translator
              .translate(speak, to: sp.getString("abbreviation").toString())
              .then((value) {
            flutterTts.speak(value.toString()).then(print);
          });
        }
        if (a == 4) {
          //await flutterTts.stop();
          // if (await Vibration.hasVibrator()) {
          //   Vibration.vibrate(amplitude: 128, duration: 2200);
          // }
          speak = "SOS Settings";
          translator
              .translate(speak, to: sp.getString("abbreviation").toString())
              .then((value) {
            flutterTts.speak(value.toString()).then(print);
          });
        }
        if (a == 5) {
          speak = "Language Selection";
          translator
              .translate(speak, to: sp.getString("abbreviation").toString())
              .then((value) {
            flutterTts.speak(value.toString()).then(print);
          });
        }
        break;
      case true:
        if (a == 0) {
          speak = "Language Selection";
          translator
              .translate(speak, to: sp.getString("abbreviation").toString())
              .then((value) {
            flutterTts.speak(value.toString()).then(print);
          });
        }
        if (a == 1) {
          speak = "Currency Detection";
          translator
              .translate(speak, to: sp.getString("abbreviation").toString())
              .then((value) {
            flutterTts.speak(value.toString()).then(print);
          });
          // await flutterTts.stop();
          // if (await Vibration.hasVibrator()) {
          //   Vibration.vibrate(amplitude: 128, duration: 1800);
          // }

        }
        if (a == 2) {
          // await flutterTts.stop();
          // if (await Vibration.hasVibrator()) {
          //   Vibration.vibrate(amplitude: 128, duration: 1400);
          // }
          speak = "Object Detection";
          translator
              .translate(speak, to: sp.getString("abbreviation").toString())
              .then((value) {
            flutterTts.speak(value.toString()).then(print);
          });
        }
        if (a == 3) {
          //await flutterTts.stop();
          // if (await Vibration.hasVibrator()) {
          //   Vibration.vibrate(amplitude: 128, duration: 1400);
          // }
          speak = "Color Identifier";
          translator
              .translate(speak, to: sp.getString("abbreviation").toString())
              .then((value) {
            flutterTts.speak(value.toString()).then(print);
          });
        }
        if (a == 4) {
          //await flutterTts.stop();
          // if (await Vibration.hasVibrator()) {
          //   Vibration.vibrate(amplitude: 128, duration: 2200);
          // }
          speak = "Text Extraction From Images";
          translator
              .translate(speak, to: sp.getString("abbreviation").toString())
              .then((value) {
            flutterTts.speak(value.toString()).then(print);
          });
        }
        if (a == 5) {
          speak = "SOS Settings";
          translator
              .translate(speak, to: sp.getString("abbreviation").toString())
              .then((value) {
            flutterTts.speak(value.toString()).then(print);
          });
        }
        break;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    flutterTts.stop().then((value) => null);
  }

  Future<bool> isAppOpenedFirstTime() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    int count = sp.getInt("defaultLanguageCheck") ?? 0;
    if (count == 0) {
      //  _controller.jumpToPage(5);
      await sp.setInt("defaultLanguageCheck", 1);
      await flutterTts.setLanguage(sp.getString("language").toString());
      setState(() {
        isOpenForFirstTime = true;
      });
      return true;
    } else {
      setState(() {
        isOpenForFirstTime = false;
      });
      return false;
    }
  }
}
