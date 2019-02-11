import 'package:flutter/material.dart';
import 'time_settings.dart';
import 'blue.dart';

class navigator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _navigator_state();
}

class _navigator_state extends State<navigator> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  String test = "bla";


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.directions_run)),
                Tab(icon: Icon(Icons.timer)),
                Tab(icon: Icon(Icons.bluetooth)),
              ],
            ),
            title: Text('Speed Keeper'),
            backgroundColor: Colors.lightGreen,
          ),
          body: TabBarView(
            children: [
              Icon(Icons.directions_car),
              Time_Settings(),
              Blue(scaffoldKey: scaffoldKey,),
            ],
          ),
        ),
      ),
    );
  }



}
