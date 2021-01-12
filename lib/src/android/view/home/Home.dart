//---- Packages
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//---- Widgets
import 'package:correios/src/android/view/home/widgets/grid.builder.dart';
import 'package:correios/src/android/view/home/widgets/list.builder.dart';

class HomeAndroid extends StatefulWidget {
  HomeAndroid({Key key, this.grid}) : super(key: key);
  final bool grid;
  @override
  _HomeAndroidState createState() => _HomeAndroidState();
}

class _HomeAndroidState extends State<HomeAndroid> {
  List products = [];

  Future getData() async {
    setState(() {
      products.clear();
    });

    DocumentSnapshot datas = await FirebaseFirestore.instance
        .collection("rastreio")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    for (var x = 0; x < await datas["products"].length; x++) {
      try {
        setState(() {
          products.add({
            "code": datas["products"][x]["code"],
            "name": datas["products"][x]["name"],
            "photoUrl": datas["products"][x]["photoUrl"]
          });
        });
      } catch (e) {
        print("Sem dados para carregar");
      }
    }
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
                child: products.length == 0
                    ? IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {},
                      )
                    : widget.grid
                        ? GridViewAndroid(
                            products: products,
                          )
                        : ListAndroid(
                            products: products,
                          ))));
  }
}
