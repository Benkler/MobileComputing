import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import "alert_dialog.dart";
import 'package:location/location.dart';
import 'package:flutter/services.dart';

class Running extends StatefulWidget {
  //Values for Bluetooth
  BluetoothCharacteristic usedCharacteristic = null;
  BluetoothDevice device = null;
  bool connectionEstablished = false;

  //Values for Time_Settings
  int minutes = 6; //Initial values
  int seconds = 30;

  @override
  State<StatefulWidget> createState() => Running_State(
      connectionEstablished: connectionEstablished,
      device: device,
      usedCharacteristic: usedCharacteristic,
      seconds: seconds,
      minutes: minutes);

  Running(
      {@required this.connectionEstablished,
      @required this.device,
      @required this.usedCharacteristic,
      @required this.minutes,
      @required this.seconds});
}

class Running_State extends State<Running> {
  Running_State(
      {@required this.connectionEstablished,
      @required this.device,
      @required this.usedCharacteristic,
      @required this.minutes,
      @required this.seconds});

  //Values for Bluetooth
  BluetoothCharacteristic usedCharacteristic;
  BluetoothDevice device;
  bool connectionEstablished;

  //Values for Time_Settings
  int minutes; //Initial values
  int seconds;

  //GPS
  Map<String, double> currentLocation = new Map();
  StreamSubscription<Map<String, double>> locationSubscription;

  Location location = new Location();
  String error;

  @override
  void initState() {
    super.initState();
    currentLocation['latitude'] = 0.0;
    currentLocation['longitude'] = 0.0;
    initPlatformState();
    locationSubscription =
        location.onLocationChanged().listen((Map<String, double> result) {
      setState(() {
        currentLocation = result;
      });
    });
  }

  void initPlatformState() async {
    Map<String, double> myLocation;
    try {
      myLocation = await location.getLocation();
      error = "";
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error =
            'Permission denied - please ask the user to enable it from the app settings';
        myLocation = null;
      }

      setState(() {
        currentLocation = myLocation;
      });


    }
  }

  @override
  Widget build(BuildContext context) {
    print("Running state build executed: " + connectionEstablished.toString());
    return new Container(
      child: new Column(
        children: <Widget>[
          new Text(
              "Connection Established: " + connectionEstablished.toString()),
          new Text("device: " + device.toString()),
          new Text("usedCharacteristic: " + usedCharacteristic.toString()),
          new Text("minutes: " + minutes.toString()),
          new Text("seconds: " + seconds.toString()),
          new Text("Latitude: " +  currentLocation['latitude'].toString())
        ],
      ),
    );
  }
}
