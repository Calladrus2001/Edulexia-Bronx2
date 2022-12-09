import 'package:code_star/Utils/constants.dart';
import 'package:flutter/material.dart';

class AppointScreen extends StatefulWidget {
  const AppointScreen({Key? key}) : super(key: key);

  @override
  State<AppointScreen> createState() => _AppointScreenState();
}

class _AppointScreenState extends State<AppointScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: clr1,
        child: Icon(Icons.chat_bubble_rounded, color: Colors.white),
        onPressed: () {},
      ),
    );
  }
}
