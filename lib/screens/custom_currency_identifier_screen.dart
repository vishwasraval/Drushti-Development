import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:hexcolor/hexcolor.dart';
import 'package:translator/translator.dart';
import 'package:vibration/vibration.dart';
import 'package:tflite/tflite.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A screen that allows users to take a picture using a given camera.
class CurrencyIdentifierScreen extends StatefulWidget {
  const CurrencyIdentifierScreen({
    Key? key,
    required this.camera,
  }) : super(key: key);

  final CameraDescription camera;

  @override
  CurrencyIdentifierScreenState createState() => CurrencyIdentifierScreenState();
}

class CurrencyIdentifierScreenState extends State<CurrencyIdentifierScreen> with WidgetsBindingObserver  {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  static final FlutterTts flutterTts = FlutterTts();

  static late XFile  currImage;
  static late BuildContext  buildcontext;
  static late String language,voice,abb;

  static void curencyDetect(BuildContext buildContext, XFile img) {
    loadModel().then((value) {
      // setState(() {});
    });
    buildcontext = buildContext;
    currImage = img;
    speakCurrencyValue();
  }

  static classifyCurrency(XFile image) async {
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

  static speakCurrencyValue() {
    classifyCurrency(currImage);
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
        context: buildcontext,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

  static Future<void> _stopTts() async {
    await flutterTts.stop();
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
    _initializeControllerFuture = _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
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
    if (!_controller.value.isInitialized) {
      return Container();
    }
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

                    curencyDetect(context, image);
                  } catch (e) {
                    // If an error occurs, log the error to the console.
                    print(e);
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
