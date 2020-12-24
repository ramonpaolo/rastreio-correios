//---- Packages
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class RastreioAndroid extends StatefulWidget {
  @override
  _RastreioAndroidState createState() => _RastreioAndroidState();
}

class _RastreioAndroidState extends State<RastreioAndroid> {
  TextEditingController _controllerName = TextEditingController();
  TextEditingController _controllerCode = TextEditingController();

  final _keySnackBar = GlobalKey<ScaffoldState>();
  final _form = GlobalKey<FormState>();

  var _imageUrl;
  var image;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      key: _keySnackBar,
      body: SingleChildScrollView(
        child: Container(
            child: Form(
          key: _form,
          child: Column(
            children: [
              Divider(
                color: Colors.white,
                height: 40,
              ),
              Align(
                  alignment: Alignment(-1, 0),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.yellow[700],
                      size: 34,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )),
              SvgPicture.asset(
                "assets/add_rastreio.svg",
                height: size.height * 0.3,
              ),
              Container(
                margin: EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(40)),
                child: TextFormField(
                  controller: _controllerCode,
                  validator: (value) {
                    if (value.isEmpty) {
                      _keySnackBar.currentState.showSnackBar(SnackBar(
                        content: Text("Campo de rastreio vazio"),
                      ));
                    } else if (value.length <= 12) {
                      _keySnackBar.currentState.showSnackBar(SnackBar(
                        content: Text("Campo de rastreio menor que 13"),
                      ));
                    }
                    return null;
                  },
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                      hintText: "Cole aqui o código de rastreio",
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 15)),
                ),
              ),
              Divider(
                color: Colors.white,
              ),
              Container(
                margin: EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(40)),
                child: TextFormField(
                  controller: _controllerName,
                  validator: (value) {
                    if (value.isEmpty) {
                      _keySnackBar.currentState.showSnackBar(SnackBar(
                        content: Text("Nome do rastreio vazio"),
                      ));
                    }
                    return null;
                  },
                  cursorColor: Colors.white,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                      hintText: "Nome do Rastreio",
                      fillColor: Colors.white,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(left: 15)),
                ),
              ),
              Divider(
                color: Colors.white,
              ),
              Container(
                  margin: EdgeInsets.only(left: 5, right: 5),
                  decoration: BoxDecoration(
                      color: Colors.yellow,
                      borderRadius: BorderRadius.circular(40)),
                  child: IconButton(
                    tooltip: "Adicionar Imagem",
                    icon: Icon(
                      Icons.camera,
                      color: Colors.black,
                    ),
                    onPressed: () async {
                      try {
                        image = await ImagePicker.platform
                            .pickImage(source: ImageSource.gallery);

                        setState(() {
                          _imageUrl = image.path;
                        });
                        await FirebaseStorage.instance
                            .ref(
                                "images/${FirebaseAuth.instance.currentUser.uid}/${_controllerCode.text}")
                            .putFile(File(_imageUrl));
                        _imageUrl = await FirebaseStorage.instance
                            .ref(
                                "images/${FirebaseAuth.instance.currentUser.uid}")
                            .child("${_controllerCode.text}")
                            .getDownloadURL();
                      } catch (e) {
                        print(e);
                      }
                    },
                  )),
              Divider(
                color: Colors.white,
              ),
              _imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                          child: Image.file(
                        File(image.path),
                        width: size.width,
                        height: size.height * 0.32,
                      )))
                  : Text(""),
              Divider(
                color: Colors.white,
              ),
              GestureDetector(
                  onTap: () async {
                    if (_controllerCode.text.length == 13 &&
                        _controllerName.text != "" &&
                        _imageUrl != "") {
                      Future.delayed(Duration(seconds: 2), () => null);
                      try {
                        var copyTrack = await FirebaseFirestore.instance
                            .collection("rastreio")
                            .doc(FirebaseAuth.instance.currentUser.uid)
                            .get();

                        await FirebaseFirestore.instance
                            .collection("rastreio")
                            .doc(FirebaseAuth.instance.currentUser.uid)
                            .update({
                          "products": [
                            for (var x = 0;
                                x < copyTrack["products"].length;
                                x++)
                              copyTrack["products"][x],
                            {
                              "name": "${_controllerName.text}",
                              "code": "${_controllerCode.text}",
                              "photoUrl": "${_imageUrl}"
                            }
                          ]
                        });
                      } catch (e) {
                        await FirebaseFirestore.instance
                            .collection("rastreio")
                            .doc(FirebaseAuth.instance.currentUser.uid)
                            .set({
                          "products": [
                            {
                              "name": "${_controllerName.text}",
                              "code": "${_controllerCode.text}",
                              "photoUrl": "${_imageUrl}"
                            }
                          ]
                        });
                      }

                      Future.delayed(
                          Duration(seconds: 1), () => Navigator.pop(context));
                    } else {
                      _keySnackBar.currentState.showSnackBar(SnackBar(
                        content: Text("Complete o cadastro do rastreio"),
                      ));
                    }
                  },
                  child: Container(
                    width: 170,
                    height: 40,
                    padding: EdgeInsets.only(left: 5, right: 5),
                    decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(20)),
                    child: Center(
                        child: Text(
                      "Adicionar Rastreio",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                  ))
            ],
          ),
        )),
      ),
    );
  }
}
