import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import "alert_dialog.dart";
import "navigator.dart";

class Blue extends StatefulWidget {
  GlobalKey<ScaffoldState> scaffoldKey;

  Blue({this.scaffoldKey});

  @override
  State<StatefulWidget> createState() => Blue_State(scaffoldKey: scaffoldKey);
}

class Blue_State extends State<Blue> {
  Blue_State({this.scaffoldKey});

  GlobalKey<ScaffoldState> scaffoldKey;
  bool BLEconnected = false;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice connectedDevice = null;
  BluetoothCharacteristic usedCharacteristic = null;
  StreamSubscription scanSubscription;
  StreamSubscription connection;
  bool deviceIsConnected = false;
  BluetoothDevice device;


  Text notConnected = new Text("Connect to Wearable");
  Text connected = new Text("Connected");
  Color red = Colors.red;
  Color green = Colors.lightGreen;


  @override
  void dispose() {
    scanSubscription?.cancel();
    scanSubscription = null;
    scanSubscription?.cancel();
    scanSubscription = null;
    connection?.cancel();
    connection = null;
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new ExpansionTile(
      title: new Text("Connection to Wearable"),
      children: <Widget>[
        new RaisedButton(
          onPressed: !this.BLEconnected ? connect : () {}, //Search for device if not connected
          child: this.BLEconnected ? connected : notConnected,
          color: this.BLEconnected ? green  : red,
        ),
        new Container(
            child: this.BLEconnected
                ? new RaisedButton(
                    onPressed: _cancelConnectiontoBLE,
                    child: Text("Disconnect"),
              
                  )
                : Container()),
        new Container(
            child: this.BLEconnected
                ? new RaisedButton(
                    onPressed: _testWearable,
                    color: Colors.white70,
                    child: Text("Test Wearable"),
                  )
                : Container()),
      ],
    );
  }

  void _cancelConnectiontoBLE() {
    setState(() {
      this.connection.cancel();
      this.connection = null;
      this.BLEconnected = false;
      this.device = null;
      scanSubscription = null;
      BLEconnected = false;
    });
  }

  void connect(){

    scaffoldKey.currentState.showSnackBar(
        new SnackBar(duration: new Duration(seconds: 4), content:
        new Row(
          children: <Widget>[
            new CircularProgressIndicator(),
            new Text("  Connecting...")
          ],
        ),
        ));
    searchForDevice()
        .whenComplete((){}
    );

  }



  /**
   * Search for Wearable --> Start Scan
   */
  Future searchForDevice() async {
    //async immediately returns a Future. It is required to use await
    //check for active BT
    bool bluetoothOn = await flutterBlue.isOn.catchError((e) {
      //await: Asynchronous code, wait for future to complete
      return null;
    });

    if (bluetoothOn == null) {
      //No BT available

      Alert_Dialog.show(
          context,
          new Text("No Bluetooth available!"),
          new Text(
              "Your phone doesn't support Bluetooth. You can't use the App!"));
      return;
    }

    if (!bluetoothOn) {

      //BT off
      Alert_Dialog.show(context, new Text("Bluetooth is turned off"),
          new Text("Please turn the Bluetooth on"));
      return;
    }
    scanSubscription = flutterBlue //Scan for Devices
        .scan(timeout: new Duration(seconds: 3))
        .listen((scanResult) {
      //Executed whenever new scan result found

      print("Device: " + scanResult.device.name);
      if (scanResult.device.name == "TECO Wearable 5 ") {
        print("----------------------Device Found---------------------------");
        this.device = scanResult.device;
        cancelScan();
        return;

      }
    }, onDone: cancelScan);
  }

  /*
  End Scan. Connect, if device found!
   */
  void cancelScan() {
    print("----------cancel");
    scanSubscription?.cancel(); //? operator: prevent null pointer access
    scanSubscription = null;

    if (device == null) {
      Alert_Dialog.show(
          context,
          new Text("The Wearable seems to be turned off"),
          new Text("Please turn it on!"));
      return;
    } else {
      _connect();
    }
  }

  /*
  Connect to Device
   */
  void _connect() async {
//    without timeout connection has to be terminated voluntarily
    if (!BLEconnected) {
      this.connection = flutterBlue.connect(this.device).listen((s) async {
        if (s == BluetoothDeviceState.connected) {
          List<BluetoothService> services =
              await this.device.discoverServices();
          BluetoothService service =
              services.toList().removeAt(2); //We need third characteristic only
          usedCharacteristic = service.characteristics.toList().first;

          _setStateBLEConnected();
        }
      });
    } else {
      Alert_Dialog.show(context, new Text("Device already Connected"),
          new Text("Check for connection."));
      return;
    }
  }

  void _setStateBLEConnected() {
    setState(() {
      print("-----------------------Set state");
      BLEconnected = true;
    });
  }

  /*
  Run Each Motor for about 1 sec
   */
  void _testWearable() async {

    this
        .device
        .writeCharacteristic(usedCharacteristic, [0xFF, 0x00, 0x00, 0x00]);
    await Future.delayed(new Duration(seconds: 1)); //kind of thread.sleep()
    this
        .device
        .writeCharacteristic(usedCharacteristic, [0x00, 0x00, 0x00, 0x00]);

    this
        .device
        .writeCharacteristic(usedCharacteristic, [0x00, 0xFF, 0x00, 0x00]);
    await Future.delayed(new Duration(seconds: 1));
    this
        .device
        .writeCharacteristic(usedCharacteristic, [0x00, 0x00, 0x00, 0x00]);

    this
        .device
        .writeCharacteristic(usedCharacteristic, [0x00, 0x00, 0xFF, 0x00]);
    await Future.delayed(new Duration(seconds: 1));
    this
        .device
        .writeCharacteristic(usedCharacteristic, [0x00, 0x00, 0x00, 0x00]);

    this
        .device
        .writeCharacteristic(usedCharacteristic, [0x00, 0x00, 0x00, 0xFF]);
    await Future.delayed(new Duration(seconds: 1));
    this
        .device
        .writeCharacteristic(usedCharacteristic, [0x00, 0x00, 0x00, 0x00]);
  }
}
