//---- Packages
import 'package:flutter/material.dart';

class ProductAndroid extends StatefulWidget {
  ProductAndroid({Key key, this.data, this.name, this.urlPhoto})
      : super(key: key);
  final Map data;
  final String name;
  final String urlPhoto;
  @override
  _ProductAndroidState createState() => _ProductAndroidState();
}

class _ProductAndroidState extends State<ProductAndroid> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Divider(
                height: size.height * 0.01,
                color: Colors.white,
              ),
              Align(
                alignment: Alignment(-1, 0),
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    size: 38,
                    color: Colors.yellow[700],
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Divider(
                height: size.height * 0.01,
                color: Colors.white,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Container(
                  height: size.height * 0.25,
                  child: Image.network(
                    "${widget.urlPhoto}",
                    filterQuality: FilterQuality.high,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Divider(
                height: size.height * 0.01,
                color: Colors.white,
              ),
              Text(
                "${widget.name}",
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
              Text(
                "${widget.data["codigo"]}",
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
              SizedBox(
                width: size.width,
                height: size.height * 0.6,
                child: ListView.builder(
                  itemCount: widget.data["eventos"].length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                            height: size.height * 0.2,
                            child: Card(
                              elevation: 0.0,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(widget.data["eventos"][index]
                                        ["status"]),
                                    subtitle: Text(
                                        "Data: ${widget.data["eventos"][index]["data"]}"),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 16, right: 16),
                                    child: Text(widget
                                                .data["eventos"][index]
                                                    ["subStatus"]
                                                .length >=
                                            2
                                        ? "${widget.data["eventos"][index]["subStatus"][0]}"
                                        : ""),
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.only(left: 16, right: 16),
                                      child: Text(widget
                                                  .data["eventos"][index]
                                                      ["subStatus"]
                                                  .length >=
                                              2
                                          ? "${widget.data["eventos"][index]["subStatus"][1]}"
                                          : "Encomenda ainda em: ${widget.data["eventos"][index]["local"]}")),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 16, right: 16, top: 6),
                                      child: Text(
                                          "Local da encomenda: ${widget.data["eventos"][index]["local"]}")),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          left: 16, right: 16, top: 6),
                                      child: Text(
                                          "Hora da postagem: ${widget.data["eventos"][index]["hora"]}")),
                                ],
                              ),
                            )));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
