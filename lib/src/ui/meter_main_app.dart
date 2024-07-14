import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int end = 30;

  int counter = 0;

  static const double _lowerValue = 20.0;
  static const double _upperValue = 30.0;

  static const Duration _animationDuration = Duration(milliseconds: 500);

  final FocusNode _focusNode = FocusNode();

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
  Widget build(BuildContext ctxOrigin) {
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
        highlightStart: _lowerValue / end,
        highlightEnd: _upperValue / end,
        themeData: somTheme,
        eventObservable: eventObservable,
        animationDuration: _animationDuration);

    return Scaffold(
      appBar: AppBar(title: const Text('SpeedOMeter')),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => MeterBloc()),
        ],
        child: BlocListener<MeterBloc, MeterState>(
          listenWhen: (before, current) {
            if (before.speed != current.speed) {
              return true;
            }
            return false;
          },
          listener: (context, state) {
            eventObservable.add(state.speedKmh);
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: speedOMeter,
              ),
              const Divider(),
              BlocBuilder<MeterBloc, MeterState>(
                buildWhen: (before, current) => before.igON != current.igON,
                builder: (context2, state) {
                  return KeyboardListener(
                      focusNode: _focusNode,
                      onKeyEvent: (key) {
                        print('key=$key');
                        if (key is KeyDownEvent) {
                          switch (key.logicalKey.keyLabel) {
                            case 'P':
                            case 'p':
                              print('power off');
                              BlocProvider.of<MeterBloc>(context2)
                                  .add(IgChangeEvent());
                              break;
                            default:
                              break;
                          }
                        }
                      },
                      child: Text('IG ${state.igON ? 'on' : 'off'}'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
