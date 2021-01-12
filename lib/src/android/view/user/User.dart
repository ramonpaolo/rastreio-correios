//---- Packages
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_animations/simple_animations.dart';

//---- Screens
import 'package:correios/src/android/view/auth/Login.dart';

class UserAndroid extends StatefulWidget {
  @override
  _UserAndroidState createState() => _UserAndroidState();
}

class _UserAndroidState extends State<UserAndroid> {
  var tween;

  Future getDataLocal() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(directory.path + "/data.json");
    return await jsonDecode(file.readAsStringSync());
  }

  @override
  void initState() {
    tween = MultiTween()
      ..add("head", ColorTween(begin: Colors.white, end: Colors.yellow))
      ..add("image", ColorTween(begin: Colors.white, end: Colors.transparent))
      ..add("name", ColorTween(begin: Colors.white, end: Colors.black));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return CustomAnimation(
      builder: (context, child, value) {
        return SingleChildScrollView(
            child: Center(
                child: FutureBuilder(
                    future: getDataLocal(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          child: Column(
                            children: [
                              Container(
                                child: Transform.translate(
                                  offset: Offset(0, size.height * 0.1),
                                  child: Center(
                                      child: ClipRRect(
                                    borderRadius: BorderRadius.circular(400),
                                    child: Container(
                                      color: value.get("image"),
                                      child: Image.network(
                                        snapshot.data["image"],
                                        width: size.width * 0.4,
                                        height: size.height * 0.18,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )),
                                ),
                                width: size.width,
                                height: size.height * 0.22,
                                color: value.get("head"),
                              ),
                              Divider(
                                color: Colors.transparent,
                                height: size.height * 0.11,
                              ),
                              Text(
                                snapshot.data["name"],
                                style: TextStyle(
                                    color: value.get("name"),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              TextButton(
                                child: Text(
                                  "Apagar todos os rastreios",
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () async => deleteRastreios(),
                              ),
                              TextButton(
                                child: Text(
                                  "Deslogar",
                                  style: TextStyle(color: Colors.yellow),
                                ),
                                onPressed: () async => deslogar(),
                              ),
                              TextButton(
                                child: Text(
                                  "Apagar a conta",
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () async {
                                  showDialog(
                                      context: context,
                                      child: Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          elevation: 0.0,
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                top: 16, left: 16, right: 16),
                                            width: size.width * 0.8,
                                            height: size.height * 0.1,
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  Text(
                                                      "Deseja realmente apagar a sua conta?"),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        child: Text("Não"),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: Text(
                                                          "Sim",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                        onPressed: () async =>
                                                            await deleteUser(),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          )));
                                },
                              ),
                            ],
                          ),
                        );
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Container(
                            width: size.width,
                            height: size.height,
                            child: Center(child: CircularProgressIndicator()));
                      } else {
                        return Container(
                            width: size.width,
                            height: size.height,
                            child: Center(
                              child: Text(
                                "Error",
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ));
                      }
                    })));
      },
      duration: Duration(milliseconds: 700),
      tween: tween,
    );
  }

  Future deleteUser() async {
    final file = await getDataLocal();
    await file.delete();
    await deleteRastreios();
    await FirebaseAuth.instance.currentUser.delete();
    await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginAndroid()),
        (screen) => false);
  }

  Future deleteRastreios() async {
    await FirebaseFirestore.instance
        .collection("rastreio")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .delete();
  }

  Future deslogar() async {
    await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginAndroid()),
        (screen) => false);
    final directory = await getApplicationDocumentsDirectory();
    final file = File(directory.path + "/data.json");
    await file.delete();
    await FirebaseAuth.instance.signOut();
  }
}
