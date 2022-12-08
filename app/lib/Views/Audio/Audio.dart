import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:code_star/Utils/constants.dart';
import 'package:code_star/Views/Audio/AddAudio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:code_star/Views/Evaluate/Evaluate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum fileStatus { GOT_FILES, SEARCHING, DO_NOT_EXIST }

class AudioScreen extends StatefulWidget {
  const AudioScreen({Key? key}) : super(key: key);

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final box = GetStorage();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  late String userID;
  List<dynamic> audioFiles = [];
  final audioplayer = AudioPlayer();
  bool isPlaying = false;
  fileStatus status = fileStatus.SEARCHING;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String url = "https://www2.cs.uic.edu/~i101/SoundFiles/PinkPanther60.wav";

  @override
  void initState() {
    userID = box.read("userID");
    getAudioFiles();

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

  void getAudioFiles() async {
    var response =
        await http.get(Uri.parse("${baseUrl}/getAudio?userID=${userID}"));
    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> responseString = jsonDecode(response.body);
        audioFiles = responseString["audioFiles"];
        if (audioFiles != null) {
          setState(() {
            status = fileStatus.GOT_FILES;
          });
        }
      } catch (e) {
        setState(() {
          status = fileStatus.DO_NOT_EXIST;
        });
      }
    }
  }

  void _refresh() async {
    setState(() {
      status = fileStatus.SEARCHING;
    });
    getAudioFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawerEnableOpenDragGesture: true,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              child: Image(
                image: AssetImage("assets/images/intro.png"),
              ),
            ),
            SizedBox(height: 60),
            GestureDetector(
              child: ListTile(
                title: Text("Add AudioFile",
                    style: TextStyle(color: clr1, fontSize: 20)),
                subtitle: Text("Convert your notes to Audiobooks",
                    style: TextStyle(color: Colors.grey)),
                trailing: Icon(Icons.keyboard_arrow_right, color: clr1),
              ),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => AddAudioScreen());
              },
            ),
            GestureDetector(
              child: ListTile(
                title: Text("Evaluate Yourself",
                    style: TextStyle(color: clr1, fontSize: 20)),
                subtitle: Text("Test your skills",
                    style: TextStyle(color: Colors.grey)),
                trailing: Icon(Icons.keyboard_arrow_right, color: clr1),
              ),
              onTap: () {
                Navigator.pop(context);
                Get.to(() => TestChoice());
              },
            ),
          ],
        ),
      ),
      body: (status == fileStatus.GOT_FILES)
          ? Stack(
              children: [
                Column(
                  children: [
                    /// Main Body
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: audioFiles.length,
                                  itemBuilder: (context, int idx) {
                                    return Card(
                                      elevation: 2.0,
                                      child: GestureDetector(
                                        child: ListTile(
                                          leading: Text(audioFiles[idx]["name"],
                                              style: TextStyle(color: clr1)),
                                          // trailing: Text(
                                          //     audioFiles[idx]["time"],
                                          //     style: TextStyle(
                                          //         color: Colors.grey)),
                                        ),
                                        onTap: () async {
                                          await audioplayer.stop();
                                          setState(() {
                                            position = Duration.zero;
                                            url =
                                                audioFiles[idx]["downloadUrl"];
                                          });
                                          await audioplayer
                                              .play(UrlSource(url));
                                        },
                                      ),
                                    );
                                  }),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                /// Audio Player here
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      child: Chip(
                        label: Text("Refresh", style: TextStyle(color: clr1)),
                        backgroundColor: Colors.white,
                        elevation: 4.0,
                      ),
                      onTap: () {
                        _refresh();
                      },
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 105,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: clr1,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10))),
                      child: Center(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Slider(
                              inactiveColor: Colors.blueGrey.shade200,
                              activeColor: Colors.white,
                              min: 0,
                              max: duration.inSeconds.toDouble(),
                              value: position.inSeconds.toDouble(),
                              onChanged: (value) async {
                                final pos = Duration(seconds: value.toInt());
                                await audioplayer.seek(pos);
                                await audioplayer.resume();
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                    if (url == "") {
                                      Get.snackbar(
                                          "Code:Star", "No File Selected");
                                    } else {
                                      if (isPlaying) {
                                        await audioplayer.pause();
                                      } else {
                                        await audioplayer.play(UrlSource(url));
                                      }
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
                  ],
                ),

                /// swipe right for drawer
                Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.swipe_right_alt,
                    color: clr1,
                    size: 18,
                  ),
                )
              ],
            )
          : (status == fileStatus.SEARCHING)
              ? Center(child: CircularProgressIndicator(color: clr1))
              : Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          SizedBox(height: 60),
                          Image(
                            image: AssetImage("assets/images/notFound.png"),
                          ),
                          SizedBox(height: 32),
                          Text(
                            "Looks like you don't have any Audiobooks yet\nSwipe right and make one!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                          Expanded(child: SizedBox(height: 1)),
                          GestureDetector(
                            child: Chip(
                              label: Text("Refresh",
                                  style: TextStyle(color: clr1)),
                              backgroundColor: Colors.white,
                              elevation: 4.0,
                            ),
                            onTap: () {
                              _refresh();
                            },
                          ),
                          SizedBox(height: 8),
                        ],
                      )),
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
