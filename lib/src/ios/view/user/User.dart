import 'package:flutter/cupertino.dart';

class UserIos extends StatefulWidget {
  @override
  _UserIosState createState() => _UserIosState();
}

class _UserIosState extends State<UserIos> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      child: Column(
        children: [Text("Eae")],
      ),
    ));
  }
}
