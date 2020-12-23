import 'package:flutter/cupertino.dart';

class HomeIos extends StatefulWidget {
  @override
  _HomeIosState createState() => _HomeIosState();
}

class _HomeIosState extends State<HomeIos> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: SingleChildScrollView(
      child: Container(
        child: Column(
          children: [],
        ),
      ),
    ));
  }
}
