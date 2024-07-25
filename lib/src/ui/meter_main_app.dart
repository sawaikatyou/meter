import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter/src/bloc/key_translate_bloc.dart';
import 'package:meter/src/bloc/meter_main_bloc.dart';

import 'digital_speed_o_meter.dart';
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
  static const kWinkerSize = 48.0;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // TODO: 心拍数対応
    // Health().requestAuthorization([HealthDataType.HEART_RATE]).then(
    //     (bool result) async {
    //   if (!result) {
    //     return;
    //   }
    //   var types = [HealthDataType.HEART_RATE];
    //   var now = DateTime.now();
    //   final yesterday = now.subtract(Duration(hours: 24));
    //
    //   // request permissions to write steps and blood glucose
    //   types = [HealthDataType.STEPS, HealthDataType.BLOOD_GLUCOSE];
    //   var permissions = [
    //     HealthDataAccess.READ_WRITE,
    //     HealthDataAccess.READ_WRITE
    //   ];
    //   final permissionResult =
    //       await Health().requestAuthorization(types, permissions: permissions);
    //   if (!permissionResult) {
    //     return;
    //   }
    //
    //   // try {
    //   // fetch health data
    //   List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
    //     types: types,
    //     startTime: yesterday,
    //     endTime: now,
    //   );
    //
    //   debugPrint('Total number of data points: ${healthData.length}. '
    //       '${healthData.length > 100 ? 'Only showing the first 100.' : ''}');
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // ウインカー用定義値
    final winkerPadding = screenSize.width / 100;
    final rightWinkerPosition =
        (screenSize.width - kWinkerSize - winkerPadding);
    final leftWinkerPosition = winkerPadding;
    const kWinkerTopBaseLine = 100.0;

    // メーター用描画定義
    const kMeterTopBaseLine = kWinkerTopBaseLine + kWinkerSize;
    final meterRightBaseLine = screenSize.width * 0.1;
    final meterBaseWidth = screenSize.width / 6;
    final meterBaseHeight = screenSize.height / 2;
    const kMeterInnerPadding = 10.0;
    final meterSize = meterBaseWidth + kMeterInnerPadding;

    print('size=${screenSize.width} / ${screenSize.height}');

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
              },
              listener: (context, state) {}),
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

                      // メーター 100の桁
                      Positioned(
                          left: meterRightBaseLine,
                          top: kMeterTopBaseLine,
                          child: DigitalSpeedOMeterPaint(
                            width: meterBaseWidth,
                            height: meterBaseHeight,
                            color: Colors.green,
                            index: 0,
                          )),

                      // メーター 10の桁
                      Positioned(
                          left: meterRightBaseLine + meterSize,
                          top: kMeterTopBaseLine,
                          child: DigitalSpeedOMeterPaint(
                            width: meterBaseWidth,
                            height: meterBaseHeight,
                            color: Colors.green,
                            index: 1,
                          )),

                      // メーター 1の桁
                      Positioned(
                          left: meterRightBaseLine + (meterSize * 2),
                          top: kMeterTopBaseLine,
                          child: DigitalSpeedOMeterPaint(
                            width: meterBaseWidth,
                            height: meterBaseHeight,
                            color: Colors.green,
                            index: 2,
                          )),

                      // メーター　小数点のドット
                      Positioned(
                          left: meterRightBaseLine +
                              (meterSize * 3) +
                              (kMeterInnerPadding / 2),
                          top: kMeterTopBaseLine +
                              meterBaseHeight -
                              kMeterInnerPadding * 2,
                          child: const DigitalSpeedOMeterDot()),

                      Positioned(
                          left: meterRightBaseLine +
                              (meterSize * 3) +
                              kMeterInnerPadding * 4,
                          top: kMeterTopBaseLine,
                          child: DigitalSpeedOMeterPaint(
                            width: meterBaseWidth,
                            height: meterBaseHeight,
                            color: Colors.green,
                            index: 3,
                          )),

                      // IG-ON / off label
                      Positioned(
                        left: screenSize.width - 60,
                        top: screenSize.height - 35,
                        child: BlocBuilder<MeterMainBloc, MeterMainState>(
                          buildWhen: (before, current) =>
                              before.igON != current.igON,
                          builder: (context2, state) {
                            return GestureDetector(
                              onTap: () {
                                BlocProvider.of<MeterMainBloc>(context)
                                    .add(IgChangeEvent());
                              },
                              child: Container(
                                color: Colors.white,
                                child: Text(
                                  'IG ${state.igON ? 'on' : 'off'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // 右側ウインカー
                      Positioned(
                        left: rightWinkerPosition,
                        top: kWinkerTopBaseLine,
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
                              size: kWinkerSize),
                        ),
                      ),

                      // 左側ウインカー
                      Positioned(
                        left: leftWinkerPosition,
                        top: kWinkerTopBaseLine,
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
                              size: kWinkerSize),
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
