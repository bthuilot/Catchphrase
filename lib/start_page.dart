import 'package:flutter/material.dart';
import 'main.dart';


class StartPage extends StatefulWidget {
  StartPage({Key key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _StartPageState createState() => new _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool animals = true;
  bool food = true;
  bool house = true;
  bool people = true;

  static const String housePath = 'assets/wordlists/household.txt';
  static const String animalPath = 'assets/wordlists/animals.txt';
  static const String foodPath = 'assets/wordlists/food.txt';
  static const String peoplePath = 'assets/wordlists/people.txt';

  List<String> paths = [housePath, animalPath, foodPath, peoplePath];


  void _change(String path) {
    if (paths.contains(path)) {
      paths.remove(path);
    }else {
      paths.add(path);
    }
  }

  Container _addWordList(String name, Checkbox checkbox) {
    return Container(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column (
          children: <Widget>[
          new Text(name),
           checkbox,
          ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Catchphrase"),
      ),
      body: Center(
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.only(bottom: 32.0),
                  child: new Text(
                    'Select which word lists to use',
                    style: Theme.of(context).textTheme.display2,
                    textAlign: TextAlign.center,
                  )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  this._addWordList("Household Items", new Checkbox(value: house, onChanged: (bool on) {
                    setState(() {
                      house = on;
                    });
                    this._change(housePath);
                  })),
                  this._addWordList("People", new Checkbox(value: people, onChanged: (bool on) {
                    setState(() {
                      people = on;
                    });
                    this._change(peoplePath);
                  })),
                  this._addWordList("Animals", new Checkbox(value: animals, onChanged: (bool on) {
                    setState(() {
                      animals = on;
                    });
                    this._change(animalPath);
                  })),
                  this._addWordList("Food", new Checkbox(value: food, onChanged: (bool on) {
                    setState(() {
                      food = on;
                    });
                    this._change(foodPath);
                  })),
                ]
              ),

              RaisedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage(paths: this.paths)),
                  );
                },
                child: Text('Start Game'),
              ),
            ]
        ),
      ),
    );
  }
}