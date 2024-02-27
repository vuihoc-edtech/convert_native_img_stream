import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:convert_native_img_stream/convert_native_img_stream.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _convertNativeImgStreamPlugin = ConvertNativeImgStream();

  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  bool capture = false, converting = false;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  @override
  void dispose() async {
    super.dispose();
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  void initializeCamera() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == CameraLensDirection.back) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      final camera = _cameras[_cameraIndex];
      _controller = CameraController(
        camera,
        // Main thing that we wanna solve, the stream of nv12 to jpeg format
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      _controller?.initialize().then((_) {
        _controller?.startImageStream((image) {
          if (capture) {
            setState(() {
              converting = false;
            });
            _controller?.stopImageStream();
            _controller?.pausePreview();
            _convertNativeImgStreamPlugin
                .convertImgToBytes(
              image.planes.first.bytes,
              image.width,
              image.height,
            )
                .then((value) {
              imageBytes = value;
              converting = false;
              setState(() {});
            });
          }
        });
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
  }

  Widget _body() {
    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();
    if (converting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (imageBytes == null)
            Center(
              child: CameraPreview(
                _controller!,
              ),
            )
          else
            Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Expanded(
                      flex: 10,
                      child: Center(
                          child: Text("Converted image",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 22)))),
                  Expanded(
                      flex: 90,
                      child: Image.memory(imageBytes!, fit: BoxFit.cover))
                ],
              ),
            ),
          if (imageBytes == null)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                    onPressed: () {
                      capture = true;
                    },
                    child: const Text("Pause & Convert Frame"))
              ],
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: _body()),
    );
  }
}
