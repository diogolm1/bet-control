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
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme:
          ThemeData(primarySwatch: Colors.green, primaryColor: Colors.black),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Anote sua aposta'),
    );
  }
}
