//---- Packages
import 'dart:convert';
import 'dart:io';

import 'package:correios/src/android/view/auth/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//---- Screens
import 'package:correios/src/android/nav.dart';
import 'package:path_provider/path_provider.dart';

class CadastroAndroid extends StatefulWidget {
  @override
  _CadastroAndroidState createState() => _CadastroAndroidState();
}

class _CadastroAndroidState extends State<CadastroAndroid> {
  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();
  TextEditingController _controllerName = TextEditingController();

  final _snackBar = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        key: _snackBar,
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: size.width,
                      height: size.height * 0.23,
                      decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(110))),
                    ),
                    Align(
                      alignment: Alignment(-1, 0),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.yellow,
                          size: 38,
                        ),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginAndroid())),
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: Colors.white,
                  height: size.height * 0.25,
                ),
                campForm(
                    TextInputType.name,
                    size,
                    "Digite seu nome completo",
                    Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                    _controllerName),
                Divider(
                  color: Colors.white,
                  height: 20,
                ),
                campForm(
                    TextInputType.emailAddress,
                    size,
                    "Digite seu email",
                    Icon(
                      Icons.email,
                      color: Colors.black,
                    ),
                    _controllerEmail),
                Divider(
                  color: Colors.white,
                  height: 20,
                ),
                campForm(
                    TextInputType.visiblePassword,
                    size,
                    "Digite uma senha",
                    Icon(
                      Icons.remove_red_eye,
                      color: Colors.black,
                    ),
                    _controllerPassword),
                Divider(
                  color: Colors.white,
                ),
                GestureDetector(
                  onTap: () async => await cadastro(),
                  child: Container(
                    width: size.width * 0.3,
                    height: size.height * 0.05,
                    child: Center(
                        child: Text("Cadastrar",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16))),
                    decoration: BoxDecoration(
                        color: Colors.yellow,
                        borderRadius: BorderRadius.circular(40)),
                  ),
                ),
                Divider(
                  height: size.height * 0.15,
                  color: Colors.white,
                ),
                Align(
                    alignment: Alignment(0.95, 0),
                    child: GestureDetector(
                        onTap: () => showModalBottomSheet(
                              context: context,
                              elevation: 0,
                              builder: (context) {
                                return Container(
                                  padding: EdgeInsets.all(16),
                                  height: size.height * 0.4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Divider(
                                        color: Colors.white,
                                      ),
                                      Text(
                                        "Sobre o desenvolvimento do App Rastreio Encomendas",
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 16),
                                      ),
                                      Divider(
                                        color: Colors.white,
                                      ),
                                      Text(
                                          "O App foi feito utilizando alguns recursos gratuitos, como:"),
                                      Divider(
                                        color: Colors.white,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text("  Rastremento de encomendas: "),
                                          Text(
                                            " API do Link&Track",
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text("  Icones: "),
                                          Text(
                                            " FreePik",
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        child: Container(
                            width: size.width * 0.2,
                            height: size.height * 0.05,
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(child: Text("Sobre")))))
              ],
            ),
          ),
        ));
  }

  Future cadastro() async {
    if (_controllerEmail.text == "" ||
        _controllerPassword.text == "" ||
        _controllerName.text == "") {
      _snackBar.currentState.showSnackBar(SnackBar(
        backgroundColor: Colors.yellow,
        content: Text("Preencha todos os campos",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ));
    } else if (_controllerEmail.text != "" &&
        _controllerPassword.text != "" &&
        _controllerName.text != "") {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _controllerEmail.text, password: _controllerPassword.text);
        await FirebaseAuth.instance.currentUser
            .updateProfile(displayName: _controllerName.text);
        var directory = await getApplicationDocumentsDirectory();
        final file = File(directory.path + "/data.json");
        await file.writeAsStringSync(jsonEncode({
          "isLogged": true,
          "name": _controllerName.text,
          "email": _controllerEmail.text
        }));
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => NavAndroid()),
            (screen) => false);
      } catch (e) {
        if (e.code == "email-already-in-use") {
          _snackBar.currentState.showSnackBar(SnackBar(
            backgroundColor: Colors.yellow,
            content: Text("Email já está em uso",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ));
        }
        print(e);
      }
    }
  }

  Widget campForm(TextInputType keyboardType, Size size, String text, Icon icon,
      TextEditingController controller) {
    return Container(
      width: size.width * 0.9,
      height: size.height * 0.06,
      decoration: BoxDecoration(
        color: Colors.yellow,
        borderRadius: BorderRadius.circular(40),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: icon,
            border: InputBorder.none,
            hintText: text,
            contentPadding: EdgeInsets.only(left: 0, top: 14),
            hintStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        keyboardType: keyboardType,
      ),
    );
  }
}
