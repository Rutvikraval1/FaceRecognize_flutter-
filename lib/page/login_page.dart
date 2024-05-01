

import 'package:faceattendance/models/user.dart';
import 'package:faceattendance/page/face_recognition/camera_page.dart';
import 'package:faceattendance/page/face_recognition/face_detector_view.dart';
import 'package:faceattendance/utils/databse_helper.dart';
import 'package:faceattendance/utils/local_db.dart';
import 'package:flutter/material.dart';

import '../utils/utils.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Face Authentication"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildButton(
                  text: 'Register',
                  icon: Icons.app_registration_rounded,
                  onClicked: () async {
                    // Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) =>  FaceDetectorView()));

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FaceScanScreen()));
                  },
                ),
                const SizedBox(height: 24),
                buildButton(
                  text: 'Login',
                  icon: Icons.login,
                  onClicked: ()  async {
                    // print(LocalDB.getUser().name);
                    var user = await  _databaseHelper.queryAllUsers();
                    print(user.length);
                    print(user);
                    print(user[0].array);
                    // ignore: use_build_context_synchronously
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => FaceScanScreen(check_login:'true')));
                  },
                ),
              ],
            ),
          ),
        ),
      );

  Widget buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onClicked,
  }) =>
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
        ),
        icon: Icon(icon, size: 26),
        label: Text(
          text,
          style: const TextStyle(fontSize: 20),
        ),
        onPressed: onClicked,
      );
}
