import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';



class Time_Settings extends StatelessWidget {
  Text text;
  int minutes;
  int seconds;

  final void Function(int) setMinutes;
  final void Function(int) setSeconds;


  Time_Settings({@required this.minutes, @required this.seconds, @required this.setMinutes, @required this.setSeconds});



  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new ListView(
      children: <Widget>[
        //Time Header
        new Container(
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: new Time_Header(),
        ),

        //Time Picker
        new Container(
            child: new My_Time_Picker(
                initialSeconds: seconds,
                initialMinutes: minutes,
                changeMinutes: setMinutes,
                changeSeconds: setSeconds)),

        //Show Time
        new Container(
          child: new Show_Time(
            seconds: seconds,
            minutes: minutes,
          ),
        ),

        new Container(
          margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: new Recommendations(),
        ),

        new Container(
          
          child: new Warning(),
        ),
      ],
    ));
  }
}

class My_Time_Picker extends StatelessWidget {
  int initialMinutes;
  int initialSeconds;
  final void Function(int) changeSeconds;
  final void Function(int) changeMinutes;

  My_Time_Picker(
      {this.initialMinutes,
      this.initialSeconds,
      this.changeSeconds,
      this.changeMinutes});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Container(
      //Time Picker
      margin: EdgeInsets.fromLTRB(50, 10, 50, 20),
      decoration:
          new BoxDecoration(border: new Border.all(color: Colors.black26)),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new My_Number_Picker(
            initialValue: initialMinutes,
            min: 2,
            max: 12,
            onChange: changeMinutes,
          ),
          new Container(
            child: new Text(
              ":",
              textScaleFactor: 2.0,
              style: new TextStyle(color: Colors.blue),
            ),
          ),
          new My_Number_Picker(
            initialValue: initialSeconds,
            min: 0,
            max: 59,
            onChange: changeSeconds,
          ),
        ],
      ),
    );
  }
}

class Warning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ExpansionTile(
      title: new Text("Warnings"),
      backgroundColor: Colors.black12,
      children: <Widget>[
        new Container(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: new RichText(
              text: new TextSpan(
            text:
                "Excessive physical effort can lead to damage to health. It is recommended to set a low average time first. ",
            style: TextStyle(
              color: Colors.black,
            ),
          )),
        ),
      ],
    );
  }
}

class Recommendations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ExpansionTile(
      title: new Text("Recommendations"),
      backgroundColor: Colors.black12,
      children: <Widget>[
        new Container(
            child: new Text(
          "Beginner: 7'59'' - 6'20'' ",
        )),
        new Container(
            child: new Text(
          "Average: 6'19'' - 5'00 ",
        )),
        new Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: new Text(
          "Advanced: 4'59 - 2'30'' ",
        )),
      ],
    );
  }
}

//Single number Picker
class My_Number_Picker extends StatelessWidget {
  int initialValue;
  int min;
  int max;
  final void Function(int) onChange;

  My_Number_Picker({this.initialValue, this.min, this.max, this.onChange});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new NumberPicker.integer(
        initialValue: initialValue,
        minValue: min,
        maxValue: max,
        onChanged: (newValue) => onChange(newValue));
  }
}

class Time_Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Container(
          margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
          child: new Text("Minuten", textScaleFactor: 1.5),
        ),
        new Container(
            child: new Text(
          "Sekunden",
          textScaleFactor: 1.5,
        )),
      ],
    );
  }
}

class Show_Time extends StatelessWidget {
  int minutes;
  int seconds;
  Show_Time({this.minutes, this.seconds});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new Icon(Icons.access_alarms),
        new Text(" "),
        new Text(
          "Tempo: $minutes' $seconds '' pro km",
          style: new TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
