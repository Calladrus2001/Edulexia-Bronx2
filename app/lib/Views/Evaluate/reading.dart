import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:code_star/Utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

enum pageStatus { START, ONGOING }

class ReadingTest extends StatefulWidget {
  const ReadingTest({Key? key}) : super(key: key);

  @override
  State<ReadingTest> createState() => _ReadingTestState();
}

class _ReadingTestState extends State<ReadingTest> {
  final box = GetStorage();
  pageStatus status = pageStatus.START;
  bool isDiffSelected = false;
  int? _value = 0;
  int? fontSize = 14;
  int? letterSpacing = 0;
  late String? UserID = "";
  late List<dynamic> sentences = [];
  late stt.SpeechToText _speech;
  TextEditingController textController = new TextEditingController();
  String _text = "";
  bool isListening = false;
  bool isComplete = false;
  int index = 0;

  @override
  void initState() {
    _speech = stt.SpeechToText();
    UserID = box.read("userID");
    super.initState();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              SizedBox(height: 40),
              Align(
                alignment: Alignment.topRight,
                child: Icon(Icons.help_outline, color: clr1),
              ),
              status == pageStatus.START
                  ? Column(
                      children: [
                        Container(
                          height: 250,
                          child: Image(
                              image: AssetImage("assets/images/reading.png")),
                        ),
                        SizedBox(height: 32),
                        Text(
                          "Select difficulty level",
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List<Widget>.generate(
                            4,
                            (int index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: ChoiceChip(
                                  selectedColor: clr1,
                                  disabledColor: Colors.grey,
                                  label: Text('${difficult[index]}',
                                      style: TextStyle(color: Colors.white)),
                                  selected: _value == index,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _value = selected ? index : null;
                                      if (_value == null) {
                                        isDiffSelected = false;
                                      } else {
                                        isDiffSelected = true;
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ).toList(),
                        ),
                        SizedBox(height: 16),
                        _value == 3
                            ? Column(
                                children: [
                                  Text(
                                    "Select font size",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List<Widget>.generate(
                                      3,
                                      (int index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child: ChoiceChip(
                                            selectedColor: clr1,
                                            disabledColor: Colors.grey,
                                            label: Text('${(index + 7) * 2}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: (index + 7) * 2)),
                                            selected: fontSize == index,
                                            onSelected: (bool selected) {
                                              setState(() {
                                                fontSize =
                                                    selected ? index : null;
                                              });
                                            },
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Select letter spacing",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List<Widget>.generate(
                                      3,
                                      (int index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child: ChoiceChip(
                                            selectedColor: clr1,
                                            disabledColor: Colors.grey,
                                            label: Text('spacing',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    letterSpacing:
                                                        (index) * 0.6)),
                                            selected: letterSpacing == index,
                                            onSelected: (bool selected) {
                                              setState(() {
                                                letterSpacing =
                                                    selected ? index : null;
                                              });
                                            },
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ],
                              )
                            : SizedBox(),

                        SizedBox(height: 32),

                        /// start button
                        GestureDetector(
                          child: Center(
                              child: Container(
                                  height: 50,
                                  width: 200,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: clr1,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(30))),
                                  child: Text("Start the Reading Test",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)))),
                          onTap: () async {
                            if (isDiffSelected) {
                              var response = await http.get(Uri.parse(
                                  "$baseUrl/eval?userID=$UserID&type=Reading"));
                              if (response.statusCode == 200) {
                                var responseString = response.body;
                                Map<String, dynamic> res =
                                    jsonDecode(responseString);
                                setState(() {
                                  sentences = res["sentences"];
                                  status = pageStatus.ONGOING;
                                });
                              }
                            } else {
                              Get.snackbar(
                                  "Code:Star", "Empty Input fields detected");
                            }
                          },
                        )
                      ],
                    )
                  : Column(
                      children: [
                        SizedBox(height: 40),
                        Card(
                          elevation: 4.0,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            height: 180,
                            width: 300,
                            alignment: Alignment.center,
                            child: Text(
                              textAlign: TextAlign.center,
                              "${sentences[index]}",
                              style: TextStyle(color: clr1, fontSize: 18),
                            ),
                          ),
                        ),
                        SizedBox(height: 18),
                        Card(
                          elevation: 4.0,
                          child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              height: 180,
                              width: 300,
                              alignment: Alignment.center,
                              child: Text(textController.text,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: clr1, fontSize: 18))),
                        ),
                        SizedBox(height: 64),
                        isComplete
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    child: Center(
                                      child: CircleAvatar(
                                        backgroundColor: clr1,
                                        minRadius: 24,
                                        child: Icon(Icons.refresh_rounded,
                                            color: Colors.white),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        textController.text = "";
                                        isComplete = false;
                                      });
                                    },
                                  ),
                                  SizedBox(width: 8),
                                  Text("or",
                                      style: TextStyle(color: Colors.grey)),
                                  SizedBox(width: 8),
                                  GestureDetector(
                                    child: Center(
                                      child: CircleAvatar(
                                        backgroundColor: clr1,
                                        minRadius: 24,
                                        child: Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            color: Colors.white),
                                      ),
                                    ),
                                    onTap: () {
                                      if (index < 2) {
                                        setState(() {
                                          index++;
                                          isComplete = false;
                                          textController.text = "";
                                        });
                                      } else {
                                        Get.snackbar("Code:Star",
                                            "Reading Test completed!");
                                        Navigator.pop(context);
                                      }
                                    },
                                  ),
                                ],
                              )
                            : isListening
                                ? GestureDetector(
                                    child: Center(
                                      child: CircleAvatar(
                                        backgroundColor: clr1,
                                        minRadius: 24,
                                        child: Icon(Icons.mic_off_rounded,
                                            color: Colors.white),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        isListening = false;
                                      });
                                      _speech.stop();
                                    },
                                  )
                                : GestureDetector(
                                    child: Center(
                                      child: CircleAvatar(
                                        backgroundColor: clr1,
                                        minRadius: 24,
                                        child: Icon(Icons.mic,
                                            color: Colors.white),
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _listen();
                                        isListening = true;
                                      });
                                    },
                                  )
                      ],
                    )
            ],
          ),
        ),
      ),
    );
  }

  void _listen() async {
    if (!isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == "done") {
            setState(() {
              isComplete = true;
              isListening = false;
            });
          }
        },
        onError: (val) {},
      );
      if (available) {
        setState(() => isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            textController.text = _text;
            print(_text);
          }),
        );
      }
    } else {
      setState(() => isListening = false);
      _speech.stop();
    }
  }
}
