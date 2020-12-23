//---- Packages
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

//---- Screens
import 'package:correios/src/ios/view/home/Home.dart';
import 'package:correios/src/ios/view/user/User.dart';

class NavAndroid extends StatefulWidget {
  @override
  _NavAndroidState createState() => _NavAndroidState();
}

class _NavAndroidState extends State<NavAndroid> {
  int _index = 0;
  List _pages = [HomeIos(), UserIos()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _pages[_index],
        bottomNavigationBar: CurvedNavigationBar(
          color: Colors.black,
          backgroundColor: Colors.yellow,
          onTap: (index) {
            setState(() {
              _index = index;
            });
          },
          index: _index,
          height: 45,
          items: [
            Icon(
              Icons.home,
              color: Colors.yellow,
              size: _index == 0 ? 18 : 24,
              semanticLabel: "Home",
            ),
            Icon(
              Icons.person,
              color: Colors.yellow,
              size: _index == 1 ? 18 : 24,
              semanticLabel: "User",
            )
          ],
        ));
  }
}
