import 'dart:io';
import 'package:code_star/Utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

enum audioStatus { UPLOADING, NOT_STARTED, UPLOADED }

class AddAudioScreen extends StatefulWidget {
  const AddAudioScreen({Key? key}) : super(key: key);

  @override
  State<AddAudioScreen> createState() => _AddAudioScreenState();
}

class _AddAudioScreenState extends State<AddAudioScreen> {
  final box = GetStorage();
  List<XFile>? _images = [];
  final ImagePicker _picker = ImagePicker();
  bool haveImages = false;
  audioStatus status = audioStatus.NOT_STARTED;
  int index = 0;
  String text = "";
  DateTime rn = DateTime.now();
  TextEditingController nameController = new TextEditingController();
  late String downloadUrl;
  late String userID;
  var progress = 0.0;

  @override
  void initState() {
    userID = box.read("userID");
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              SizedBox(height: 40),

              /// help btn
              Row(
                children: [
                  Expanded(child: SizedBox(width: 1)),
                  GestureDetector(
                    child: Icon(Icons.help_outline, color: clr1),
                    onTap: () {
                      Get.defaultDialog(
                          title: "Help",
                          titleStyle: TextStyle(color: clr1),
                          radius: 10,
                          content: Text(
                            "1. Select images of the study material you would like to made Audiofile for.\n\n"
                            "2. Press the Upload Button to generate the AudioFile and save it to Cloud.\n\n"
                            "3. Thats it!",
                            style: TextStyle(color: Colors.grey),
                          ));
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
              SizedBox(height: 20),

              /// pick image
              haveImages
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {
                              if (index >= 1) {
                                setState(() {
                                  index -= 1;
                                });
                              }
                            },
                            icon: Icon(Icons.keyboard_arrow_left)),
                        SizedBox(width: 20),
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Image.file(
                            File(_images![index].path),
                            fit: BoxFit.fill,
                          ),
                        ),
                        SizedBox(width: 20),
                        IconButton(
                            onPressed: () {
                              if (index < _images!.length - 1) {
                                setState(() {
                                  index += 1;
                                });
                              }
                            },
                            icon: Icon(Icons.keyboard_arrow_right))
                      ],
                    )
                  : GestureDetector(
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                            color: clr1,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      onTap: () async {
                        _images = await _picker.pickMultiImage();
                        if (_images != null) {
                          imagesToText(_images!);
                          setState(() {
                            haveImages = true;
                          });
                        }
                      },
                    ),
              SizedBox(height: 16),
              haveImages
                  ? Center(child: Text("${index + 1}/${_images!.length}"))
                  : SizedBox(),
              SizedBox(height: 24),

              /// name textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Enter name of Audiobook',
                    hintText: 'ex. myAwesomeNotes',
                  ),
                ),
              ),
              SizedBox(height: 32),

              /// generate AudioFile
              status == audioStatus.UPLOADED
                  ? Chip(
                      backgroundColor: Colors.green.shade500,
                      label: Text("Audiobook is available now",
                          style: TextStyle(color: Colors.white)),
                    )
                  : status == audioStatus.NOT_STARTED
                      ? GestureDetector(
                          child: Container(
                            height: 50,
                            width: 110,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              color: clr1,
                            ),
                            child: Icon(
                              Icons.upload_rounded,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            if (nameController.text == "" || _images == []) {
                              Get.snackbar(
                                  "Code:Star", "Empty input fields detected");
                            } else {
                              setState(() {
                                status = audioStatus.UPLOADING;
                              });
                              synth(text);
                            }
                          },
                        )
                      : Column(
                          children: [
                            SizedBox(height: 64),
                            Center(
                                child: CircularProgressIndicator(color: clr1)),
                            SizedBox(height: 24),
                            Text(
                              "Uploading Audiobook, Please do not close this screen",
                              style: TextStyle(color: Colors.grey),
                            )
                          ],
                        )
            ],
          ),
        ),
      ),
    );
  }

  void imagesToText(List<XFile> _images) {
    for (int i = 0; i < _images.length; i++) {
      getRecognisedText(_images[i]);
    }
  }

  void getRecognisedText(XFile image) async {
    final inputImage = InputImage.fromFilePath(image.path);
    final TextRecognizer textRecognizer =
        TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        text = text + line.text + "\n";
      }
    }
    textRecognizer.close();
  }

  void synth(String text) async {
    var response = await http.post(Uri.parse("$baseUrl/synthAudio"), body: {
      "userID": userID,
      "name": nameController.text,
      "time": "${DateFormat.MMMMd().format(rn)} ${DateFormat.jm().format(rn)}",
      "text": text
    });
    if (response.statusCode == 200) {
      setState(() {
        status = audioStatus.UPLOADED;
      });
    }
  }
}
