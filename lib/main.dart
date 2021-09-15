import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:async/async.dart';

const url = "https://api.hgbrasil.com/finance/quotations?key=17dbd118";

void main() async {
  http.Response response = await http.get(Uri.parse(url));
  print(response.body);

  runApp(MaterialApp(
    home: Container(),
  ));
}
