import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:correios/src/android/view/home/product.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ListAndroid extends StatefulWidget {
  ListAndroid({Key key, this.codes}) : super(key: key);
  final List codes;

  @override
  _ListAndroidState createState() => _ListAndroidState();
}

class _ListAndroidState extends State<ListAndroid> {
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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ListView.builder(
      itemBuilder: (context, index) {
        return FutureBuilder(
            future: getLocationProduct(widget.codes[index]["code"]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return GestureDetector(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                            height: size.height * 0.3,
                            child: Card(
                              elevation: 0.0,
                              child: Column(
                                children: [
                                  GestureDetector(
                                      onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProductAndroid(
                                                    data: snapshot.data,
                                                    name: widget.codes[index]
                                                        ["name"],
                                                    urlPhoto:
                                                        widget.codes[index]
                                                            ["photoUrl"],
                                                    //codes[index]["image"]
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
                                                "${widget.codes[index]["photoUrl"]}",
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
                                                      onPressed: () async {
                                                        List updateList = [];
                                                        print(
                                                            widget.codes[index]
                                                                ["code"]);
                                                        DocumentSnapshot
                                                            copyTrack =
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    "rastreio")
                                                                .doc(await FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    .uid)
                                                                .get();
                                                        for (var x = 0;
                                                            x <
                                                                await copyTrack[
                                                                        "products"]
                                                                    .length;
                                                            x++) {
                                                          if (copyTrack[
                                                                      "products"]
                                                                  [x]["code"] !=
                                                              widget.codes[
                                                                      index]
                                                                  ["code"]) {
                                                            setState(() {
                                                              updateList.add(
                                                                  copyTrack[
                                                                          "products"]
                                                                      [x]);
                                                            });
                                                          }
                                                        }

                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                "rastreio")
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                .uid)
                                                            .set({
                                                          "products": updateList
                                                        });
                                                        await getData();
                                                      },
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
                                    title: Text(widget.codes[index]["name"]),
                                    subtitle: Text(
                                      snapshot.data["eventos"][0]["status"] ==
                                              "Objeto encaminhado"
                                          ? "${snapshot.data["eventos"][0]["subStatus"][0]} ${snapshot.data["eventos"][0]["subStatus"][1]} "
                                          : snapshot.data["eventos"][0]
                                              ["status"],
                                    ),
                                    trailing: Icon(
                                      Icons.track_changes,
                                      color: Colors.yellow[700],
                                    ),
                                  )
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
              } else if (snapshot.connectionState == ConnectionState.none) {
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
              }
            });
      },
      itemCount: widget.codes.length,
    );
  }

  Future getData() async {
    setState(() {
      widget.codes.clear();
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
            widget.codes.add({
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
}
