import 'package:flutter/material.dart';
import 'package:vibrate/vibrate.dart';
import 'package:screen/screen.dart';

void main() {
  runApp(new MaterialApp(
    home: new Pomodoro(),
  ));
}

class Pomodoro extends StatefulWidget {
  PomodoroState createState() => new PomodoroState();
}

class PomodoroState extends State<Pomodoro> with TickerProviderStateMixin {
  AnimationController _controller;
  int workingTime = 28;
  int shortBreakTime = 2;
  int longBreakTime = 4;
  bool start = true;
  bool workingNow = true;
  bool breakNow = false;
  int numberOfBreaks = 0;
  String workingTask = 'Working Time';
  String shortBreakTask = 'Walk Outside';
  String longBreakTask = 'Meditate';

  void startTime() {
    _controller = new AnimationController(
      vsync: this,
      duration: Duration(
          minutes: workingNow
              ? workingTime
              : numberOfBreaks < 4 ? shortBreakTime : longBreakTime),
    )..forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        workingNow = !workingNow;
        if (workingNow == false) {
          numberOfBreaks += 1;
        }
        setState(() {});
        startTime();
        final Iterable<Duration> pauses = [
          const Duration(milliseconds: 100),
          const Duration(milliseconds: 100),
          const Duration(milliseconds: 100),
        ];
        Vibrate.vibrateWithPauses(pauses);
        if (numberOfBreaks == 4) {
          numberOfBreaks = 0;
        }
      }
    });
  }

  @override
  void initState() {
    Screen.keepOn(true);
    _controller = new AnimationController(
      vsync: this,
      duration: Duration(minutes: workingNow ? workingTime : shortBreakTime),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Do something
        workingNow = !workingNow;
        if (workingNow == false) {
          numberOfBreaks += 1;
        }
        setState(() {});
        startTime();
        final Iterable<Duration> pauses = [
          const Duration(milliseconds: 100),
          const Duration(milliseconds: 100),
          const Duration(milliseconds: 100),
        ];
        Vibrate.vibrateWithPauses(pauses);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.black,
        body: new Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Center(
              child: new PomodoroTimer(
                timeRemainingInSeconds: new IntTween(
                  begin: _controller.duration.inSeconds,
                  end: 0,
                ).animate(_controller),
                task: workingNow
                    ? workingTask
                    : numberOfBreaks < 4 ? shortBreakTask : longBreakTask,
              ),
            ),
            new Container(
              height: 80.0,
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        new Container(
                          height: 50.0,
                          child: new RaisedButton(
                            child: new Text(
                              start == true ? 'START' : 'PAUSE',
                              style: new TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                            ),
                            color: Colors.grey[600],
                            elevation: 0.0,
                            splashColor: Colors.blueGrey,
                            onPressed: () {
                              if (start == true) {
                                start = !start;
                                _controller.forward();
                                setState(() {});
                              } else {
                                start = !start;
                                _controller.stop();
                                setState(() {});
                              }
                            },
                          ),
                        ),
                        new Container(
                          height: 50.0,
                          child: new RaisedButton(
                            child: new Text(
                              'RESET',
                              style: new TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                            ),
                            color: Colors.grey[600],
                            elevation: 0.0,
                            splashColor: Colors.blueGrey,
                            onPressed: () {
                              _controller.reset();
                            },
                          ),
                        ),
                      ]),
                ],
              ),
            ),
          ],
        ));
  }
}

class PomodoroTimer extends AnimatedWidget {
  Animation<int> timeRemainingInSeconds;
  final String task;

  PomodoroTimer({this.timeRemainingInSeconds, this.task})
      : super(listenable: timeRemainingInSeconds);

  Widget build(BuildContext context) {
    String minutes = '${(timeRemainingInSeconds.value / 60).floor()}';
    String seconds = '${(timeRemainingInSeconds.value % 60)}'.padLeft(2, '0');
    return new Column(children: [
      new Text(
        task,
        style: new TextStyle(fontSize: 16.0, color: Colors.white),
      ),
      new Text(
        '$minutes:$seconds',
        style: new TextStyle(fontSize: 40.0, color: Colors.white),
      )
    ]);
  }
}
