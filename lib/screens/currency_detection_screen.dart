
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite/tflite.dart';
import 'package:vibration/vibration.dart';
import 'package:translator/translator.dart';
import 'package:hexcolor/hexcolor.dart';
import 'dart:io';

class CurrencyDetectionPage {
  static XFile ? currImage;
  static BuildContext ?context;


  static late String language,voice,abb;
  static final FlutterTts flutterTts = FlutterTts();

  static void curencyDetect(BuildContext buildContext, XFile img) {
    loadModel().then((value) {
      // setState(() {});
    });
    context = buildContext;
    currImage = img;
    speakColorValue();
  }

  static classifyColor(XFile image) async {
    SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
    language=( sharedPreferences.getString("language"))!;
    //voice=( sharedPreferences.getString("voice"))!;
    abb=( sharedPreferences.getString("abbreviation"))!;

    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 7,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    // print("This is the $output");
    // print("This is the ${output![0]['label']}");
    dynamic label = output![0]['label'];
    //print(label.runtimeType);
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(amplitude: 500, duration: 200);
    }
    _speak(label);
    showCaptionDialog(label, image);
  }

  static loadModel() async {
    await Tflite.loadModel(
      model: 'assets/cash_model_unquant.tflite',
      labels: 'assets/cash_labels.txt',
    );
  }

  static speakColorValue() {
    classifyColor(currImage!);
  }

  static Future _speak(String output) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(amplitude: 500, duration: 200);
    }
    final translator=GoogleTranslator();
    SharedPreferences sp = await SharedPreferences.getInstance();
    await flutterTts.setLanguage(sp.getString("language").toString());
    translator
        .translate(output, to: sp.getString("abbreviation").toString())
        .then((value) {
      //  print(value);
      flutterTts.speak(value.toString()).then(print);
    });
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
                title: const Text('Currency Identification'),
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
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(10.0),

                              primary: HexColor('e56b6f'),
                              elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0)),
                            ),

                            child: const Text(
                              'Replay',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          )),
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




// import 'dart:async';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tflite/tflite.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:translator/translator.dart';
// import 'package:camera/camera.dart';
// import 'dart:math' as math;
// import '../main.dart';
// import 'models.dart';
// import 'package:drushti/utils/constants.dart';
//
// typedef Callback = void Function(List<dynamic> list, int h, int w);
//
// class CashBndBox extends StatefulWidget {
//   final List<dynamic> results;
//   final int previewH;
//   final int previewW;
//   final double screenH;
//   final double screenW;
//   final String model;
//   final String detection;
//
//   const CashBndBox(this.results, this.previewH, this.previewW, this.screenH,
//       this.screenW, this.model, this.detection);
//
//   @override
//   _CashBndBox createState() =>  _CashBndBox();
// }
//
// class _CashBndBox extends State<CashBndBox> {
//   final FlutterTts flutterTts = FlutterTts();
//   final translator = GoogleTranslator();
//   dynamic _timer;
//
//   String? speak = " ";
//   String? prevString;
//   String language = "";
//   String voice = "";
//   String abb = "";
//
//   @override
//   void initState() {
//
//     super.initState();
//     loadModel().then((val) {
//       setState(() {
//         //_busy = false;
//       });
//     });
//     checklanguage();
//     _timer = Timer.periodic(
//         const Duration(seconds: 3), (Timer timer) => _speak());
//   }
//
//   @override
//   void dispose() {
//     // Tflite.close().then((value) => null);
//     //_timer.cancel();
//
//     //stop();
//     super.dispose();
//     flutterTts.stop().then((value) => _timer.cancel());
//   }
//
//   loadModel() async {
//     Tflite.close();
//     String? res = await Tflite.loadModel(
//       model: cashModelFileName,
//       labels: cashLabelFileName,
//     );
//     // print("MODEL" + res!);
//     // print(cashModelFileName);
//   }
//
//   Future<void> checklanguage() async {
//     // await flutterTts.getVoices.then((print));
//     // await flutterTts.getLanguages.then((print));
//     SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//     if (sharedPreferences.getString("language") == null) {
//       sharedPreferences.setString("language", engLanguage);
//       language = (sharedPreferences.getString("language"))!;
//     }
//     if (sharedPreferences.getString("voice") == null) {
//       sharedPreferences.setString("voice", engVoice);
//       voice = (sharedPreferences.getString("voice"))!;
//     }
//     if (sharedPreferences.getString("abbreviation") == null) {
//       sharedPreferences.setString("abbreviation", engAbbreviation);
//       abb = (sharedPreferences.getString("abbreviation"))!;
//       await flutterTts.setLanguage(language);
//       await flutterTts.setVoice({voice: language});
//       // print(abb + " " + language + " " + voice);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     List<Widget> _renderBoxes() {
//       return widget.results.map((re) {
//         var _x = re["rect"]["x"];
//         var _w = re["rect"]["w"];
//         var _y = re["rect"]["y"];
//         var _h = re["rect"]["h"];
//         dynamic scaleW, scaleH, x, y, w, h;
//
//         if (widget.screenH / widget.screenW >
//             widget.previewH / widget.previewW) {
//           scaleW = widget.screenH / widget.previewH * widget.previewW;
//           scaleH = widget.screenH;
//           var difW = (scaleW - widget.screenW) / scaleW;
//           x = (_x - difW / 2) * scaleW;
//           w = _w * scaleW;
//           if (_x < difW / 2) w -= (difW / 2 - _x) * scaleW;
//           y = _y * scaleH;
//           h = _h * scaleH;
//         } else {
//           scaleH = widget.screenW / widget.previewW * widget.previewH;
//           scaleW = widget.screenW;
//           var difH = (scaleH - widget.screenH) / scaleH;
//           x = _x * scaleW;
//           w = _w * scaleW;
//           y = (_y - difH / 2) * scaleH;
//           h = _h * scaleH;
//           if (_y < difH / 2) h -= (difH / 2 - _y) * scaleH;
//         }
//
//         speak = re["detectedClass"];
//
//         return Positioned(
//           left: math.max(0, x),
//           top: math.max(0, y),
//           width: w,
//           height: h,
//           child: Container(
//             padding: const EdgeInsets.only(top: 5.0, left: 5.0),
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: const Color.fromRGBO(37, 213, 253, 1.0),
//                 width: 3.0,
//               ),
//             ),
//             child: Text(
//               "${re["detectedClass"]} ${(re["confidenceInClass"] * 100).toStringAsFixed(0)}%",
//               style: const TextStyle(
//                 color: Color.fromRGBO(37, 213, 253, 1.0),
//                 fontSize: 14.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         );
//       }).toList();
//     }
//
//     List<Widget> _renderStrings() {
//       double offset = -10;
//       return widget.results.map((re) {
//         //print(re.toString());
//         offset = offset + 14;
//         //print(re["label"]);
//         if (re["confidence"] > 0.95) speak = re["label"];
//         return Positioned(
//           top: 50,
//           left: 20,
//           //top: 100,
//           width: widget.screenW,
//           height: widget.screenH,
//           child: Text(
//             "\n${re["label"]} ${(re["confidence"] * 100).toStringAsFixed(0)} %\n\n",
//             style: const TextStyle(
//               color: Color.fromRGBO(37, 213, 253, 1.0),
//               fontSize: 16.0,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         );
//       }).toList();
//     }
//
//     return Stack(
//       children: widget.model == mobilenet ? _renderStrings() : _renderBoxes(),
//     );
//   }
//
//   Future _speak() async {
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     await flutterTts.setLanguage(sp.getString("language").toString());
//     translator
//         .translate(speak!, to: sp.getString("abbreviation").toString())
//         .then((value) {
//       if(speak != null && speak != prevString ) {
//         prevString = speak;
//         flutterTts.speak(value.toString()).then(print);
//       }
//       else {
//         null;
//       }
//     });
//   }
//
//   stop() async {
//     await flutterTts.stop().then((value) => null);
//   }
// }
//
// class CashCamera extends StatefulWidget {
//   final List<CameraDescription> cameras;
//   final Callback setRecognitions;
//   final String model;
//
//   const CashCamera(this.cameras, this.model, this.setRecognitions);
//
//   @override
//   _CashCameraState createState() => _CashCameraState();
// }
//
// class _CashCameraState extends State<CashCamera> with WidgetsBindingObserver {
//   static late CameraController controller;
//   bool isDetecting = false;
//
//   initController() async {
//     if (!mounted) {
//       return;
//     }
//     controller =
//         CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);
//
//     try {
//       await controller.initialize().then((value) {
//         controller.startImageStream((cameraImage) {});
//       });
//     } on CameraException catch (e) {
//       debugPrint("...***...exception...***...");
//       debugPrint(e.toString());
//     }
//     if (mounted) {
//       setState(() {});
//     }
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (!controller.value.isInitialized) {
//       return;
//     }
//     if (state == AppLifecycleState.inactive) {
//       controller.dispose();
//       debugPrint("...***...inactive dispose...***...");
//     } else if (state == AppLifecycleState.resumed) {
//       initController();
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance!.addObserver(this);
//     if (widget.cameras == null || widget.cameras.length < 1) {
//       print('No camera is found');
//     } else {
//       controller = CameraController(
//         widget.cameras[0],
//         ResolutionPreset.high,
//       );
//       controller.initialize().then((_) {
//         if (!mounted) {
//           return;
//         }
//         setState(() {});
//
//         controller.startImageStream((CameraImage img) {
//           if (!isDetecting) {
//             isDetecting = true;
//
//             //int startTime = DateTime.now().millisecondsSinceEpoch;
//
//             if (widget.model == mobilenet) {
//               Tflite.runModelOnFrame(
//                 bytesList: img.planes.map((plane) {
//                   return plane.bytes;
//                 }).toList(),
//                 imageHeight: img.height,
//                 imageWidth: img.width,
//                 numResults: 2,
//               ).then((recognitions) {
//                 //int endTime = DateTime.now().millisecondsSinceEpoch;
//                 //print("Detection took ${endTime - startTime}");
//
//                 widget.setRecognitions(recognitions!, img.height, img.width);
//
//                 isDetecting = false;
//               });
//             } else if (widget.model == posenet) {
//               Tflite.runPoseNetOnFrame(
//                 bytesList: img.planes.map((plane) {
//                   return plane.bytes;
//                 }).toList(),
//                 imageHeight: img.height,
//                 imageWidth: img.width,
//                 numResults: 2,
//               ).then((recognitions) {
//                // int endTime = DateTime.now().millisecondsSinceEpoch;
//                 //print("Detection took ${endTime - startTime}");
//
//                 widget.setRecognitions(recognitions!, img.height, img.width);
//
//                 isDetecting = false;
//               });
//             } else {
//               Tflite.detectObjectOnFrame(
//                 bytesList: img.planes.map((plane) {
//                   return plane.bytes;
//                 }).toList(),
//                 model: widget.model == yolo ? "YOLO" : "SSDMobileNet",
//                 imageHeight: img.height,
//                 imageWidth: img.width,
//                 imageMean: widget.model == yolo ? 0 : 127.5,
//                 imageStd: widget.model == yolo ? 255.0 : 127.5,
//                 numResultsPerClass: 1,
//                 threshold: widget.model == yolo ? 0.2 : 0.4,
//               ).then((recognitions) {
//                 //int endTime = DateTime.now().millisecondsSinceEpoch;
//                 //print("Detection took ${endTime - startTime}");
//
//                 widget.setRecognitions(recognitions!, img.height, img.width);
//
//                 isDetecting = false;
//               });
//             }
//           }
//         });
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//
//     super.dispose();
//     controller.dispose();
//     WidgetsBinding.instance!.removeObserver(this);
//     debugPrint("...***...dispose...***...");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (controller == null || !controller.value.isInitialized) {
//       return Container();
//     }
//
//     var tmp = MediaQuery.of(context).size;
//     var screenH = math.max(tmp.height, tmp.width);
//     var screenW = math.min(tmp.height, tmp.width);
//     tmp = controller.value.previewSize!;
//     var previewH = math.max(tmp.height, tmp.width);
//     var previewW = math.min(tmp.height, tmp.width);
//     var screenRatio = screenH / screenW;
//     var previewRatio = previewH / previewW;
//
//     return WillPopScope(
//         onWillPop: () {
//           debugPrint('DEBUG: back pressed');
//           //controller.dispose();
//           return Future.value(true);
//         },
//         child: OverflowBox(
//           // maxHeight: screenW/previewW*previewH,
//           // maxWidth: screenW,
//           maxHeight: screenRatio > previewRatio
//               ? screenH
//               : screenW / previewW * previewH,
//           maxWidth: screenRatio > previewRatio
//               ? screenH / previewH * previewW
//               : screenW,
//
//           child: CameraPreview(controller),
//         ));
//   }
// }
