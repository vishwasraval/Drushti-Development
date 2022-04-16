import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_ocr_plugin/simple_ocr_plugin.dart';
import 'package:translator/translator.dart';
import 'package:vibration/vibration.dart';
import 'package:tflite/tflite.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A screen that allows users to take a picture using a given camera.
class TextExtractionScreen extends StatefulWidget {
  const TextExtractionScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  TextExtractionScreenState createState() => TextExtractionScreenState();
}

class TextExtractionScreenState extends State<TextExtractionScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  static final FlutterTts flutterTts = FlutterTts();

  static late XFile  currImage;
  static late BuildContext  buildcontext;
  static late String language,voice,abb;

  static Future _stopTts() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(amplitude: 100, duration: 200);
    }
    flutterTts.stop();
  }

  static Future _pauseTts() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(amplitude: 100, duration: 200);
    }
    flutterTts.pause();
  }

  static Future _speakOCR(String text) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(amplitude: 500, duration: 200);
    }
    await flutterTts.speak(text);
  }

  static void openCamera(BuildContext context,XFile img) async {

    var _extractText = await SimpleOcrPlugin.performOCR(img.path);
    //print(_extractText.substring(20));
    _speakOCR(_extractText.substring(20, _extractText.length - 15)).then((value) => null);
    showOCRDialog(
        _extractText.substring(20, _extractText.length - 15), PickedFile(img.path), context);
  }

  static Future<void> showOCRDialog(
      String text, PickedFile picture, BuildContext context) async {
    final pngByteData = await picture.readAsBytes();

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
                title: const Text('Text Detected'),
                content: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: 300.0,
                        height: 150,
                        child: ElevatedButton(
                          onPressed: _stopTts,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(10.0),
                            primary: HexColor('b56576'),
                            elevation: 5.0,
                            shape:  RoundedRectangleBorder(
                                borderRadius:  BorderRadius.circular(16.0)),
                          ),

                          child: const Text('Stop',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),

                        ),
                      ),
                      Container(height: 10),
                      SizedBox(
                        width: 300.0,
                        height: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            _speakOCR(text);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(10.0),
                            primary: HexColor('b56576'),
                            elevation: 5.0,
                            shape:  RoundedRectangleBorder(
                                borderRadius:  BorderRadius.circular(16.0)),
                          ),

                          child: const Text('Replay',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Container(height: 10),
                      SizedBox(
                        width: 300.0,
                        height: 150,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(10.0),
                            primary: HexColor('b56576'),
                            elevation: 5.0,
                            shape:  RoundedRectangleBorder(
                                borderRadius:  BorderRadius.circular(16.0)),
                          ),
                          onPressed: _pauseTts,

                          child: const Text('Pause',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Container(height: 10),
                      Image.memory(pngByteData),
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
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        }).then((value) => _stopTts());
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
                title: const Text('Color Identification'),
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
        context: buildcontext,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }



  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
      enableAudio: false,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    _controller.setFlashMode(FlashMode.off);

  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);


    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Take a picture'),backgroundColor: Colors.transparent,),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return GestureDetector(
                onTap: () async{
                  try {
                    // Ensure that the camera is initialized.
                    await _initializeControllerFuture;

                    // Attempt to take a picture and get the file `image`
                    // where it was saved.

                    final image = await _controller.takePicture();

                    // If the picture was taken, display it on a new screen.

                    openCamera(context, image);
                  } catch (e) {
                    // // If an error occurs, log the error to the console.
                    // print(e);
                  }
                },
                child:OverflowBox(
                  // maxHeight: screenW/previewW*previewH,
                  // maxWidth: screenW,
                  maxHeight: screenH,

                  maxWidth:  screenW,

                  child: CameraPreview(_controller),
                ));
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
