import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:speedometer/speedometer.dart';
import 'package:rxdart/rxdart.dart';

class MeterMainApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MeterMainScreen(title: 'SpeedOMeter Example'),
    );
  }
}

@immutable
class MeterMainScreen extends StatefulWidget {

  const MeterMainScreen({super.key, required this.title});

  final String title;

  @override
  State createState() => MeterMainScreenState();
}

class MeterMainScreenState extends State<MeterMainScreen> {
  int start = 0;
  int end = 60;

  int counter = 0;

  double _lowerValue = 20.0;
  double _upperValue = 40.0;

  Duration _animationDuration = Duration(milliseconds: 100);

  PublishSubject<double> eventObservable = PublishSubject();

  @override
  void initState() {
    super.initState();
    const click = const Duration(milliseconds: 5000);
    var rng = Random();
    Timer.periodic(click,
        (Timer t) => eventObservable.add(rng.nextInt(59) + rng.nextDouble()));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    ThemeData somTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        primary: Colors.blue,
        secondary: Colors.black,
        background: Colors.grey,
      ),
    );
    var speedOMeter = SpeedOMeter(
      start: start,
      end: end,
      highlightStart: (_lowerValue / end),
      highlightEnd: (_upperValue / end),
      themeData: somTheme,
      eventObservable: this.eventObservable,
      animationDuration: _animationDuration,
    );
    return Scaffold(
        appBar: AppBar(
          title: Text("SpeedOMeter"),
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(40.0),
              child: speedOMeter,
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _animationDuration += Duration(milliseconds: 100);
                });
              },
              child: Text('Slower...'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _animationDuration -= Duration(milliseconds: 100);
                });
              },
              child: Text('Faster!'),
            ),
          ],
        ));
  }
}
