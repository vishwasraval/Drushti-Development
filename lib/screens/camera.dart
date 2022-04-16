import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import '../main.dart';
import 'models.dart';

typedef Callback = void Function(List<dynamic> list, int h, int w);

class Camera extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String model;

  const Camera(this.cameras, this.model, this.setRecognitions);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> with WidgetsBindingObserver {
  static late CameraController controller;
  bool isDetecting = false;

  initController() async {
    if (!mounted) {
      return;
    }
    controller =
        CameraController(cameras[0], ResolutionPreset.high, enableAudio: false);

    try {
      await controller.initialize().then((value) {
        controller.startImageStream((cameraImage) {});
      });
    } on CameraException catch (e) {
      debugPrint("...***...exception...***...");
      debugPrint(e.toString());
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      debugPrint("...***...inactive dispose...***...");
    } else if (state == AppLifecycleState.resumed) {
      initController();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    if (widget.cameras.isEmpty) {
      debugPrint('No camera is found');
    } else {
      controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
      );
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        controller.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;


            if (widget.model == mobilenet) {
              Tflite.runModelOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                imageHeight: img.height,
                imageWidth: img.width,
                numResults: 2,
              ).then((recognitions) {

                widget.setRecognitions(recognitions!, img.height, img.width);

                isDetecting = false;
              });
            } else if (widget.model == posenet) {
              Tflite.runPoseNetOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                imageHeight: img.height,
                imageWidth: img.width,
                numResults: 2,
              ).then((recognitions) {
                int endTime = DateTime.now().millisecondsSinceEpoch;
                //print("Detection took ${endTime - startTime}");

                widget.setRecognitions(recognitions!, img.height, img.width);

                isDetecting = false;
              });
            } else {
              Tflite.detectObjectOnFrame(
                bytesList: img.planes.map((plane) {
                  return plane.bytes;
                }).toList(),
                model: widget.model == yolo ? "YOLO" : "SSDMobileNet",
                imageHeight: img.height,
                imageWidth: img.width,
                imageMean: widget.model == yolo ? 0 : 127.5,
                imageStd: widget.model == yolo ? 255.0 : 127.5,
                numResultsPerClass: 1,
                threshold: widget.model == yolo ? 0.2 : 0.4,
              ).then((recognitions) {
                int endTime = DateTime.now().millisecondsSinceEpoch;
                //print("Detection took ${endTime - startTime}");

                widget.setRecognitions(recognitions!, img.height, img.width);

                isDetecting = false;
              });
            }
          }
        });
      });
    }
  }

  @override
  void dispose() {

    super.dispose();
    controller.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    debugPrint("...***...dispose...***...");
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }

    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize!;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return WillPopScope(
      onWillPop: () {
        debugPrint('DEBUG: back pressed');
        //controller.dispose();
        return Future.value(true);
      },
    //   child: SizedBox(
    //     child: CameraPreview(controller),
    //   ),
    //
    // );
    child: OverflowBox(
      // maxHeight: screenW/previewW*previewH,
      // maxWidth: screenW,
      maxHeight: screenRatio > previewRatio
          ? screenH
          : screenW / previewW * previewH,
      maxWidth: screenRatio > previewRatio
          ? screenH / previewH * previewW
          : screenW,

      child: CameraPreview(controller),
    ));
  }
}
