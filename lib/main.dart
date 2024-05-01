

import 'package:camera/camera.dart';
import 'package:faceattendance/page/face_recognition/camera_page.dart';
import 'package:faceattendance/page/login_page.dart';
import 'package:faceattendance/utils/local_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();

  // final appDocDir = await path_provider.getApplicationDocumentsDirectory();
  // print('path');
  // print(appDocDir.path);
  // Hive.init(appDocDir.path);
  // await HiveBoxes.initialize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Face Auth",
        home: LoginPage(),
      );
}
