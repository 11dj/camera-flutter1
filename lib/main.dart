import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(CameraApp());
}

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  CameraController controller;
  FlashMode flashsetting = FlashMode.off;
  var _file;
  var _fileSize;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    controller.setFlashMode(FlashMode.off);
    // _initializeControllerFuture = controller.initialize();
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  _takePicture() async {
    var file = await controller.takePicture();
    print('_takePicture');
    print('file.path ${file.path}');
    var decodedImage =
        await decodeImageFromList(File(file.path).readAsBytesSync());
    print(double.parse(decodedImage.width.toString()));
    print(decodedImage.height);
    setState(() {
      _file = file?.path;
      _fileSize = decodedImage;
    });
  }

  // _getResolutionImg(var path) async {
  //   return await decodeImageFromList(File(path).readAsBytesSync());
  // }

  _toggleTorch() {
    print('_toggleTorch');
    if (flashsetting == FlashMode.torch) {
      controller.setFlashMode(FlashMode.off);
      setState(() => flashsetting = FlashMode.off);
    } else {
      controller.setFlashMode(FlashMode.torch);
      setState(() => flashsetting = FlashMode.torch);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Stack(
              // alignment: Alignment.bottomCenter,
              children: [
                AspectRatio(
                  aspectRatio: 1 / controller.value.aspectRatio,
                  child: Stack(
                    children: <Widget>[
                      CustomPaint(
                        foregroundPainter: Paint(),
                        child: CameraPreview(controller),
                      ),
                      ClipPath(
                          clipper: Clip(), child: CameraPreview(controller)),
                    ],
                  ),
                ),
                // Positioned(
                //   bottom: 80,
                //   child: Row(
                //     children: [
                //       Container(
                //         child: Column(
                //           children: [
                //             Text('Hrllo'),
                //             Text('Hrllo'),
                //           ],
                //         ),
                //       )
                //     ],
                //   ),
                // ),
                if (_file != null)
                  Positioned(
                      bottom: 80,
                      child: Container(
                        width: double.parse(_fileSize.width.toString()),
                        height: double.parse(_fileSize.width.toString()) / 2,
                        child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.white,
                                  height: _fileSize.height * 0.24,
                                ),
                                Image.file(File(_file)),
                              ],
                            )),
                      ))
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xff03dac6),
            foregroundColor: Colors.black,
            onPressed: () {
              // _toggleTorch();
              _takePicture();
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

class Paint extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.grey.withOpacity(0.8), BlendMode.dstOut);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class Clip extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    print('Clip $size');
    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(10, (size.height / 2) - (size.height * 0.25),
              size.width - 20, (size.width * 0.5)),
          Radius.circular(16)));
    return path;
  }

  @override
  bool shouldReclip(oldClipper) {
    return true;
  }
}
