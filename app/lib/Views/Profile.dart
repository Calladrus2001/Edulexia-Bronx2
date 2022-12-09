import 'dart:convert';
import 'package:code_star/Models/HistoryModel.dart';
import 'package:code_star/Utils/constants.dart';
import 'package:code_star/Views/Auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final box = GetStorage();
  late String userID;
  int balance = 0;
  HistoryModel? histories = null;
  bool haveHistory = false;

  @override
  void initState() {
    userID = box.read("userID");
    getInfo();
    super.initState();
  }

  void getInfo() async {
    var response =
        await http.get(Uri.parse("${baseUrl}/getBalance?userID=${userID}"));
    var response2 =
        await http.get(Uri.parse("${baseUrl}/getHistory?userID=${userID}"));
    if (response.statusCode == 200) {
      Map<String, dynamic> responseString = jsonDecode(response.body);
      setState(() {
        balance = responseString["balance"][0];
      });
    }
    if (response2.statusCode == 200) {
      histories = historyModelFromJson(response2.body);
      if (histories != null || histories!.history!.length != 0) {
        setState(() {
          haveHistory = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          child: Icon(Icons.logout, color: clr1),
          onPressed: () {
            setState(() {
              box.remove("userID");
              userID = "";
            });
            Get.to(() => AuthScreen());
          },
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 90,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: clr1,
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(40))),
                child: Column(
                  children: [
                    SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.account_circle_rounded,
                              color: clr1,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text("UserID: ${userID}",
                              style: TextStyle(color: Colors.white))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: Container(
                  height: 100,
                  width: 200,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: clr1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Your Balance",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(balance.toString(),
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Your Transaction History",
                style: TextStyle(
                    color: clr1, fontSize: 18, fontWeight: FontWeight.w500),
              ),
              haveHistory
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Container(
                        child: SingleChildScrollView(
                          child: ListView.builder(
                              itemCount: histories!.history!.length,
                              shrinkWrap: true,
                              itemBuilder: (context, int idx) {
                                return Card(
                                  elevation: 2.0,
                                  child: ListTile(
                                    title: Text(
                                        histories!.history![idx].message!,
                                        style: TextStyle(
                                            fontSize: 14, color: clr1)),
                                    // subtitle: Text(histories!.history![idx].time!,
                                    //     style: TextStyle(color: Colors.grey)),
                                    trailing: histories!.history![idx].type ==
                                            "Expense"
                                        ? Text(
                                            "-${histories!.history![idx].cost}",
                                            style: TextStyle(
                                                color: Colors.red.shade300),
                                          )
                                        : Text(
                                            "+${histories!.history![idx].cost}",
                                            style: TextStyle(
                                                color: Colors.green.shade300),
                                          ),
                                  ),
                                );
                              }),
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 250,
                            child: Image(
                              image: AssetImage("assets/images/notFound.png"),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Looks like you haven't made any transactions yet.\nLet's make an Audiobook or attempt a test to get started.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          )
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
