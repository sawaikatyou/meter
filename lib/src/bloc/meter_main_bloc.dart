import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:logging/logging.dart';
import 'package:meter/src/util/calc_util.dart';

import '../util/environment_util.dart';

final _logger = Logger('MeterMainBloc');

@immutable
class MeterEvent {}

class _InitEvent extends MeterEvent {}

class IgChangeEvent extends MeterEvent {}

class WinkerRightEvent extends MeterEvent {}

class WinkerLeftEvent extends MeterEvent {}

class SpeedUpdated extends MeterEvent {
  SpeedUpdated(this.speed);

  final double speed;
}

class _IlluminationUpdateEvent extends MeterEvent {}

class MeterMainState extends Equatable {
  const MeterMainState(
    this.speedKmh,
    this.igON,
    this.winkerLeftOn,
    this.winkerRightOn,
    this.digitalMeterInformation,
  );

  final double speedKmh;
  final bool igON;
  final bool winkerLeftOn;
  final bool winkerRightOn;
  final List<bool> digitalMeterInformation;

  MeterMainState copyWith({
    double? speedKmh,
    bool? igON,
    bool? winkerLeftOn,
    bool? winkerRightOn,
    List<bool>? digitalMeterInformation,
  }) =>
      MeterMainState(
        speedKmh ?? this.speedKmh,
        igON ?? this.igON,
        winkerLeftOn ?? this.winkerLeftOn,
        winkerRightOn ?? this.winkerRightOn,
        digitalMeterInformation ?? this.digitalMeterInformation,
      );

  @override
  List<Object?> get props => [
        speedKmh,
        igON,
        winkerLeftOn,
        winkerRightOn,
        digitalMeterInformation,
      ];

  @override
  bool? get stringify => false;
}

class MeterMainBloc extends Bloc<MeterEvent, MeterMainState> {
  final location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  /// デバッグモード 順番点灯モード
  static const kDebugIlluminationMode = false;

  /// デジタルパネル部の最大長
  static const kDigitalInformationMax = (4 * 7) + 1;

  /// 全消灯パターン
  static const kPatternOff = [false, false, false, false, false, false, false];

  static const Map<int, List<bool>> kNumberPatternMap = {
    0: [true, true, true, false, true, true, true],
    1: [false, false, true, false, false, true, false],
    2: [true, false, true, true, true, false, true],
    3: [true, false, true, true, false, true, true],
    4: [false, true, true, true, false, true, false],
    5: [true, true, false, true, false, true, true],
    6: [true, true, false, true, true, true, true],
    7: [true, true, true, false, false, true, false],
    8: [true, true, true, true, true, true, true],
    9: [true, true, true, true, false, true, true],
  };

  /// オブジェクト初期値
  static const kStateInit = MeterMainState(0.0, false, false, false, [
    ...kPatternOff, // 100の桁
    ...kPatternOff, // 10の桁
    ...kPatternOff, // 1の桁
    false, // ドット
    ...kPatternOff // 小数点1桁
  ]);

  List<bool> makeInformation({double input = 0.0}) {
    final result = <bool>[];
    result.addAll(kNumberPatternMap[fetch100(input)] ?? kPatternOff);
    result.addAll(kNumberPatternMap[fetch010(input)] ?? kPatternOff);
    result.addAll(kNumberPatternMap[fetch001(input)] ?? kPatternOff);
    result.add(true);
    result.addAll(kNumberPatternMap[fetchMinor(input)] ?? kPatternOff);

    return result;
  }

  /// 全パネル点灯／消灯
  List<bool> fillInformation({required bool input}) {
    List<bool> result = [];

    for (int i = 0; i < kDigitalInformationMax; i++) {
      result.add(input);
    }

    return result;
  }

  MeterMainBloc({MeterMainState? init}) : super(init ?? kStateInit) {
    on<_InitEvent>((event, emit) {
      // speed 監視
      _locationSubscription =
          location.onLocationChanged.handleError((dynamic err) {
        _locationSubscription?.cancel();
      }).listen((currentLocation) {
        final speedMps = currentLocation.speed;
        if (speedMps != null) {
          final speedKmh = (speedMps * 3600) / 1000;
          _logger.info('fetch speed. speedKmh=$speedKmh');
          add(SpeedUpdated(speedKmh));
        }
      });
      _logger.info('init completed.');
    });

    on<SpeedUpdated>((event, emit) {
      if (state.igON && !kDebugIlluminationMode) {
        final nextSpeed = event.speed;
        final info = makeInformation(input: nextSpeed);

        emit(
          state.copyWith(
            speedKmh: nextSpeed,
            digitalMeterInformation: info,
          ),
        );
      }
    });

    on<WinkerLeftEvent>((event, emit) =>
        emit(state.copyWith(winkerLeftOn: !state.winkerLeftOn)));

    on<WinkerRightEvent>((event, emit) =>
        emit(state.copyWith(winkerRightOn: !state.winkerRightOn)));

    on<IgChangeEvent>((event, emit) {
      final igonNewStatus = !state.igON;
      emit(state.copyWith(
        igON: igonNewStatus,
        digitalMeterInformation: fillInformation(input: false),
      ));

      // coverage:ignore-start
      // この処理は正規の作り込みでないので、テストは不要
      // IGON中はデジタルメーターの各パネルを点灯させる
      if (!isUnitTestMode() && kDebugIlluminationMode) {
        if (igonNewStatus) {
          timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
            add(_IlluminationUpdateEvent());
          });
        } else {
          timer?.cancel();
          count = 0;
        }
      }
      // coverage:ignore-end
    });

// coverage:ignore-start
// デバッグ点灯モードの処理は正規の作り込みでないので、テストは不要
    on<_IlluminationUpdateEvent>((event, emit) {
      List<bool> newInfo = <bool>[...state.digitalMeterInformation];

      if (count > kDigitalInformationMax - 1) {
        count = 0;
        newInfo = fillInformation(input: false);
      }
      newInfo[count] = true;
      if (count > 0) {
        newInfo[count - 1] = false;
      }
      count++;

      emit(state.copyWith(
        digitalMeterInformation: newInfo,
      ));
      // _logger.info('_InnerTestCounted newInfo=${_logger.dump(newInfo)}');
    });
// coverage:ignore-end

    add(_InitEvent());
  }

// coverage:ignore-start
  Timer? timer;
  int count = 0;
// coverage:ignore-end
}
