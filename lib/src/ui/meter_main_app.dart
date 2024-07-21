import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:health/health.dart';
import 'package:meter/src/bloc/key_translate_bloc.dart';
import 'package:meter/src/bloc/meter_main_bloc.dart';
import 'package:speedometer/speedometer.dart';
import 'package:rxdart/rxdart.dart' as RxDart;

import 'half_round_back_sheet.dart';

class MeterMainApp extends StatelessWidget {
  const MeterMainApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'SpeedOMeter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MeterMainScreen(title: 'SpeedOMeter Example'));
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

  RxDart.PublishSubject<double> SpeedEventObservable = RxDart.PublishSubject();
  RxDart.PublishSubject<double> TacoEventObservable = RxDart.PublishSubject();

  @override
  void initState() {
    super.initState();
    //

    // define the types to get

    Health().requestAuthorization([HealthDataType.HEART_RATE]).then(
        (bool result) async {
      if (!result) {
        return;
      }
      var types = [HealthDataType.HEART_RATE];
      var now = DateTime.now();
      final yesterday = now.subtract(Duration(hours: 24));

      // request permissions to write steps and blood glucose
      types = [HealthDataType.STEPS, HealthDataType.BLOOD_GLUCOSE];
      var permissions = [
        HealthDataAccess.READ_WRITE,
        HealthDataAccess.READ_WRITE
      ];
      final permissionResult =
          await Health().requestAuthorization(types, permissions: permissions);
      if (!permissionResult) {
        return;
      }

      // try {
      // fetch health data
      List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
        types: types,
        startTime: yesterday,
        endTime: now,
      );

      debugPrint('Total number of data points: ${healthData.length}. '
          '${healthData.length > 100 ? 'Only showing the first 100.' : ''}');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const padding = 10.0;
    final halfWidth = screenSize.width * 0.3;
    final halfHeight = screenSize.height * 0.5;
    final meterScale = halfWidth - padding * 2;
    final centerPoint = halfHeight - (screenSize.height / 6) + padding;
    final winkerPoint = centerPoint - (screenSize.height / 4);
    final leftPoint1 = (screenSize.width * 0.1) + padding;
    final leftPoint2 = (screenSize.width * 0.6) + padding;

    print('size=${screenSize.width} / ${screenSize.height}');

    final themeBase = ThemeData();
    ThemeData speedTheme = themeBase.copyWith(
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
        themeData: speedTheme,
        eventObservable: SpeedEventObservable,
        animationDuration: _animationDuration);

    ThemeData tacoTheme = themeBase.copyWith(
        colorScheme: themeBase.colorScheme.copyWith(
      primary: Colors.red,
      secondary: Colors.black,
      background: Colors.grey,
    ));

    var tacoMeter = SpeedOMeter(
        start: start,
        end: end,
        highlightStart: _lowerValue / end,
        highlightEnd: _upperValue / end,
        themeData: tacoTheme,
        eventObservable: TacoEventObservable,
        animationDuration: _animationDuration);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MeterMainBloc()),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<MeterMainBloc, MeterMainState>(
              listenWhen: (before, current) {
            if (before.speedKmh != current.speedKmh) {
              return true;
            }
            return false;
          }, listener: (context, state) {
            SpeedEventObservable.add(state.speedKmh);
            TacoEventObservable.add(state.speedKmh);
          }),
        ],
        child: Scaffold(
          body: MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (ctx) =>
                      KeyTranslateBloc(BlocProvider.of<MeterMainBloc>(ctx))),
            ],
            child: BlocBuilder<MeterMainBloc, MeterMainState>(
              builder: (context, state) {
                return KeyboardListener(
                  focusNode: _focusNode,
                  onKeyEvent: (key) =>
                      BlocProvider.of<KeyTranslateBloc>(context)
                          .add(HardwareKeyBoardEvent(key)),
                  child: Stack(
                    children: [
                      const HalfRoundBackSheet(),
                      Positioned(
                          left: leftPoint1,
                          top: centerPoint,
                          width: meterScale,
                          height: meterScale,
                          child: speedOMeter),
                      Positioned(
                          left: leftPoint2,
                          top: centerPoint,
                          width: meterScale,
                          height: meterScale,
                          child: tacoMeter),
                      Positioned(
                        left: screenSize.width - 60,
                        top: screenSize.height - 35,
                        child: BlocBuilder<MeterMainBloc, MeterMainState>(
                          buildWhen: (before, current) =>
                              before.igON != current.igON,
                          builder: (context2, state) {
                            return Container(
                              color: Colors.white,
                              child: Text(
                                'IG ${state.igON ? 'on' : 'off'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // 右側ウインカー
                      Positioned(
                        left: leftPoint2 + (meterScale * 0.6),
                        top: winkerPoint,
                        child: Container(
                          decoration: BoxDecoration(
                            color: state.winkerRightOn
                                ? Colors.white
                                : Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_forward_outlined,
                              color: state.winkerRightOn
                                  ? Colors.green
                                  : Colors.black,
                              size: 48),
                        ),
                      ),
                      // 左側ウインカー
                      Positioned(
                        left: leftPoint1 + (meterScale * 0.1),
                        top: winkerPoint,
                        child: Container(
                          decoration: BoxDecoration(
                            color: state.winkerLeftOn
                                ? Colors.white
                                : Colors.black26,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.arrow_back_outlined,
                              color: state.winkerLeftOn
                                  ? Colors.green
                                  : Colors.black,
                              size: 48),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
