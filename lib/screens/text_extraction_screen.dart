//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:simple_ocr_plugin/simple_ocr_plugin.dart';
// import 'package:vibration/vibration.dart';
//
// class ocrDialog {
//   static final FlutterTts flutterTts = FlutterTts();
//
//   static Future<void> showOCRDialog(
//       String text, PickedFile picture, BuildContext context) async {
//     final pngByteData = await picture.readAsBytes();
//
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
//                 title: const Text('Text Detected'),
//                 content: SingleChildScrollView(
//                   child: Column(
//                     children: <Widget>[
//                        SizedBox(
//                         width: 300.0,
//                         height: 150,
//                         child: ElevatedButton(
//                           onPressed: _stopTts,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.all(10.0),
//                             primary: HexColor('b56576'),
//                             elevation: 5.0,
//                             shape:  RoundedRectangleBorder(
//                                 borderRadius:  BorderRadius.circular(16.0)),
//                           ),
//
//                           child: const Text('Stop',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold)),
//
//                         ),
//                       ),
//                       Container(height: 10),
//                        SizedBox(
//                         width: 300.0,
//                         height: 150,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             _speakOCR(text);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.all(10.0),
//                             primary: HexColor('b56576'),
//                             elevation: 5.0,
//                             shape:  RoundedRectangleBorder(
//                                 borderRadius:  BorderRadius.circular(16.0)),
//                           ),
//
//                           child: const Text('Replay',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold)),
//                           ),
//                       ),
//                       Container(height: 10),
//                        SizedBox(
//                         width: 300.0,
//                         height: 150,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.all(10.0),
//                             primary: HexColor('b56576'),
//                             elevation: 5.0,
//                             shape:  RoundedRectangleBorder(
//                                 borderRadius:  BorderRadius.circular(16.0)),
//                           ),
//                           onPressed: _pauseTts,
//
//                           child: const Text('Pause',
//                               style: TextStyle(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold)),
//                            ),
//                       ),
//                        Container(height: 10),
//                        Image.memory(pngByteData),
//                       const SizedBox(width: 20),
//                        Text(text),
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
//         context: context,
//         pageBuilder: (context, animation1, animation2) {
//           return Container();
//         }).then((value) => _stopTts());
//   }
//
//   static Future _stopTts() async {
//     if (await Vibration.hasVibrator()) {
//       Vibration.vibrate(amplitude: 100, duration: 200);
//     }
//     flutterTts.stop();
//   }
//
//   static Future _pauseTts() async {
//     if (await Vibration.hasVibrator()) {
//       Vibration.vibrate(amplitude: 100, duration: 200);
//     }
//     flutterTts.pause();
//   }
//
//   static Future _speakOCR(String text) async {
//     if (await Vibration.hasVibrator()) {
//       Vibration.vibrate(amplitude: 500, duration: 200);
//     }
//     await flutterTts.speak(text);
//   }
//
//   // Future<void> optionsDialogBox(BuildContext context) {
//   //   return showDialog(
//   //       context: context,
//   //       builder: (BuildContext context) {
//   //         return AlertDialog(
//   //           content: SingleChildScrollView(
//   //             child:  ListBody(
//   //               children: <Widget>[
//   //                 RichText(
//   //                   text: TextSpan(
//   //                     style: Theme.of(context).textTheme.bodyText2,
//   //                     children: const [
//   //                       WidgetSpan(
//   //                         child: Padding(
//   //                           padding:
//   //                               EdgeInsets.symmetric(horizontal: 3.0),
//   //                           child: Icon(FlutterIcons.photo_camera_mdi),
//   //                         ),
//   //                       ),
//   //                       TextSpan(
//   //                         text: 'Choose mode',
//   //                         style: TextStyle(
//   //                             fontWeight: FontWeight.bold, fontSize: 20),
//   //                       ),
//   //                     ],
//   //                   ),
//   //                 ),
//   //                 const Padding(
//   //                   padding: EdgeInsets.all(8.0),
//   //                 ),
//   //                 GestureDetector(
//   //                   child: const Text('Take a picture'),
//   //                   onTap: () {
//   //                     openCamera(context);
//   //                   },
//   //                 ),
//   //                 const Padding(
//   //                   padding: EdgeInsets.all(8.0),
//   //                 ),
//   //                 GestureDetector(
//   //                   child: const Text('Select from gallery'),
//   //                   onTap: () {
//   //                     openGallery(context);
//   //                   },
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //         );
//   //       });
//   // }
//
//   static void openCamera(BuildContext context,XFile img) async {
//
//     var _extractText = await SimpleOcrPlugin.performOCR(img!.path);
//     //print(_extractText.substring(20));
//     _speakOCR(_extractText.substring(20, _extractText.length - 15)).then((value) => null);
//     showOCRDialog(
//         _extractText.substring(20, _extractText.length - 15), PickedFile(img.path), context);
//   }
//
//   // Future<void> openGallery(BuildContext context) async {
//   //   ImagePicker ip =  ImagePicker();
//   //   var picture = await ip.getImage(
//   //     source: ImageSource.gallery,
//   //   );
//   //   var _extractText = await SimpleOcrPlugin.performOCR(picture!.path);
//   //   //print(_extractText.substring(20));
//   //   _speakOCR(_extractText.substring(20, _extractText.length - 15));
//   //   showOCRDialog(_extractText.substring(20, _extractText.length - 15),
//   //       picture, context);
//   // }
// }
