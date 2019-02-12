import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import "alert_dialog.dart";


class Running extends StatefulWidget{

  //Values for Bluetooth
  BluetoothCharacteristic usedCharacteristic = null;
  BluetoothDevice device = null;
  bool connectionEstablished = false;

  //Values for Time_Settings
  int minutes = 6; //Initial values
  int seconds = 30;

  @override
  State<StatefulWidget> createState() =>Running_State(connectionEstablished: connectionEstablished,device: device,usedCharacteristic: usedCharacteristic,seconds: seconds, minutes: minutes);

  Running({@required this.connectionEstablished,@required this.device,@required this.usedCharacteristic, @required this.minutes, @required this.seconds});

}

class Running_State extends State<Running>{

  //Values for Bluetooth
  BluetoothCharacteristic usedCharacteristic;
  BluetoothDevice device;
  bool connectionEstablished;

  //Values for Time_Settings
  int minutes; //Initial values
  int seconds;



  Running_State({@required this.connectionEstablished,@required this.device,@required this.usedCharacteristic, @required this.minutes, @required this.seconds});

  @override
  Widget build(BuildContext context) {
    print("Running state build executed: " + connectionEstablished.toString());
    return new Container(

      child: new Column(
        children: <Widget>[
          new Text("Connection Established: " + connectionEstablished.toString()),
          new Text("device: " + device.toString()),
          new Text("usedCharacteristic: " + usedCharacteristic.toString()),
          new Text("minutes: " + minutes.toString()),
          new Text("seconds: " + seconds.toString()),
          

        ],
      ),
      
    );
  }
  
  
  
}