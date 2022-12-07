import 'dart:convert';

import 'package:code_star/Utils/constants.dart';
import 'package:code_star/Views/Home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class AuthScreen extends StatefulWidget {
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final box = GetStorage();
  bool hasAccount = false;
  final emailController = new TextEditingController();
  final passController = new TextEditingController();
  String _email = "";
  String _password = "";
  bool haveID = false;

  @override
  void initState() {
    check();
    super.initState();
  }

  void check() async {
    String? userID = box.read("userID");
    if (userID != null)
      setState(() {
        haveID = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: haveID
            ? Homepage()
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * 0.27,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(50),
                              bottomRight: Radius.circular(50),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: 65),
                              Image.asset(
                                'assets/images/intro.png',
                                height: 250,
                              ),
                              SizedBox(height: 30),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Text("Code:Star",
                        style: TextStyle(
                            color: clr1, letterSpacing: 3, fontSize: 24)),
                    Form(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  labelText: 'Enter your email',
                                  hintText: 'ex: test@gmail.com',
                                ),
                                onChanged: (value) {
                                  _email = value;
                                },
                                validator: (value) {}),
                            SizedBox(height: 10),
                            TextFormField(
                              controller: passController,
                              decoration: InputDecoration(
                                labelText: 'Enter your password',
                              ),
                              obscureText: true,
                              onChanged: (value) {
                                _password = value;
                              },
                              validator: (value) {},
                            ),
                            SizedBox(height: 72),

                            /// login/register button

                            Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: GestureDetector(
                                  child: Container(
                                    height: 55,
                                    width: double.infinity,
                                    child: Center(
                                        child: hasAccount
                                            ? Text(
                                                "Register",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )
                                            : Text(
                                                "Login",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              )),
                                    decoration: BoxDecoration(
                                        color: clr1,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25))),
                                  ),
                                  onTap: () {
                                    hasAccount
                                        ? SignUp(_email, _password)
                                        : SignIn(_email, _password);
                                    emailController.text = "";
                                    passController.text = "";
                                  },
                                )),

                            /// login/register button ends
                            SizedBox(height: 64),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                hasAccount
                                    ? Text("Already have an account?  ",
                                        style: TextStyle(color: Colors.grey))
                                    : Text("Don't have an account?  ",
                                        style: TextStyle(color: Colors.grey)),
                                GestureDetector(
                                    child: hasAccount
                                        ? Text("Login",
                                            style: TextStyle(color: clr1))
                                        : Text("Register",
                                            style: TextStyle(color: clr1)),
                                    onTap: () {
                                      setState(() {
                                        hasAccount = !hasAccount;
                                      });
                                    })
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ));
  }

  Future SignIn(String email, String password) async {
    var response = await http.post(Uri.parse("${baseUrl}/login"), body: {
      "userName": emailController.text,
      "password": passController.text
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> responseString = jsonDecode(response.body);
      box.write("userID", responseString["userID"]);
      setState(() {
        haveID = true;
      });
    }
  }

  Future SignUp(String email, String password) async {
    var response = await http.post(Uri.parse("${baseUrl}/addUser"), body: {
      "userName": emailController.text,
      "password": passController.text
    });
    if (response.statusCode == 200) {
      Map<String, dynamic> responseString = jsonDecode(response.body);
      box.write("userID", responseString["userID"]);
      setState(() {
        haveID = true;
      });
    }
  }
}
