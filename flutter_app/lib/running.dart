import 'package:flutter/material.dart';

import 'package:flutter_blue/flutter_blue.dart';
import 'dart:async';
import "alert_dialog.dart";
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'result.dart';

class Running extends StatefulWidget {
  //Values for Bluetooth
  BluetoothCharacteristic usedCharacteristic = null;
  BluetoothDevice device = null;
  bool connectionEstablished = false;

  //Values for Time_Settings
  int minutes;
  int seconds;

  @override
  State<StatefulWidget> createState() {
    print("-------------------------------Create State");
    return new Running_State();
  }

  Running(
      {@required this.connectionEstablished,
      @required this.device,
      @required this.usedCharacteristic,
      @required this.minutes,
      @required this.seconds});
}

class Running_State extends State<Running>
    with AutomaticKeepAliveClientMixin<Running> {
  //GPS
  Map<String, double> _currentLocation = new Map();
  Map<String, double> _startLocation = new Map();
  StreamSubscription<Map<String, double>> locationSubscription;
  Location location = new Location();
  String error = "";
  bool _permission = false;

  //Current Speed and Tracking Data
  double _discrepancyInMeterPerSecond = 0;
  double _discrepancyInSecondsPerKm = 0;
  String _currentSpeedAsString = "";
  Color _discrepancyColor = Colors.black26;
  bool _trackingStarted = false;
  bool _trackingPaused = false;
  static const allowedSpeedDiscrepancy = 10;

  //Timer for GPS
  static const timeout = const Duration(seconds: 1);
  // static const ms = const Duration(milliseconds: 1);

  //Timer for average
  int tooFastTime;
  int tooSlowTime;
  int perfectSpeedTime;
  static const interval = const Duration(seconds: 1);
  Timer averageTimeCalculator;

  //----------------------Build Widgets----------------------------

  @override
  Widget build(BuildContext context) {
    super.build(context);
    widget.minutes;
    return new Container(
      child: new Stack(children: <Widget>[
        new Positioned(
          //Start Tracking
          child: !_trackingStarted
              ? new Align(
                  child: startTrackingButton(),
                )
              : new Container(),
        ),
        new Positioned(
            //Tracking Display

            child: _trackingStarted
                ? new Align(
                    alignment: FractionalOffset.center,
                    child: trackingDisplay(),
                  )
                : new Container()),
        new Positioned(
            //Show Bottom Bar if tracking is started
            child: _trackingStarted
                ? new Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: bottomBar())
                : new Container())
      ]),
    );
  }

  Widget trackingDisplay() {
    return new FractionallySizedBox(
        widthFactor:
            (MediaQuery.of(context).orientation == Orientation.portrait)
                ? 0.7
                : 0.3,
        heightFactor:
            (MediaQuery.of(context).orientation == Orientation.portrait)
                ? 0.5
                : 0.4,
        child: _trackingPaused
            ? new Container(
                //Paused
                alignment: FractionalOffset.center,
                color: Colors.black26,
                child: new Text("Paused!"),
              )
            : Container(
                //Running
                color: _discrepancyColor,
                child: new Column(
                  //Running
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text(
                      "Current Speed:",
                      style: TextStyle(fontSize: 20),
                    ),
                    new Text(
                      _currentSpeedAsString,
                      style: TextStyle(fontSize: 20),
                    ),
                    new Text(""), //Spacer
                    new Text("Desired Speed:"),
                    new Text("${widget.minutes}' ${widget.seconds}''"),
                  ],
                )));
  }

  Widget startTrackingButton() {
    return _trackingStarted
        ? new Container()
        : new RaisedButton(
            child: new Text("Start Tracking"), onPressed: _startTracking);
  }

  /*
  Bottom Bar to pause, stop and restart Tracking
   */
  Widget bottomBar() {
    if (!_trackingStarted) {
      return new Container();
    }
    return new Container(
      decoration: BoxDecoration(color: Colors.lightGreen),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new IconButton(
            onPressed: _stopTracking,
            icon: Icon(Icons.stop),
          ),
          _trackingPaused
              ? new IconButton(
                  onPressed: _restartTracking,
                  icon: Icon(Icons.play_circle_filled))
              : new IconButton(
                  onPressed: _pauseTracking,
                  icon: Icon(Icons.pause_circle_filled),
                ),
        ],
      ),
    );
  }

  //--------------------Conversion Methods---------------------
  /*
  Calculate Speed Discrepancy in meter/sec
   */
  double _calculateCurrentDiscrepancyInMeterPerSecond() {
    double curSpeedInMeterPerSecond = _currentLocation['speed'];
    double desiredSpeedInMeterPerSecond =
        1000 / (widget.minutes * 60 + widget.seconds);
    return curSpeedInMeterPerSecond - desiredSpeedInMeterPerSecond;
  }

  /*
  - Calculate Speed Discrepancy in Seconds Per km
  -  <0 ==>  To Fast
  -  >0  ==> To Slow
   */
  double _calculateCurrentDiscrepancyInSecondsPerKm() {
    double curSpeedInSecondsPerKm = 1000 / _currentLocation['speed'];
    int desiredSpeedInSecondsPerKm = (widget.minutes * 60 + widget.seconds);
    return curSpeedInSecondsPerKm - desiredSpeedInSecondsPerKm;
  }

  /*
  Calculate String in    min ' sec'' per km
   */
  String _calculateDisplaySpeed() {
    double curSpeedInMeterPerSecond = _currentLocation['speed'];
    if (curSpeedInMeterPerSecond == 0) {
      return " 0'' 0'";
    }
    double secondsPerKilometer = 1000 / curSpeedInMeterPerSecond;

    int minutes = (secondsPerKilometer / 60).floor();
    int seconds = (secondsPerKilometer % 60).round();
    return " ${minutes}' ${seconds}''";
  }

  //---------------------------Handle Tracking State------------------

  Color _chooseDisplayColor() {
    if (_discrepancyInSecondsPerKm < -allowedSpeedDiscrepancy) {
      //To Fast
      return Colors.redAccent;
    } else if (_discrepancyInSecondsPerKm > allowedSpeedDiscrepancy) {
      return Colors.blue;
    } else {
      return Colors.lightGreen;
    }
  }

  void _startTracking() {
    if (!_checkConditionsForStarting()) {
      return;
    }
    //initSnackBar();
    setState(() {
      _trackingStarted = true;
      startTimerToCheckGPS();
      tooSlowTime = 0;
      tooFastTime = 0;
      perfectSpeedTime = 0;
      averageTimeCalculator = averageTimeCalculation();
    });
  }

  void _restartTracking() {
    setState(() {
      _trackingPaused = false;
      startTimerToCheckGPS();
      averageTimeCalculator = averageTimeCalculation();
    });
  }

  void _stopTracking() {
    averageTimeCalculator.cancel();
    setState(() {
      _trackingStarted = false;
      _trackingPaused = false;
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => Result(perfectSpeedTime: perfectSpeedTime,tooFastTime: tooFastTime,tooSlowTime: tooSlowTime,)));
    // Alert_Dialog.show(context, new Text( "Time for tracking: ${tooFastTime + tooSlowTime + perfectSpeedTime}"), new Text("Too fast: ${tooFastTime}, too slow: ${tooSlowTime}, rightTime: ${perfectSpeedTime} "));
  }

  void _pauseTracking() {
    setState(() {
      _trackingPaused = true;
      averageTimeCalculator.cancel();
    });
  }

  bool _checkConditionsForStarting() {
    return true;
  }

  void startTimerToCheckGPS() {
    new Timer.periodic(timeout, (Timer t) async {
      Map<String, double> myLocation;
      try {
        myLocation = await location.getLocation();
        //print("-----------------------------------GPS still active");
      } catch (e) {
        Alert_Dialog.show(context, new Text("You disabled the GPS"),
            new Text("Please enable it again!"));
        _pauseTracking();
        t.cancel();
      }
    });
  }

  Timer averageTimeCalculation() {
    return new Timer.periodic(interval, (Timer t) {
      if (_discrepancyInSecondsPerKm < -allowedSpeedDiscrepancy) {
        //Too fast
        tooFastTime++;
      } else if (_discrepancyInSecondsPerKm > allowedSpeedDiscrepancy) {
        //Too slow
        tooSlowTime++;
      } else {
        perfectSpeedTime++;
      }
    });
  }

  _calculateAverageTime() {}

  //-------------------------------------Init stuff------------------------------

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    locationSubscription?.cancel();
    locationSubscription = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    print("---------------------------------Init Executed");
    _currentLocation['latitude'] = 0.0;
    _currentLocation['longitude'] = 0.0;
    initPlatformState();

    //Add subscription to GPS changes
    locationSubscription =
        location.onLocationChanged().listen((Map<String, double> result) {
      setState(() {
        _currentLocation = result; //set new location incl. speed
        _discrepancyInMeterPerSecond =
            _calculateCurrentDiscrepancyInMeterPerSecond();
        _discrepancyInSecondsPerKm =
            _calculateCurrentDiscrepancyInSecondsPerKm();
        _currentSpeedAsString = _calculateDisplaySpeed();
        _discrepancyColor = _chooseDisplayColor();
        _calculateAverageTime();
      });
    });
  }

  /*
  - Initialize GPS Location
  - Ask for permission if necessary
   */
  void initPlatformState() async {
    Map<String, double> myLocation;
    try {
      _permission = await location.hasPermission();
      myLocation = await location.getLocation();
      error = "";
    } on PlatformException catch (e) {
      print("-------------------------------------Exception" + e.toString());
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error =
            'Permission denied - please ask the user to enable it from the app settings';
        myLocation = null;
      }
      //Init GPS with data
      setState(() {
        _currentLocation = myLocation;
        _startLocation = myLocation;
        if (myLocation != null) {
          _discrepancyInMeterPerSecond =
              _calculateCurrentDiscrepancyInMeterPerSecond();
        } else {
          _discrepancyInMeterPerSecond = null;
        }
      });
    }
  }
}
