// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const url = "https://api.hgbrasil.com/finance/quotations?key=17dbd118";

void main() async {
  runApp(
    MaterialApp(
      home: const Home(),
      theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: const InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.amber,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.amber,
            ),
          ),
          hintStyle: TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final euroController = TextEditingController();
  final poundController = TextEditingController();

  late double dollar, euro, pound;

  _resetFields() {
    realController.text = "";
    dollarController.text = "";
    euroController.text = "";
    poundController.text = "";
  }

  _realChanged(String text) {
    double real = double.parse(text);
    dollarController.text = (real / dollar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
    poundController.text = (real / pound).toStringAsFixed(2);
  }

  _dollarChanged(String text) {
    double dollar = double.parse(text);
    realController.text = (dollar * this.dollar).toStringAsFixed(2);
    euroController.text = (dollar * this.dollar / euro).toStringAsFixed(2);
    poundController.text = (dollar * this.dollar / pound).toStringAsFixed(2);
  }

  _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dollarController.text = (euro * this.euro / dollar).toStringAsFixed(2);
    poundController.text = (euro * this.euro / pound).toStringAsFixed(2);
  }

  _poundChanged(String text) {
    double pound = double.parse(text);
    realController.text = (pound * this.pound).toStringAsFixed(2);
    dollarController.text = (pound * this.pound / dollar).toStringAsFixed(2);
    euroController.text = (pound * this.pound / euro).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Conversor de Moedas",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.black,
            onPressed: _resetFields,
          )
        ],
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getCurrencies(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  "Carregando...",
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Ocorreu um erro :(",
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                dollar = snapshot.data!["USD"]["buy"];
                euro = snapshot.data!["EUR"]["buy"];
                pound = snapshot.data!["GBP"]["buy"];

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.monetization_on_rounded,
                        color: Colors.amber,
                        size: 170,
                      ),
                      Divider(),
                      buildTextField(
                          "BRL", "R\$ ", realController, _realChanged),
                      Divider(),
                      buildTextField(
                          "USD", "US\$ ", dollarController, _dollarChanged),
                      Divider(),
                      buildTextField(
                          "EUR", "€ ", euroController, _euroChanged),
                      Divider(),
                      buildTextField(
                          "GBP", "£ ", poundController, _poundChanged)
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

buildTextField(String _labelText, String _prefix,
    TextEditingController _controller, Function _function) {
  return TextField(
    controller: _controller,
    style: const TextStyle(
      color: Colors.amber,
      fontSize: 25,
    ),
    decoration: InputDecoration(
      labelText: _labelText,
      labelStyle: const TextStyle(color: Colors.white),
      border: const OutlineInputBorder(),
      prefix: Text(
        _prefix,
        style: const TextStyle(
          color: Colors.amber,
          fontSize: 25,
        ),
      ),
    ),
    keyboardType: TextInputType.numberWithOptions(decimal: true, signed: false),
    onChanged: (String value) {
      _function(value);
    },
  );
}

Future<Map> getCurrencies() async {
  http.Response response = await http.get(Uri.parse(url));
  return json.decode(response.body)["results"]["currencies"];
}
