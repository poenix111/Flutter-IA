import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = true;
  File? _image;
  final picker = ImagePicker();
  List? _output;
  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {
        // _isLoading = false;
      });
    });
  }

  Future pickImage() async {
    if (await Permission.storage.isPermanentlyDenied) await openAppSettings();
    await Permission.storage.request();
    if (await Permission.camera.isPermanentlyDenied) await openAppSettings();
    await Permission.camera.request();

    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
    detectImage(_image);
  }

  Future getImage() async {
    if (await Permission.storage.isPermanentlyDenied) await openAppSettings();
    await Permission.storage.request();
    if (await Permission.camera.isPermanentlyDenied) await openAppSettings();
    await Permission.camera.request();

    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
    detectImage(_image);
  }

  detectImage(File? image) async {
    try {
      var output = await Tflite.runModelOnImage(
        path: image!.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      setState(() {
        _output = output!;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  loadModel() async {
    Tflite.close();
    String? result;
    result = await Tflite.loadModel(
      model: 'assets/model/model_unquant.tflite',
      labels: "assets/model/labels.txt",
    );

    print(result);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      appBar: AppBar(
        title: Text("Cat & Dog Classifier"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              Text(
                "Coding cafe",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Cats & Dogs Detector App",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Center(
                child: _isLoading
                    ? Container(
                        width: 350,
                        child: Column(
                          children: [
                            Image.asset('assets/cat_dog.png'),
                          ],
                        ),
                      )
                    : Container(
                        child: Column(
                          children: [
                            SizedBox(height: 20),
                            Container(
                              // height: 50,
                              child: Image.file(_image!),
                            ),
                            SizedBox(height: 20),
                            _output != null
                                ? Text(
                                    '${_output![0]['label']}',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await pickImage();
                      },
                      child: Container(
                        // width: MediaQuery.of(context).size.width - 250,
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 80),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          "Capture a photo",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () async {
                        getImage();
                      },
                      child: Container(
                        // width: MediaQuery.of(context).size.width - 250,
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 80),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          "Select  a photo",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
