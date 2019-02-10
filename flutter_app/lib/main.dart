import 'package:flutter/material.dart';
import 'navigator.dart';

void main() => runApp(MaterialApp(
  title: 'Speed Keeper',
  home: SpeedKeeper(),
));

class SpeedKeeper extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Speed Keeper',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
     home: navigator()
    );
  }
}






