//---- Packages
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:correios/src/android/view/home/widgets/grid.builder.dart';
import 'package:correios/src/android/view/home/widgets/list.builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//---- Screens
import 'package:correios/src/android/view/home/product.dart';

class HomeAndroid extends StatefulWidget {
  HomeAndroid({Key key, this.grid}) : super(key: key);
  final bool grid;
  @override
  _HomeAndroidState createState() => _HomeAndroidState();
}

class _HomeAndroidState extends State<HomeAndroid> {
  List codes = [];
  List products = [];

  Future getData() async {
    setState(() {
      codes.clear();
    });
    try {
      var readFile = await FirebaseFirestore.instance
          .collection("rastreio")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .get();
      for (var x = 0; x < await readFile["products"].length; x++) {
        try {
          print(readFile["products"][x]["photoUrl"]);
          setState(() {
            codes.add({
              "code": readFile["products"][x]["code"],
              "name": readFile["products"][x]["name"],
              "photoUrl": readFile["products"][x]["photoUrl"]
            });
          });
        } catch (e) {
          print("Sem dados para carregar");
        }
      }
    } catch (e) {
      print("Sem dados");
    }
  }

  Future getLocationProduct(String codigoRastreio) async {
    print("Codígo do rastreio: $codigoRastreio");
    var result = await http.get(
        """https://api.linketrack.com/track/json?user=ramonpaolomaran12@gmail.com&token=81a5dee9e7fd891156d3f99f5e1da6654de3873418ba938c6db20b1f5d1e69c5&codigo=$codigoRastreio""");
    print(await result.body);
    Map resultado = {};
    try {
      resultado = await jsonDecode(result.body);
    } catch (e) {
      print(e);
    }
    return resultado;
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Container(
            width: size.width,
            height: size.height * 0.82,
            child: RefreshIndicator(
                onRefresh: getData,
                child: widget.grid
                    ? GridViewAndroid(
                        codes: codes,
                      )
                    : ListAndroid(
                        codes: codes,
                      ))));
  }
}
