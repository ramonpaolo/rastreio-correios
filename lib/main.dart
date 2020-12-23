//---- Packages
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

//---- Screens
import 'package:correios/src/android/nav.dart';
import 'package:correios/src/ios/view/home/Home.dart';
import 'package:correios/src/android/view/auth/Login.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_splashscreen/simple_splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  Platform.isAndroid == true
      ? runApp(MaterialApp(home: SplashScreen()))
      : runApp(CupertinoApp(
          home: HomeIos(),
        ));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isLog = false;
  var file;

  void isLogged() async {
    try {
      var directory = await getApplicationDocumentsDirectory();
      file = File(directory.path + "/data.json");
      var json = await jsonDecode(file.readAsStringSync());
      print(json);
      setState(() {
        isLog = json["isLogged"];
      });
    } catch (e) {
      print("File not exists");
    }
  }

  @override
  void initState() {
    isLogged();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Simple_splashscreen(
      context: context,
      gotoWidget: isLog ? NavAndroid() : LoginAndroid(),
      splashscreenWidget: SplashAnimation(),
      timerInSeconds: 2,
    );
  }
}

class SplashAnimation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 1000,
        height: 1000,
        color: Colors.yellow,
      ),
    );
  }
}
