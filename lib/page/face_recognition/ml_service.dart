import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:faceattendance/models/user.dart';
import 'package:faceattendance/utils/databse_helper.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;
import '../../utils/utils.dart';
import 'image_converter.dart';

class MLService {
  late Interpreter interpreter;
  List? predictedArray;
  double threshold = 0.5;

  Future<dynamic> predict(
      CameraImage cameraImage, Face face, bool loginUser, String name) async {
    DatabaseHelper _databaseHelper = DatabaseHelper.instance;

    print("step 1");
    print(cameraImage);
    print(face);
    print(loginUser);
    print(name);

    List input = _preProcess(cameraImage, face);
    input = input.reshape([1, 112, 112, 3]);

    List output = List.generate(1, (index) => List.filled(192, 0));

    await initializeInterpreter();

    interpreter.run(input, output);
    output = output.reshape([192]);

    predictedArray = List.from(output);
    print("predictedArray");
    print("name");
    print(predictedArray);

    if (loginUser) {
      print("step 2");
      print(name);
      print(predictedArray.toString());
      // await _databaseHelper.insert({
      //   DatabaseHelper.columnUser: name,
      //   DatabaseHelper.columnarrayKey: predictedArray.toString(),
      // });
      User userToSave = User( name: name,array: predictedArray!
      );
      await _databaseHelper.insert(userToSave);
      await Future.delayed(Duration(milliseconds: 100));
      return null;
    } else {
      List<User> users = await _databaseHelper.queryAllUsers();
      double minDist = 999;
      double currDist = 0.0;
      User? predictedResult;

      for (User u in users) {
        print('step 1');
        print(u.array);
        currDist = euclideanDistance(predictedArray!,u.array );
        if (currDist <= threshold && currDist < minDist) {
          print('step 2 currDist');
          print(currDist);
          minDist = currDist;
          predictedResult = u;
          break;
        }
      }
      return predictedResult;

      // print("step 3");
      // List<User> users = await _databaseHelper.queryAllUsers();
      // print('User data');
      // print(users.length);
      // print(users.length);
      // print(predictedArray.toString());
      // List userArray = jsonDecode(users[1]['arrayKey']);
      // print('userArray done');
      // print(userArray);
      // // var a = jsonDecode(listA);
      // int minDist = 999;
      // double threshold = 1.5;
      // var dist = euclideanDistance(predictedArray!, userArray);
      // print('step 6');
      // print(dist);
      // print('step 7');
      // print(dist <= threshold && dist < minDist);
      // if (dist <= threshold && dist < minDist) {
      //
      //   print('step 4');
      //
      //   // return user;
      //   return true;
      // } else {
      //   print('step 5');
      //   return null;
      // }
    }
  }


  double euclideanDistance(List? e1, List? e2) {
    if (e1 == null || e2 == null) throw Exception("Null argument");

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }

  // euclideanDistance(List l1, List l2) {
  //   double sum = 0;
  //   for (int i = 0; i < l1.length; i++) {
  //     sum += pow((l1[i] - l2[i]), 2);
  //   }
  //   print('step 10');
  //   print(sum);
  //   return pow(sum, 0.5);
  // }

  initializeInterpreter() async {
    Delegate? delegate;
    try {
      if (Platform.isAndroid) {
        delegate = GpuDelegateV2(
            options: GpuDelegateOptionsV2(
              isPrecisionLossAllowed: false,
              inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
              inferencePriority1: TfLiteGpuInferencePriority.minLatency,
              inferencePriority2: TfLiteGpuInferencePriority.auto,
              inferencePriority3: TfLiteGpuInferencePriority.auto,
            ));
      } else if (Platform.isIOS) {
        delegate = GpuDelegate(
          options: GpuDelegateOptions(
              allowPrecisionLoss: true,
              waitType: TFLGpuDelegateWaitType.active),
        );
      }
      var interpreterOptions = InterpreterOptions()..addDelegate(delegate!);

      interpreter = await Interpreter.fromAsset('mobilefacenet.tflite',
          options: interpreterOptions);
    } catch (e) {
      printIfDebug('Failed to load model.');
      printIfDebug(e);
    }
  }

  List _preProcess(CameraImage image, Face faceDetected) {
    imglib.Image croppedImage = _cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, 112);

    Float32List imageAsList = _imageToByteListFloat32(img);
    return imageAsList;
  }

  imglib.Image _cropFace(CameraImage image, Face faceDetected) {
    imglib.Image convertedImage = _convertCameraImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(
        convertedImage, x.round(), y.round(), w.round(), h.round());
  }

  imglib.Image _convertCameraImage(CameraImage image) {
    var img = convertToImage(image);
    var img1 = imglib.copyRotate(img!, -90);
    return img1;
  }

  Float32List _imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (imglib.getRed(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getGreen(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getBlue(pixel) - 128) / 128;
      }
    }

    return convertedBytes.buffer.asFloat32List();
  }
}
