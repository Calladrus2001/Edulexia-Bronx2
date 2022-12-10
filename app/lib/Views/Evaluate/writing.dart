import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:code_star/Utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

enum pageStatus { START, ONGOING }

class HearingTest extends StatefulWidget {
  const HearingTest({Key? key}) : super(key: key);

  @override
  State<HearingTest> createState() => _HearingTestState();
}

class _HearingTestState extends State<HearingTest> {
  final box = GetStorage();
  late String? UserID = "";
  pageStatus status = pageStatus.START;
  final textController = TextEditingController();
  bool isDiffSelected = false;
  int? _value = 0;
  int idx = 0;
  List<dynamic> urls = [];
  final audioplayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    UserID = box.read("userID");
    audioplayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    audioplayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    audioplayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    audioplayer.onPlayerComplete.listen((event) {
      setState(() {
        position = Duration.zero;
      });
    });
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
            crossAxisAlignment: CrossAxisAlignment.center,
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
                              image: AssetImage("assets/images/writing.png")),
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
                            3,
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
                                  child: Text("Start the Writing Test",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)))),
                          onTap: () async {
                            if (isDiffSelected) {
                              var response = await http.get(Uri.parse(
                                  "$baseUrl/eval?userID=$UserID&type=Writing"));
                              if (response.statusCode == 200) {
                                var responseString = response.body;
                                Map<String, dynamic> res =
                                    jsonDecode(responseString);
                                setState(() {
                                  urls = res["urls"];
                                  status = pageStatus.ONGOING;
                                });
                                print(urls);
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
                        SizedBox(height: 60),
                        Text("Quote ${idx + 1}",
                            style: TextStyle(color: clr1, fontSize: 24)),
                        SizedBox(height: 16),
                        Container(
                          height: 105,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: clr1,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Center(
                              child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              children: [
                                Slider(
                                  inactiveColor: Colors.blueGrey.shade200,
                                  activeColor: Colors.white,
                                  min: 0,
                                  max: duration.inSeconds.toDouble(),
                                  value: position.inSeconds.toDouble(),
                                  onChanged: (value) async {
                                    final pos =
                                        Duration(seconds: value.toInt());
                                    await audioplayer.seek(pos);
                                    await audioplayer.resume();
                                  },
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_printDuration(position),
                                        style: TextStyle(color: Colors.white)),
                                    GestureDetector(
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          backgroundColor: clr1,
                                          radius: 20,
                                          child: isPlaying
                                              ? Icon(
                                                  Icons.pause,
                                                  color: Colors.white,
                                                )
                                              : Icon(
                                                  Icons.play_arrow,
                                                  color: Colors.white,
                                                ),
                                        ),
                                      ),
                                      onTap: () async {
                                        if (isPlaying) {
                                          await audioplayer.pause();
                                        } else {
                                          await audioplayer
                                              .play(UrlSource(urls[idx]));
                                        }
                                      },
                                    ),
                                    Text(_printDuration(duration),
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ],
                            ),
                          )),
                        ),
                        SizedBox(height: 36),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                              border: Border.all(color: clr1, width: 1.5),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: Colors.white),
                          child: TextField(
                            maxLines: 4,
                            keyboardType: TextInputType.multiline,
                            controller: textController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 16),
                                hintText:
                                    "Enter the transcription of the Audio file played"),
                            style: TextStyle(fontSize: 18, color: clr1),
                          ),
                        ),
                        SizedBox(height: 144),
                        GestureDetector(
                          child: CircleAvatar(
                            minRadius: 25,
                            backgroundColor: clr1,
                            child: Icon(Icons.arrow_forward_ios_rounded,
                                color: Colors.white),
                          ),
                          onTap: () {
                            if (idx < urls.length - 1) {
                              setState(() {
                                textController.text = "";
                                idx++;
                              });
                            } else {
                              Get.snackbar(
                                  "Code:Star", "Writing Test Completed");
                              Navigator.pop(context);
                            }
                          },
                        )
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
