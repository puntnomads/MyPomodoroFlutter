import 'package:flutter/material.dart';
import 'package:vibrate/vibrate.dart';

void main() {
  runApp(new Container(
    color: Colors.white,
  ));
  runApp(new MaterialApp(
    theme: new ThemeData(primarySwatch: Colors.red),
    home: new HomePage(),
  ));
}

class HomePage extends StatefulWidget {
  HomePageState createState() => new HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  AnimationController _controller;
  int workingTime = 28;
  int shortBreakTime = 5;
  int longBreakTime = 4;
  bool workingNow = true;
  bool breakNow = false;
  int numberOfBreaks = 0;
  String workingTask = 'Working';
  String shortBreakTask = 'Walk Outside';
  String longBreakTask = 'Meditate';

  void startTime() {
    _controller = new AnimationController(
      vsync: this,
      duration: Duration(seconds: workingNow ? workingTime : shortBreakTime),
    )..forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        print('hello');
        workingNow = !workingNow;
        setState(() {});
        startTime();
        Vibrate.vibrate();
      }
    });
  }

  @override
  void initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: Duration(seconds: workingNow ? workingTime : shortBreakTime),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Do something
        print('hello');
        workingNow = !workingNow;
        setState(() {});
        startTime();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.play_arrow),
          onPressed: () {
            _controller.forward();
          },
        ),
        body: new Column(
          children: <Widget>[
            new RaisedButton(
              child: const Text('Pause'),
              color: Theme.of(context).accentColor,
              elevation: 4.0,
              splashColor: Colors.blueGrey,
              onPressed: () {
                // Perform some action
                _controller.stop();
              },
            ),
            new RaisedButton(
              child: const Text('Reset'),
              color: Theme.of(context).accentColor,
              elevation: 4.0,
              splashColor: Colors.blueGrey,
              onPressed: () {
                // Perform some action
                _controller.reset();
              },
            ),
            new Center(
              child: new PomodoroTimer(
                timeRemainingInSeconds: new IntTween(
                  begin: _controller.duration.inSeconds,
                  end: 0,
                ).animate(_controller),
              ),
            ),
          ],
        ));
  }
}

class PomodoroTimer extends AnimatedWidget {
  PomodoroTimer({this.timeRemainingInSeconds})
      : super(listenable: timeRemainingInSeconds);

  Animation<int> timeRemainingInSeconds;

  Widget build(BuildContext context) {
    String minutes = '${(timeRemainingInSeconds.value / 60).floor()}';
    String seconds = '${(timeRemainingInSeconds.value % 60)}'.padLeft(2, '0');
    return new Text(
      '$minutes:$seconds',
      style: Theme.of(context).textTheme.display2,
    );
  }
}

// https://gist.github.com/collinjackson/d7dfff892aeb365a28efaac531aa3b4f
// https://stackoverflow.com/questions/45130497/creating-a-custom-clock-widget-in-flutter
// https://stackoverflow.com/questions/51451662/flutter-keeping-time
