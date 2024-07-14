import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter/src/bloc/meter_bloc.dart';
import 'package:speedometer/speedometer.dart';
import 'package:rxdart/rxdart.dart' as RxDart;

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

  static const double _lowerValue = 40.0;
  static const double _upperValue = 60.0;

  static const Duration _animationDuration = Duration(milliseconds: 100);

  RxDart.PublishSubject<double> eventObservable = RxDart.PublishSubject();

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
    final themeBase = ThemeData();
    ThemeData somTheme = themeBase.copyWith(
        colorScheme: themeBase.colorScheme.copyWith(
      primary: Colors.red,
      secondary: Colors.black,
      background: Colors.grey,
    ));

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
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: speedOMeter,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
