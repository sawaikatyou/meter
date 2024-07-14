import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter/src/bloc/meter_bloc.dart';
import 'package:meter/src/bloc/meter_state.dart';
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
  }

  @override
  void dispose() {
    super.dispose();
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
        eventObservable: eventObservable,
        animationDuration: _animationDuration);
    return Scaffold(
      appBar: AppBar(title: const Text("SpeedOMeter")),
      body: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => MeterBloc()),
          ],
          child: BlocListener<MeterBloc, MeterState>(
            listener: (context, state) {
              eventObservable.add(state.speed.toDouble());
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: speedOMeter,
                ),
              ],
            ),
          )),
    );
  }
}
