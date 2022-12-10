import 'package:code_star/Utils/constants.dart';
import 'package:code_star/Views/Evaluate/writing.dart';
import 'package:code_star/Views/Evaluate/reading.dart';
import 'package:flutter/material.dart';

class TestChoice extends StatefulWidget {
  const TestChoice({Key? key}) : super(key: key);

  @override
  State<TestChoice> createState() => _TestChoiceState();
}

class _TestChoiceState extends State<TestChoice> {
  List<Widget> bodyPages = [ReadingTest(), HearingTest()];
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: _index,
          selectedItemColor: clr1,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle_rounded), label: "Reading"),
            BottomNavigationBarItem(
                icon: Icon(Icons.speaker_notes_outlined),
                label: "Transcription"),
          ],
          onTap: (int index) {
            setState(() {
              _index = index;
            });
          },
        ),
        body: Stack(
          children: [
            IndexedStack(
              index: _index,
              children: bodyPages,
            ),
          ],
        ));
  }
}
