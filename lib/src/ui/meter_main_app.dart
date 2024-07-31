import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:meter/src/bloc/key_translate_bloc.dart';
import 'package:meter/src/bloc/meter_main_bloc.dart';
import 'package:meter/src/util/environment_util.dart';

import 'digital_speed_o_meter.dart';
import 'back_sheet.dart';

final _logger = Logger('MeterMainApp');

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
  final _focusNode = FocusNode();

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

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MeterMainBloc()),
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
                onKeyEvent: (key) {
                  _logger.info('detect keyEvent. key=$key');
                  return BlocProvider.of<KeyTranslateBloc>(context)
                      .add(HardwareKeyBoardEvent(key));
                },
                child: Stack(
                  children: [
                    const BackSheet(),

                    // メーター 100の桁
                    Positioned(
                        left: meterRightBaseLine,
                        top: kMeterTopBaseLine,
                        child: DigitalSpeedOMeter(
                          width: meterBaseWidth,
                          height: meterBaseHeight,
                          color: Colors.green,
                          offset: const Offset(0, 6),
                        )),

                    // メーター 10の桁
                    Positioned(
                        left: meterRightBaseLine + meterSize,
                        top: kMeterTopBaseLine,
                        child: DigitalSpeedOMeter(
                          width: meterBaseWidth,
                          height: meterBaseHeight,
                          color: Colors.green,
                          offset: const Offset(7, 13),
                        )),

                    // メーター 1の桁
                    Positioned(
                        left: meterRightBaseLine + (meterSize * 2),
                        top: kMeterTopBaseLine,
                        child: DigitalSpeedOMeter(
                          width: meterBaseWidth,
                          height: meterBaseHeight,
                          color: Colors.green,
                          offset: const Offset(14, 20),
                        )),

                    // メーター　小数点のドット
                    Positioned(
                        left: meterRightBaseLine +
                            (meterSize * 3) +
                            (kMeterInnerPadding / 2),
                        top: kMeterTopBaseLine +
                            meterBaseHeight -
                            kMeterInnerPadding * 2,
                        child: const DigitalSpeedOMeterDot(
                          color: Colors.green,
                          index: 21,
                        )),

                    // メーター　小数点1桁目
                    Positioned(
                        left: meterRightBaseLine +
                            (meterSize * 3) +
                            kMeterInnerPadding * 4,
                        top: kMeterTopBaseLine,
                        child: DigitalSpeedOMeter(
                          width: meterBaseWidth,
                          height: meterBaseHeight,
                          color: Colors.green,
                          offset: const Offset(22, 29),
                        )),

                    // IG-ON / off label
                    Positioned(
                      left: screenSize.width - (isUnitTestMode() ? 100 : 60),
                      top: screenSize.height - (isUnitTestMode() ? 70 : 35),
                      child: BlocBuilder<MeterMainBloc, MeterMainState>(
                        buildWhen: (before, current) =>
                            before.igON != current.igON,
                        builder: (context2, state) {
                          return GestureDetector(
                            key: const ValueKey('ig_on_off_label'),
                            onTap: () {
                              _logger.info('tap ig_on_off_label');
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
    );
  }
}
