//---- Packages
import 'dart:convert';
import 'dart:io';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

//---- Screens
import 'package:correios/src/android/view/home/Home.dart';
import 'package:correios/src/android/view/user/User.dart';
import 'package:correios/src/android/view/home/add_rastreio.dart';

class NavAndroid extends StatefulWidget {
  @override
  _NavAndroidState createState() => _NavAndroidState();
}

class _NavAndroidState extends State<NavAndroid> {
  bool grid = false;

  int _index = 0;

  Widget _setScreens() {
    switch (_index) {
      case 0:
        return HomeAndroid(
          grid: grid,
        );
        break;
      case 1:
        return UserAndroid();
        break;
      default:
        HomeAndroid(
          grid: grid,
        );
    }
  }

  Future getData() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(directory.path + "/data.json");
    var data = await jsonDecode(file.readAsStringSync());
    setState(() {
      grid = data["grid"];
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _index == 0
            ? AppBar(
                backgroundColor: Colors.white,
                elevation: 0.0,
                actions: [
                  IconButton(
                    tooltip: "Grid Rastreio",
                    icon: Icon(
                      Icons.grid_view,
                      color: Colors.yellow[700],
                    ),
                    onPressed: () async {
                      final directory =
                          await getApplicationDocumentsDirectory();
                      final file = File(directory.path + "/data.json");
                      var data = await jsonDecode(file.readAsStringSync());
                      setState(() {
                        data["grid"] = !data["grid"];
                        grid = data["grid"];
                      });
                      file.writeAsStringSync(jsonEncode(data));
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add,
                      color: Colors.yellow[700],
                    ),
                    tooltip: "Adicionar Rastreio",
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RastreioAndroid()));
                    },
                  )
                ],
              )
            : null,
        backgroundColor: Colors.white,
        body: _setScreens(),
        bottomNavigationBar: CurvedNavigationBar(
          color: Colors.yellow,
          backgroundColor: Colors.white,
          onTap: (index) {
            setState(() {
              _index = index;
            });
          },
          index: _index,
          height: 50,
          items: [
            Icon(
              Icons.home,
              color: Colors.white,
              size: 28,
              semanticLabel: "Home",
            ),
            Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
              semanticLabel: "User",
            )
          ],
        ));
  }
}
