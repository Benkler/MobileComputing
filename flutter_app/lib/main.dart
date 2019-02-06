import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  title: 'Flutter Tutorial',
  home: TutorialHome(),
));

class TutorialHome extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text("Counter"),
        ),
        body:new Center(
          child:new Counter(),
        ),
      ),
    );
  }
}

class Counter extends StatefulWidget {
  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State {
  int _counter = 0;

  void _increment() {
    setState(() {
      ++_counter;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new Text(
          'You have pushed the button this many times:',
        ),
        new CounterDisplay(count : _counter),
        new ChangeCounterButton(onPressed: _increment),
      ],
    );
  }
}

class CounterDisplay extends StatelessWidget {
  CounterDisplay({this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Text('$count');
  }
}

class ChangeCounterButton extends StatelessWidget {
  ChangeCounterButton({this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      tooltip: 'Increment',
      onPressed: onPressed,
      child: new Icon(Icons.add),
    );
  }
}