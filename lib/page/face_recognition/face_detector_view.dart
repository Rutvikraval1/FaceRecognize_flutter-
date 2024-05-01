import 'dart:math';

import 'package:camera/camera.dart';
import 'package:faceattendance/page/face_recognition/detector_view.dart';
import 'package:faceattendance/page/pointer/face_detector_painter.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorView extends StatefulWidget {
  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      // enableContours: true,
      // enableLandmarks: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Face Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = FaceDetectorPainter(
        faces,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }

    print("step 1");
    print(faces);
    if (faces.isNotEmpty) {
      for (Face face in faces) {
        final Rect boundingBox = face.boundingBox;
        print("step 2");
        print(boundingBox);
        print('headEulerAngleY');
        print(face.headEulerAngleY);
        print(face.headEulerAngleX);
        final double? rotX = face.headEulerAngleX;// Head is tilted up and down rotX degrees
        print("step 3");
        print(rotX);
        final double? rotY = face.headEulerAngleY;// Head is rotated to the right rotY degrees
        print("step 4");
        print(rotY);
        final double? rotZ = face.headEulerAngleZ; // Head is tilted sideways rotZ degrees
        print("step 5");
        print(rotZ);

        // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
        // eyes, cheeks, and nose available):
        final FaceLandmark? leftEar = face.landmarks[FaceLandmarkType.leftEar];

        print("step 6");
        print(leftEar);
        if (leftEar != null) {
          final Point<int> leftEarPos = leftEar.position;
          print("step 7");
          print(boundingBox);
        }
        print("step 8");
        print(face.smilingProbability);
        // If classification was enabled with FaceDetectorOptions:
        if (face.smilingProbability != null) {
          final double? smileProb = face.smilingProbability;
        }
        print("step 9");
        print(face.trackingId);
        // If face tracking was enabled with FaceDetectorOptions:
        if (face.trackingId != null) {
          final int? id = face.trackingId;
          print("face id");
          print(id);
        }
      }
    }



    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
