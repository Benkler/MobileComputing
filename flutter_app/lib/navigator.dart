import 'package:flutter/material.dart';
import 'time_settings.dart';

class navigator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _navigator_state();
}

class _navigator_state extends State<navigator> {


  String test = "bla";


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
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
              Icon(Icons.settings_bluetooth),
            ],
          ),
        ),
      ),
    );
  }



}
