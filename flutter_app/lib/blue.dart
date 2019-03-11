import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import "alert_dialog.dart";
import "navigator.dart";

class Blue extends StatefulWidget {
  GlobalKey<ScaffoldState> scaffoldKey;
  final void Function(
      BluetoothCharacteristic usedCharacteristic,
      BluetoothDevice device,
      bool connectioEstablished) setBluetoothParametersInNavigator;

  Blue({this.scaffoldKey, this.setBluetoothParametersInNavigator});

  @override
  State<StatefulWidget> createState() => Blue_State();
}

class Blue_State extends State<Blue> with AutomaticKeepAliveClientMixin<Blue> {
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;




  @override
  void initState() {
    super.initState();

  }

  StreamSubscription _scanSubscription;

  //BT Instance
  FlutterBlue flutterBlue = null;

  //Device
  BluetoothDevice device;
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;
  StreamSubscription deviceStateSubscription; //Pipe for device changes
  BluetoothCharacteristic usedCharacteristic = null;
  bool BLEdeviceConnected = false;
  bool BLEdevicePaired = false;

  /// State of BT
  StreamSubscription bluetoothconnection; //Pipe for BT connection
  StreamSubscription
      _stateSubscription; //Pipe for BT state changes (change between On and OFF)
  BluetoothState state = BluetoothState.unknown; // ON or OFF

  //Layout
  Text notConnected = new Text("Connect to Wearable");
  Text connected = new Text("    Connected    ");
  Text paired = new Text("   Waiting for Device   ");
  Text disconnect = new Text("   Disconnect   ");
  Color red = Colors.red;
  Color green = Colors.green;
  Color orange = Colors.orange;

  /*
  Create new Flutter Instance to flush old connected devices
  Create listeners for BT ON/OFF changes
   */
  void resetFlutterInstance() {
    flutterBlue = FlutterBlue.instance;
    flutterBlue.state.then((s) {
      setState(() {
        state = s;
      });
    });

    // Subscribe to state changes
    _stateSubscription = flutterBlue.onStateChanged().listen((s) {
      if (s == BluetoothState.off) {

        //Aler if BT is turned off
        Alert_Dialog.show(context, new Text("Bluetooth was turned off"),
            new Text("Please turn it on and connect to device!"));
        _cancelConnectiontoBLE();
      }
      setState(() {
        state = s;
      });
    });
  }

  @override
  void dispose() {
    print("-----------------Dispose Executed Bluetooth");
    _stateSubscription?.cancel();
    _stateSubscription = null;
    _scanSubscription?.cancel();
    _scanSubscription = null;
    bluetoothconnection?.cancel();
    bluetoothconnection = null;
    flutterBlue = FlutterBlue.instance;
    BLEdevicePaired = false;
    BLEdeviceConnected = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return new Container(
        margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
        child: Column(
          children: <Widget>[
            new RaisedButton(
              onPressed: !this.BLEdeviceConnected
                  ? connectAndDisplaySnackBar
                  : () {}, //Search for device if not connected
              child: this.BLEdeviceConnected
                  ? connected
                  : (BLEdevicePaired ? paired : notConnected),
              color: this.BLEdeviceConnected
                  ? green
                  : (BLEdevicePaired ? orange : red),
            ),
            new Container(
                child: this.BLEdeviceConnected | BLEdevicePaired
                    ? new RaisedButton(
                        onPressed: _cancelConnectiontoBLE,
                        child: disconnect,
                      )
                    : Container()),
            new Container(
                child: this.BLEdeviceConnected
                    ? new RaisedButton(
                        onPressed: _testWearable,
                        color: Colors.white70,
                        child: Text("Test Wearable"),
                      )
                    : Container()),
          ],
        ));
  }

  void _cancelConnectiontoBLE() {
    widget.setBluetoothParametersInNavigator(null, null, false);
    setState(() {
      _stateSubscription?.cancel();
      _stateSubscription = null;
      deviceStateSubscription?.cancel();
      deviceStateSubscription = null;
      bluetoothconnection?.cancel();
      bluetoothconnection = null;
      _scanSubscription?.cancel();
      _scanSubscription = null;
      BLEdevicePaired = false;
      BLEdeviceConnected = false;
      this.device = null;
    });
  }

  /*
  Create connection to device.
  Display Snack Bar while connection is running
   */
  void connectAndDisplaySnackBar() {
    widget.scaffoldKey.currentState.showSnackBar(new SnackBar(
      duration: new Duration(seconds: 3),
      content: new Row(
        children: <Widget>[
          new CircularProgressIndicator(),
          new Text("  Connecting...")
        ],
      ),
    ));

    searchForDevice();
  }

  /**
   * Search for Wearable --> Start Scan
   */
  Future searchForDevice() async {
    resetFlutterInstance();
    bool bluetoothOn = await flutterBlue.isOn.catchError((e) {
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
    _scanSubscription = flutterBlue //Scan for Devices
        .scan(timeout: new Duration(seconds: 3))
        .listen((scanResult) {
      //Executed whenever new scan result found

      if (scanResult.device.name == "TECO Wearable 4") {
        this.device = scanResult.device;
        cancelScan(); //cacle scan if device found
        return;
      }
    }, onDone: cancelScan); //Cancle scanafter timeout
  }

  /*
  End Scan. Connect, if device found!
   */
  void cancelScan() {
    print("Cancel scan");
    _scanSubscription?.cancel(); //? operator: prevent null pointer access
    _scanSubscription = null;

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
  Connect to Device and discover services.
  Subscribe to connection Change
   */
  _connect() async {


    // Disconnect before connect if already connected to prevent reconnect error
    device.state.then((s) {
      if(s == BluetoothDeviceState.connected){
        bluetoothconnection?.cancel();
        bluetoothconnection = null;
      }
    });

    // Connect to device
    this.bluetoothconnection =
        flutterBlue.connect(device, timeout: const Duration(seconds: 4)).listen(
              null, //If not successfull-> cancel
              onDone: _cancelConnectiontoBLE,
            );

    // Update the connection state immediately
    device.state.then((s) {
      setState(() {
        deviceState = s;
      });
    });

    // Subscribe to connection changes
    deviceStateSubscription = device.onStateChanged().listen((s) {
      setState(() {
        print("--------------------------------------------Device state is:" + s.toString());
        deviceState = s;
      });
      if (s == BluetoothDeviceState.connected) {
        _discoverServices();
      } else if (s == BluetoothDeviceState.disconnected) {
        _handleDisconnectedDevice();
      }
    });
  }

  /*
  Handle if device is disconnected.
  Disregard disconnection due to bluetooth changes
   */
  void _handleDisconnectedDevice() async {
    //Check if disconnection is due to BT OFF
    bool bluetoothOn = await flutterBlue.isOn;
    if (!bluetoothOn) {
      return;
    }

    Alert_Dialog.show(context, new Text("Connection Lost"),
        new Text("Please check if device is turned on!"));
    setState(() {
      BLEdeviceConnected = false;
      BLEdevicePaired = true; //Already paired, but corrently not connected
      widget.setBluetoothParametersInNavigator(usedCharacteristic, device, false);
    });
  }

  /*
  Discover services, filter as we only need the third service
   */
  void _discoverServices() {
    device.discoverServices().then((services) {
      setState(() {
        BluetoothService service =
            services.toList().removeAt(2); //We need third characteristic only
        usedCharacteristic = service.characteristics.toList().first;
        _setStateBLEConnected();
      });
    });
  }

  //Connected (implies paired, but we need differentiation between beeing connected and only being paired)
  void _setStateBLEConnected() {
    setState(() {
      BLEdeviceConnected = true;
      BLEdevicePaired = false;
    });
    widget.setBluetoothParametersInNavigator(usedCharacteristic, device, true);
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
    await Future.delayed(new Duration(seconds: 1)); //kind of thread.sleep()
    this
        .device
        .writeCharacteristic(usedCharacteristic, [0x00, 0x00, 0x00, 0x00]);
    this
        .device
        .writeCharacteristic(usedCharacteristic, [0x00, 0x00, 0xFF, 0x00]);
    await Future.delayed(new Duration(seconds: 1)); //kind of thread.sleep()
    this
        .device
        .writeCharacteristic(usedCharacteristic, [0x00, 0x00, 0x00, 0x00]);
    this
        .device
        .writeCharacteristic(usedCharacteristic, [0x00, 0x00, 0x00, 0xFF]);
    await Future.delayed(new Duration(seconds: 1)); //kind of thread.sleep()
    this
        .device
        .writeCharacteristic(usedCharacteristic, [0x00, 0x00, 0x00, 0x00]);
  }
}
