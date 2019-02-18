import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

class Result extends StatelessWidget {
  final int tooSlowTime;
  final int tooFastTime;
  final int perfectSpeedTime;
  int perfectPercent;
  int slowPercent;
  int fastPercent;

  Result(
      {@required this.perfectSpeedTime,
      @required this.tooSlowTime,
      @required this.tooFastTime}) {
    _calculatePercent();
  }

  List<CircularStackEntry> createData() {
    return <CircularStackEntry>[
      new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(
              this.tooFastTime.toDouble(), Colors.redAccent,
              rankKey: 'Q1'),
          new CircularSegmentEntry(tooSlowTime.toDouble(), Colors.blue,
              rankKey: 'Q2'),
          new CircularSegmentEntry(
              perfectSpeedTime.toDouble(), Colors.lightGreen,
              rankKey: 'Q3'),
        ],
        rankKey: 'Quarterly Profits',
      ),
    ];
  }

  void _calculatePercent() {

    int sum = tooSlowTime + perfectSpeedTime + tooFastTime;
    print("Sum: ${sum},  Slow: ${tooSlowTime},  Fast: ${tooFastTime}, Optimal: ${perfectSpeedTime}");
    fastPercent = ((tooFastTime / sum)*100).round();
    slowPercent = ((tooSlowTime / sum)*100).round();
    perfectPercent = 100 - (fastPercent + slowPercent);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);

    return new Scaffold(
      body: new Container(
          child: new Column(
        children: <Widget>[
          new Container(
            child: new AnimatedCircularChart(
                size: const Size(300.0, 300.0),
                chartType: CircularChartType.Pie,
                initialChartData: createData()),
          ),
          new Container(
              child: new Column(
            children: <Widget>[
              new Text(
                "Optimal Speed: ${perfectPercent}%",
                style: new TextStyle(color: Colors.lightGreen),
              ),
              new Text(
                "Too Slow: ${slowPercent}%",
                style: new TextStyle(color: Colors.blue),
              ),
              new Text("Too Fast: ${fastPercent}%",
                  style: new TextStyle(
                    color: Colors.redAccent,
                  ))
            ],
          )),
          new Container(
              alignment: Alignment.bottomCenter,
              child: new RaisedButton(
                color: Colors.lightGreen,
                child: new Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ))
        ],
      )),
    );
  }
}
