import 'package:flutter/material.dart';

import 'views/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bet Control',
      theme: ThemeData(
          textTheme: TextTheme(
            bodyText1: TextStyle(),
            bodyText2: TextStyle(),
          ).apply(bodyColor: Colors.white, displayColor: Colors.white),
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          backgroundColor: Color.fromRGBO(53, 51, 51, 1)),
      darkTheme: ThemeData(
          textTheme: TextTheme(
            bodyText1: TextStyle(),
            bodyText2: TextStyle(),
          ).apply(bodyColor: Colors.white, displayColor: Colors.white),
          primarySwatch: Colors.green,
          primaryColor: Color.fromRGBO(53, 51, 51, 1),
          backgroundColor: Color.fromRGBO(53, 51, 51, 1)),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Anote sua aposta'),
    );
  }
}
