import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'start_page.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';


void main() => runApp(new MyApp());
final String title = "Catchphrase!";

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Catchphrase!',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.deepPurple,
      ),
      home: new StartPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.paths}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  List<String> paths;

  @override
  _MyHomePageState createState() => new _MyHomePageState(this.paths);
}

class _MyHomePageState extends State<MyHomePage> {
  bool gameStart = false;
  int teamAScore = 0;
  int teamBScore = 0;
  List<String> _words = [];
  String _currentWord = "";
  final _rand = new Random();
  Stopwatch _stopwatch;
  final GlobalKey<AnimatedCircularChartState> _chartKey = new GlobalKey<AnimatedCircularChartState>();

  _MyHomePageState(List<String> paths) {
    this._addWordList(paths);
  }

  void _nextWord() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _currentWord = _words.removeAt(_rand.nextInt(_words.length));
    });
  }

  Future<Null> getFileData(String path) async {
    rootBundle.loadString(path).then((String str) => str.split("\n").forEach((String word) => this._addToList(word)));
  }

  void _addToList(String word) {
    this._words.add(word);
  }

  void _addWordList(List<String> paths) {
    paths.forEach((path) => getFileData(path));
  }



  void _startGame() {
    this._nextWord();
    setState(() {
      this.gameStart = true;
      new Timer(new Duration(seconds: 45), _timerUp);
      const oneSec = const Duration(seconds: 1);
      new Timer.periodic(oneSec, (Timer t) => this._updateTimer(t));
    });
  }

  Future<Null> _timerUp() async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Timer done'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text("Ended on word $_currentWord"),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Point to Team A'),
              onPressed: () {
                Navigator.of(context).pop();
                this._increaseScore(false);
              },
            ),
            new FlatButton(onPressed: () {
              Navigator.of(context).pop();
              this._increaseScore(true);
            }, child: new Text('Point to Team B'))
          ],
        );
      },
    );
  }

  void _updateTimer(Timer t) {
    _chartKey.currentState.updateData(this._getTimerData(t));
  }


  Container _centerScreen() {
    if (!gameStart) {
      return Container(
        child: new RaisedButton(onPressed: _startGame,
            child: new Text('Start')),
      );
    } else {
      return Container(
        padding: const EdgeInsets.only(top: 70.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                '$_currentWord',
                style: Theme
                    .of(context)
                    .textTheme
                    .display3,
                textAlign: TextAlign.center,
              ),
              new RaisedButton(
                  child: new Text('Next word'),
                  onPressed: _nextWord
              ),
            ]
        ),
      );
    }
  }

  Future<Null> _gameOverPopup(String team) async {
    return showDialog<Null>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text('Game over'),
          content: new SingleChildScrollView(
            child: new ListBody(
              children: <Widget>[
                new Text("$team wins!"),
              ],
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text('Return to home screen'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _increaseScore(bool teamB) {
    setState(() {
      if (!teamB) {
        teamAScore++;
        if (teamAScore > 6) {
          this._gameOverPopup("Team A");
        }
      } else {
        teamBScore++;
        if (teamBScore > 6) {
          this._gameOverPopup("Team B");
        }
      }
      this.gameStart = false;
    });
  }

  List<CircularStackEntry> _getTimerData(Timer t) {
    double percentage;
    if(t != null) {
      percentage =  ((45.0 - t.tick)/ 45.0) * 100;
    } else {
      percentage = 0.0;
    }
    if(t!= null && t.tick == 45) {
      t.cancel();
    }
    return <CircularStackEntry>[
      new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(
            percentage,
            Colors.deepPurple,
            rankKey: 'Time done',
          ),
        ],
        rankKey: 'progress',
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug paint" (press "p" in the console where you ran
          // "flutter run", or select "Toggle Debug Paint" from the Flutter tool
          // window in IntelliJ) to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Row(
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                    child: Text(
                      'Team A: $teamAScore',
                      textAlign: TextAlign.center,
                      style: Theme
                          .of(context)
                          .textTheme
                          .display1,
                    )
                ),

                Container(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                    child: Text(
                      'Team B: $teamBScore',
                      textAlign: TextAlign.center,
                      style: Theme
                          .of(context)
                          .textTheme
                          .display1,
                    )
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new AnimatedCircularChart(
                  key: _chartKey,
                  size: const Size(50.0,50.0),
                  initialChartData: this._getTimerData(null),
                  chartType: CircularChartType.Pie,
                  percentageValues: true,
                ),
              ],
            ),

            this._centerScreen(),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

