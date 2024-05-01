import 'package:camera/camera.dart';
import 'package:faceattendance/page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:lottie/lottie.dart';
import '../../models/user.dart';
import '../../widgets/common_widgets.dart';
import 'ml_service.dart';

List<CameraDescription>? cameras;

class FaceScanScreen extends StatefulWidget {
 final  String? check_login;
  const FaceScanScreen({Key? key, this.check_login}) : super(key: key);

  @override
  _FaceScanScreenState createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  TextEditingController controller = TextEditingController();
  late CameraController _cameraController;
  bool flash = false;
  bool isControllerInitialized = false;
  late FaceDetector _faceDetector;
  final MLService _mlService = MLService();
  List<Face> facesDetected = [];

  Future initializeCamera() async {
    await _cameraController.initialize();
    isControllerInitialized = true;

    _cameraController.setFlashMode(FlashMode.off);
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  InputImageRotation rotationIntToImageRotation(int rotation) {
    switch (rotation) {
      case 90:
        return InputImageRotation.Rotation_90deg;
      case 180:
        return InputImageRotation.Rotation_180deg;
      case 270:
        return InputImageRotation.Rotation_270deg;
      default:
        return InputImageRotation.Rotation_0deg;
    }
  }

  Future<void> detectFacesFromImage(CameraImage image) async {
    InputImageData _firebaseImageMetadata = InputImageData(
      imageRotation: rotationIntToImageRotation(
          _cameraController.description.sensorOrientation),
      inputImageFormat: InputImageFormat.BGRA8888,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      planeData: image.planes.map(
            (Plane plane) {
          return InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );

    InputImage _firebaseVisionImage = InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      inputImageData: _firebaseImageMetadata,
    );
    // var result = await _faceDetector.processImage(_firebaseVisionImage);
    final result = await _faceDetector.processImage(_firebaseVisionImage);
    if (result.isNotEmpty) {
      facesDetected = result;
      print("facesDetected");
    }
  }

  Future<void> _predictFacesFromImage({required CameraImage image}) async {
    await detectFacesFromImage(image);
    if (facesDetected.isNotEmpty) {
      User? user = await _mlService.predict(
          image,
          facesDetected[0],
          widget.check_login == null,
          widget.check_login == null ?controller.text :'' );

      if (widget.check_login == null) {
        // register case

        print("user data");
        print(user?.name);
        print(user?.array);
        print(user?.array?.length);

        Navigator.pop(context);
        print("User registered successfully");
      } else {
        // login case
        if (user == null) {
          Navigator.pop(context);
          print("Unknown User");
        } else {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        }
      }
    }
    if (mounted) setState(() {});
    await takePicture();
  }

  Future<void> takePicture() async {
    if (facesDetected.isNotEmpty) {
      await _cameraController.stopImageStream();
      XFile file = await _cameraController.takePicture();
      file = XFile(file.path);
      _cameraController.setFlashMode(FlashMode.off);
    } else {
      showDialog(
          context: context,
          builder: (context) =>
          const AlertDialog(content: Text('No face detected!')));
    }
  }

  @override
  void initState() {
    _cameraController = CameraController(cameras![1], ResolutionPreset.high);
    initializeCamera();
    _faceDetector = GoogleMlKit.vision.faceDetector(
      const FaceDetectorOptions(
        mode: FaceDetectorMode.accurate,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [

            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Expanded(
                //   child: Padding(
                //     padding: const EdgeInsets.only(bottom: 100),
                //     child: Lottie.asset("assets/loading.json",
                //         width: MediaQuery.of(context).size.width * 0.7),
                //   ),
                // ),
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height/1.3,
                    child: isControllerInitialized
                        ? CameraPreview(_cameraController)
                        : null),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                      fillColor: Colors.white, filled: true),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: CWidgets.customExtendedButton(
                          text: "Capture",
                          context: context,
                          isClickable: true,
                          onTap: (){
                            bool canProcess = false;
                            _cameraController.startImageStream((CameraImage image) async {
                              if (canProcess) return;
                              canProcess = true;
                              _predictFacesFromImage(image: image).then((value) {
                                canProcess = false;
                              });
                              return null;
                            });
                          }),
                    ),
                    IconButton(
                        icon: Icon(
                          flash ? Icons.flash_on : Icons.flash_off,
                          color: Colors.black,
                          size: 28,
                        ),
                        onPressed: () {
                          setState(() {
                            flash = !flash;
                          });
                          flash
                              ? _cameraController
                              .setFlashMode(FlashMode.torch)
                              : _cameraController.setFlashMode(FlashMode.off);
                        }),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
