import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() => runApp(MaterialApp(
      title: 'Flutter Tutorial',
      home: TutorialHome(),
    ));

class TutorialHome extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      //Android Spezifische App, Darf nur ein mal auftreten
      title: 'Running Assistant', //Text bei App auf dem Handy
      theme: new ThemeData(
        //Hauptfarbe für die Anwendung
        primarySwatch: Colors.blue,
      ),

      home: new DefaultTabController(
          length: 2,
          child: new Scaffold(
            appBar: new AppBar(
              title: new Text("Counter"),
              bottom: TabBar(tabs: [
                Tab(icon: new Icon(Icons.view_comfy)),
                Tab(icon: new Icon(Icons.wifi)),
              ]),
            ),
            body: new MyTabBarView(),
          )),
    );
  }
}

class MyTabBarView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new TabBarView(children: [
      new Counter(),
      new RandomWords(),
    ]);
  }
}

class MyList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text('Bla');
  }
}

Future<List> fetchPost() async {
  final response =
  await http.get('https://swapi.co/api/people');

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return  json.decode(response.body)['results'];
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load post');
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => new RandomWordsState();
}

class RandomWordsState extends State<RandomWords>
    with AutomaticKeepAliveClientMixin<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
// TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
   return new FutureBuilder<List>(
     future: fetchPost(),
     builder: (context, snapbla) {
       if (snapbla.hasData) {
         return  new ListView.builder(
             itemCount: snapbla.data == null ? 0 : snapbla.data.length,
             itemBuilder: (BuildContext context, int index) {
               return new Container(
                 child: new Center(
                     child: new Column(
                       // Stretch the cards in horizontal axis
                       crossAxisAlignment: CrossAxisAlignment.stretch,
                       children: <Widget>[
                         new Card(
                           child: new Container(
                             child: new Text(
                               // Read the name field value and set it in the Text widget
                               snapbla.data[index]['name'],
                               // set some style to text
                               style: new TextStyle(
                                   fontSize: 20.0, color: Colors.lightBlueAccent),
                             ),
                             // added padding
                             padding: const EdgeInsets.all(15.0),
                           ),
                         )
                       ],
                     )),
               );
             });




       } else if (snapbla.hasError) {
         return Text("${snapbla.error}");
       }

       // By default, show a loading spinner
       return CircularProgressIndicator();
     },
   );


  }

  Widget _buildRow(WordPair pair) {
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
    );
  }
}

class Counter extends StatefulWidget {
  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter>
    with AutomaticKeepAliveClientMixin<Counter> {
  int _counter = 0;

  void _increment() {
    setState(() {
      ++_counter;
    });
  }

  void _decrement() {
    setState(() {
      --_counter;
    });
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween, //Macht y-Achse Alignment weil Column
      children: [
        new Row(),
        new CounterDisplay(count: _counter),
        new Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 19),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new ChangeCounterButton(onPressed: _decrement, myText: '--'),
              new ChangeCounterButton(onPressed: _increment, myText: '++'),
            ],
          ),
        ),
      ],
    );
  }
}

class CounterDisplay extends StatelessWidget {
  final int count;
  CounterDisplay({this.count});

  @override
  Widget build(BuildContext context) {
    return new Text(
      "Counter " + '$count',
      style: new TextStyle(fontSize: 20.0),
    );
  }
}

class ChangeCounterButton extends StatelessWidget {
  ChangeCounterButton({this.onPressed, this.myText});

  final VoidCallback onPressed;
  final String myText;

  @override
  Widget build(BuildContext context) {
    return new RaisedButton(
      onPressed: onPressed,
      color: Colors.blue,
      child: new Text(
        this.myText,
        style: new TextStyle(color: Colors.white),
      ),
    );
  }
}
