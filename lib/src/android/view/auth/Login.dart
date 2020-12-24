//---- Packages
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

//---- Screens
import 'package:correios/src/android/nav.dart';
import 'package:correios/src/android/view/auth/Cadastro.dart';

class LoginAndroid extends StatefulWidget {
  @override
  _LoginAndroidState createState() => _LoginAndroidState();
}

class _LoginAndroidState extends State<LoginAndroid> {
  bool visiblePassword = true;

  TextEditingController _controllerEmail = TextEditingController();
  TextEditingController _controllerPassword = TextEditingController();

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
                              bottomRight: Radius.circular(100))),
                    ),
                    Align(
                      alignment: Alignment(1, 0),
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_forward,
                          color: Colors.yellow,
                          size: 38,
                        ),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CadastroAndroid())),
                      ),
                    ),
                  ],
                ),
                Divider(
                  color: Colors.white,
                  height: size.height * 0.06,
                ),
                SvgPicture.asset(
                  "assets/auth.svg",
                  height: size.height * 0.24,
                ),
                campForm(
                  TextInputType.emailAddress,
                  size,
                  "Digite seu email",
                  Icon(
                    Icons.email,
                    color: Colors.black,
                  ),
                  _controllerEmail,
                ),
                Divider(
                  color: Colors.white,
                  height: 20,
                ),
                campForm(
                  TextInputType.visiblePassword,
                  size,
                  "Digite sua senha",
                  Icon(
                    Icons.vpn_key,
                    color: Colors.black,
                  ),
                  _controllerPassword,
                ),
                Divider(
                  color: Colors.white,
                ),
                GestureDetector(
                  onTap: () async => await login(),
                  child: Container(
                    width: size.width * 0.3,
                    height: size.height * 0.05,
                    child: Center(
                        child: Text("Logar",
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
                  color: Colors.white,
                  height: size.height * 0.18,
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
                                          Text("Rastremento de encomendas: "),
                                          Text(
                                            "API do Link&Track",
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
                                          Text("Icones: "),
                                          Text(
                                            "FreePik, Iconscout",
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

  void snackBar(String text) {
    _snackBar.currentState.showSnackBar(SnackBar(
      backgroundColor: Colors.yellow,
      content: Text("$text",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    ));
  }

  Future login() async {
    if (_controllerEmail.text == "" || _controllerPassword.text == "") {
      snackBar("Preencha todos os campos");
    } else if (_controllerEmail.text != "" && _controllerPassword.text != "") {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _controllerEmail.text, password: _controllerPassword.text);
        var directory = await getApplicationDocumentsDirectory();
        final file = File(directory.path + "/data.json");
        await file.writeAsStringSync(await jsonEncode({
          "isLogged": true,
          "name": FirebaseAuth.instance.currentUser.displayName,
          "email": FirebaseAuth.instance.currentUser.email,
          "image": FirebaseAuth.instance.currentUser.photoURL
        }));
        print("Dados salvos");
        await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => NavAndroid()),
            (screen) => false);
      } catch (e) {
        if (e.code == "user-not-found") {
          snackBar("Email não encontrado");
        } else if (e.code == "wrong-password") {
          snackBar("Senha errada");
        } else if (e.code == "invalid-email") {
          snackBar("Email inválido");
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
        obscureText: text == "Digite sua senha" ? visiblePassword : false,
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: icon,
            suffixIcon: text == "Digite sua senha"
                ? IconButton(
                    icon: visiblePassword
                        ? Icon(
                            Icons.remove_red_eye,
                            color: Colors.black,
                          )
                        : Icon(
                            Icons.remove_red_eye_outlined,
                            color: Colors.black,
                          ),
                    onPressed: () {
                      setState(() {
                        visiblePassword = !visiblePassword;
                      });
                    },
                  )
                : null,
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
