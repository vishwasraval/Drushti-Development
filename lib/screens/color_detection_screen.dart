// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:tflite/tflite.dart';
// import 'package:vibration/vibration.dart';
// import 'package:translator/translator.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'dart:math' as math;
//
// class ColorDetectionPage extends StatefulWidget {
//   const ColorDetectionPage({Key? key,
//     required this.camera,
//   }) : super(key: key);
//
//   final CameraDescription camera;
//
//   @override
//   _ColorDetectionPageState createState() => _ColorDetectionPageState();
// }
//
// class _ColorDetectionPageState extends State<ColorDetectionPage> with WidgetsBindingObserver {
//
//   static late XFile  currImage;
//   static late BuildContext  buildcontext;
//   static late String language,voice,abb;
//   static final FlutterTts flutterTts = FlutterTts();
//
//   static void colorDetect(BuildContext buildContext, XFile img) {
//     loadModel().then((value) {
//       // setState(() {});
//     });
//     buildcontext = buildContext;
//     currImage = img;
//     speakColorValue();
//   }
//
//   static classifyColor(XFile image) async {
//     SharedPreferences sharedPreferences=await SharedPreferences.getInstance();
//     language=( sharedPreferences.getString("language"))!;
//     //voice=( sharedPreferences.getString("voice"))!;
//     abb=( sharedPreferences.getString("abbreviation"))!;
//
//     var output = await Tflite.runModelOnImage(
//         path: image.path,
//         numResults: 7,
//         threshold: 0.5,
//         imageMean: 127.5,
//         imageStd: 127.5);
//     // print("This is the $output");
//     // print("This is the ${output![0]['label']}");
//     dynamic label = output![0]['label'];
//     //print(label.runtimeType);
//     if (await Vibration.hasVibrator()) {
//       Vibration.vibrate(amplitude: 500, duration: 200);
//     }
//     _speak(label);
//     showCaptionDialog(label, image);
//   }
//
//   static loadModel() async {
//     await Tflite.loadModel(
//       model: 'assets/color_model_unquant.tflite',
//       labels: 'assets/color_labels.txt',
//     );
//   }
//
//   static speakColorValue() {
//     classifyColor(currImage);
//   }
//
//   static Future _speak(String output) async {
//     if (await Vibration.hasVibrator()) {
//       Vibration.vibrate(amplitude: 500, duration: 200);
//     }
//     final translator=GoogleTranslator();
//     SharedPreferences sp = await SharedPreferences.getInstance();
//     await flutterTts.setLanguage(sp.getString("language").toString());
//     translator
//         .translate(output, to: sp.getString("abbreviation").toString())
//         .then((value) {
//         //  print(value);
//       flutterTts.speak(value.toString()).then(print);
//     });
//   }
//
//   static Future<void> showCaptionDialog(String text, XFile picture) async {
//     showGeneralDialog(
//         barrierColor: Colors.black.withOpacity(0.5),
//         transitionBuilder: (context, a1, a2, widget) {
//           return Transform.scale(
//             scale: a1.value,
//             child: Opacity(
//               opacity: a1.value,
//               child: AlertDialog(
//                 shape: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(16.0)),
//                 title: const Text('Color Identification'),
//                 content: SingleChildScrollView(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       SizedBox(
//                         width: 300.0,
//                         height: 420.0,
//                         //decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16.0))),
//                         child: ElevatedButton(
//                           onPressed: () {
//                             _speak(text);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.all(10.0),
//
//                             primary: HexColor('e56b6f'),
//                             elevation: 5.0,
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(16.0)),
//                           ),
//
//                           child: const Text(
//                             'Replay',
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                       )),
//                       const SizedBox(
//                         width: 300.0,
//                         height: 20,
//                       ),
//                       Image.file(File(picture.path)),
//                       const SizedBox(width: 20),
//                       Text(text),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//         transitionDuration: const Duration(milliseconds: 200),
//         barrierDismissible: true,
//         barrierLabel: '',
//         context: buildcontext,
//         pageBuilder: (context, animation1, animation2) {
//           return Container();
//         });
//   }
//
//   static Future<void> _stopTts() async {
//     await flutterTts.stop();
//   }
//
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     // To display the current output from the Camera,
//     // create a CameraController.
//     _controller = CameraController(
//       // Get a specific camera from the list of available cameras.
//       widget.camera,
//       // Define the resolution to use.
//       ResolutionPreset.medium,
//     );
//
//     // Next, initialize the controller. This returns a Future.
//     _initializeControllerFuture = _controller.initialize();
//   }
//
//   @override
//   void dispose() {
//     // Dispose of the controller when the widget is disposed.
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     var tmp = MediaQuery.of(context).size;
//     var screenH = math.max(tmp.height, tmp.width);
//     var screenW = math.min(tmp.height, tmp.width);
//     tmp = _controller.value.previewSize!;
//     var previewH = math.max(tmp.height, tmp.width);
//     var previewW = math.min(tmp.height, tmp.width);
//     var screenRatio = screenH / screenW;
//     var previewRatio = previewH / previewW;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Take a picture')),
//       // You must wait until the controller is initialized before displaying the
//       // camera preview. Use a FutureBuilder to display a loading spinner until the
//       // controller has finished initializing.
//       body: FutureBuilder<void>(
//         future: _initializeControllerFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             // If the Future is complete, display the preview.
//             return  WillPopScope(
//                 onWillPop: () {
//               debugPrint('DEBUG: back pressed');
//               //controller.dispose();
//               return Future.value(true);
//             },
//           child: GestureDetector(
//                 onTap: () async{
//                   try {
//                     // Ensure that the camera is initialized.
//                     await _initializeControllerFuture;
//
//                     // Attempt to take a picture and get the file `image`
//                     // where it was saved.
//                     final image = await _controller.takePicture();
//
//                     // If the picture was taken, display it on a new screen.
//                     colorDetect(context, image);
//                   } catch (e) {
//                     // If an error occurs, log the error to the console.
//                     print(e);
//                   }
//                 },
//                 child:OverflowBox(
//             // maxHeight: screenW/previewW*previewH,
//             // maxWidth: screenW,
//             maxHeight: screenRatio > previewRatio
//             ? screenH
//                 : screenW / previewW * previewH,
//               maxWidth: screenRatio > previewRatio
//                   ? screenH / previewH * previewW
//                   : screenW,
//
//               child: CameraPreview(_controller),
//             )));
//           } else {
//             // Otherwise, display a loading indicator.
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }
//
