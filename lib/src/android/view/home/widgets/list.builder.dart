//---- Packages
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

//---- Screens
import 'package:correios/src/android/view/home/product.dart';

class ListAndroid extends StatefulWidget {
  ListAndroid({Key key, this.products}) : super(key: key);
  final List products;

  @override
  _ListAndroidState createState() => _ListAndroidState();
}

class _ListAndroidState extends State<ListAndroid> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ListView.builder(
      itemBuilder: (context, index) {
        return FutureBuilder(
            future: getLocationProduct(widget.products[index]["code"]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return GestureDetector(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                            height: size.height * 0.3,
                            child: Card(
                              elevation: 0,
                              child: Column(
                                children: [
                                  GestureDetector(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductAndroid(
                                                    data: snapshot.data,
                                                    name: widget.products[index]
                                                        ["name"],
                                                    urlPhoto:
                                                        widget.products[index]
                                                            ["photoUrl"],
                                                    //products[index]["image"]
                                                  ))),
                                      child: Stack(
                                        alignment: Alignment.topRight,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(30),
                                                topRight: Radius.circular(30)),
                                            child: Container(
                                              width: size.width,
                                              height: size.height * 0.2,
                                              child: Image.network(
                                                "${widget.products[index]["photoUrl"]}",
                                                width: size.width,
                                                height: size.height * 0.2,
                                                filterQuality:
                                                    FilterQuality.high,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          Align(
                                              alignment: Alignment(1, 1),
                                              child: Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10, top: 10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40)),
                                                  width: 40,
                                                  height: 40,
                                                  child: Center(
                                                    child: IconButton(
                                                      onPressed: () async =>
                                                          await removeRastreio(
                                                              index),
                                                      icon: Icon(
                                                        Icons.clear,
                                                        size: 26,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  )))
                                        ],
                                      )),
                                  ListTile(
                                      title:
                                          Text(widget.products[index]["name"]),
                                      subtitle: Text(snapshot
                                                  .data["eventos"].length !=
                                              0
                                          ? "${snapshot.data["eventos"][0]["status"]}" ==
                                                  "Objeto encaminhado"
                                              ? "${snapshot.data["eventos"][0]["subStatus"][0]} ${snapshot.data["eventos"][0]["subStatus"][1]} "
                                              : "${snapshot.data["eventos"][0]["status"]}"
                                          : "Sem eventos"),
                                      trailing: _iconTrack(snapshot.data))
                                ],
                              ),
                            ))));
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                    width: size.width,
                    height: size.height * 0.2,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ));
              } else
                return Container(
                    width: size.width,
                    height: size.height * 0.2,
                    child: Center(
                      child: Text(
                        "Error",
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                    ));
            });
      },
      itemCount: widget.products.length,
    );
  }

  Widget _iconTrack(Map data) {
    if ("${data["eventos"][0]["status"]}" == "Objeto encaminhado") {
      return Tooltip(
          child: Icon(
            Icons.track_changes,
            color: Colors.yellow[700],
          ),
          message: "Objeto em trânsito");
    } else if ("${data["eventos"][0]["status"]}" ==
        "Objeto entregue ao destinatário") {
      return Tooltip(
        child: Icon(
          Icons.person,
          color: Colors.yellow[700],
        ),
        message: "Entregue ao Destinatário",
      );
    } else {
      return Tooltip(
        child: Icon(
          Icons.delivery_dining,
          color: Colors.yellow[700],
        ),
        message: "Objeto indo ao usuário",
      );
    }
  }

  Future getLocationProduct(String codigoRastreio) async {
    var result = await http.get(
        """https://api.linketrack.com/track/json?user=ramonpaolomaran12@gmail.com&token=81a5dee9e7fd891156d3f99f5e1da6654de3873418ba938c6db20b1f5d1e69c5&codigo=$codigoRastreio""");
    try {
      return await jsonDecode(result.body);
    } catch (e) {
      print(e);
      return;
    }
  }

  Future removeRastreio(index) async {
    List updateList = [];
    DocumentSnapshot copyTrack = await FirebaseFirestore.instance
        .collection("rastreio")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    for (var x = 0; x < await copyTrack["products"].length; x++) {
      if (copyTrack["products"][x]["code"] != widget.products[index]["code"]) {
        setState(() {
          updateList.add(copyTrack["products"][x]);
        });
      }
    }

    await FirebaseFirestore.instance
        .collection("rastreio")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set({"products": updateList});
    await getData();
  }

  Future getData() async {
    setState(() {
      widget.products.clear();
    });

    DocumentSnapshot datas = await FirebaseFirestore.instance
        .collection("rastreio")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    for (var x = 0; x < await datas["products"].length; x++) {
      try {
        setState(() {
          widget.products.add({
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
}
