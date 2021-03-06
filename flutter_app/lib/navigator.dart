import 'package:flutter/material.dart';
import 'time_settings.dart';
import 'blue.dart';
import 'running.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import 'package:flutter/services.dart';

class navigator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _navigator_state();
}

class _navigator_state extends State<navigator> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  //Values for Time_Settings
  int _minutes = 6; //Initial values
  int _seconds = 30;

  //Values for Bluetooth
  BluetoothCharacteristic _usedCharacteristic = null;
  BluetoothDevice _device;
  bool _connectionEstablished = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
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
              Running(connectionEstablished: _connectionEstablished,device: _device,usedCharacteristic: _usedCharacteristic,seconds: _seconds, minutes: _minutes,),
              Time_Settings(
                  minutes: _minutes,
                  seconds: _seconds,
                  setMinutes: _setMinutes,
                  setSeconds: _setSeconds),
              Blue(
                scaffoldKey: scaffoldKey, setBluetoothParametersInNavigator: setBluetoothParameters ,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Callback function to set minutes
  void _setMinutes(int minutes) {
    setState(() {
      print("----------------------------Minutes changed to ${minutes}");
      _minutes = minutes;
    });
  }

  //Callbackfunction to set seconds
  void _setSeconds(int seconds) {
    setState(() {
      print("------------------------------Seconds changed to ${seconds}");
      _seconds = seconds;
    });
  }

  void setBluetoothParameters(
      BluetoothCharacteristic usedCharacteristic, BluetoothDevice device, bool connectionEstablished) {
    print("Set BT param --------------------------------");
    print("Bool: " + connectionEstablished.toString() );
    setState(() {
      this._device = device;
      this._usedCharacteristic = usedCharacteristic;
      this._connectionEstablished = connectionEstablished;
    });
  }
}
