import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:logging/logging.dart';

final _logger = Logger('MeterMainBloc');

class MeterEvent implements Equatable {
  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [];
}

class _InitEvent extends MeterEvent {}

class IgChangeEvent extends MeterEvent {}

class WinkerRightEvent extends MeterEvent {}

class WinkerLeftEvent extends MeterEvent {}

class _InnerSpeedUpdated extends MeterEvent {
  _InnerSpeedUpdated(this.nextState);

  MeterMainState nextState;

  @override
  List<Object?> get props => [super.props, nextState];
}

class _InnerTestCounted extends MeterEvent {
  @override
  List<Object?> get props => ['_InnerTestCounted'];
}

class MeterMainState implements Equatable {
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
    bool? igOn,
    bool? winkerLeftOn,
    bool? winkerRightOn,
    List<bool>? digitalMeterInformation,
  }) {
    return MeterMainState(
      speedKmh ?? this.speedKmh,
      igOn ?? this.igON,
      winkerLeftOn ?? this.winkerLeftOn,
      winkerRightOn ?? this.winkerRightOn,
      digitalMeterInformation ?? this.digitalMeterInformation,
    );
  }

  @override
  List<Object?> get props => [
        speedKmh,
        igON,
        winkerLeftOn,
        winkerRightOn,
        digitalMeterInformation,
      ];

  @override
  bool? get stringify => true;
}

class MeterMainBloc extends Bloc<MeterEvent, MeterMainState> {
  final Location location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  static const kDigitsCount = 4;
  static const kOneDigitValues = 7;
  static const kDecimalPoint = 1;

  static const kDigitalInformationMax =
      (kDigitsCount * kOneDigitValues) + kDecimalPoint;

  static const kPatternOff = [false, false, false, false, false, false, false];
  static const kPattern0 = [true, true, true, false, true, true, true];
  static const kPattern1 = [false, false, true, false, false, true, false];
  static const kPattern2 = [true, false, true, true, true, false, true];
  static const kPattern3 = [true, false, true, true, false, true, true];
  static const kPattern4 = [false, true, true, true, false, true, false];
  static const kPattern5 = [true, true, false, true, false, true, true];
  static const kPattern6 = [true, true, false, true, true, true, true];
  static const kPattern7 = [true, true, true, false, false, true, false];
  static const kPattern8 = [true, true, true, true, true, true, true];
  static const kPattern9 = [true, true, true, true, false, true, true];

  // 100の桁を取得
  int fetchOne(double speedKmh) {
    var temp = speedKmh;
    if (speedKmh < 100) {
      return -1;
    }
    if (speedKmh > 1000) {
      temp = speedKmh % 1000;
    }
    return (temp / 100).toInt();
  }

  // 10の桁を取得
  int fetchTwo(double speedKmh) {
    var temp = speedKmh;
    if (speedKmh < 10) {
      return -1;
    }
    if (speedKmh > 100) {
      temp = speedKmh % 100;
    }
    return (temp / 10).toInt();
  }

  // 1の桁を取得
  int fetchThree(double speedKmh) {
    var temp = speedKmh;
    if (speedKmh > 10) {
      temp = speedKmh % 10;
    }
    return temp.toInt();
  }

  // 小数点の1桁目を取得
  int fetchMinor(double speedKmh) {
    var temp = speedKmh;
    if (speedKmh > 1) {
      temp = speedKmh % 1;
    }
    temp = (temp * 10.0);
    return temp.ceil().toInt();
  }

  List<bool> makeInformation({double input = 0.0}) {
    final result = <bool>[];
    final value100 = fetchOne(input);
    final value010 = fetchTwo(input);
    final value001 = fetchThree(input);
    final valueDot = fetchMinor(input);
    final Map<int, List<bool>> parameters = {
      0: kPattern0,
      1: kPattern1,
      2: kPattern2,
      3: kPattern3,
      4: kPattern4,
      5: kPattern5,
      6: kPattern6,
      7: kPattern7,
      8: kPattern8,
      9: kPattern9,
    };

    result.addAll(parameters[value100] ?? kPatternOff);
    result.addAll(parameters[value010] ?? kPatternOff);
    result.addAll(parameters[value001] ?? kPatternOff);
    result.add(true);
    result.addAll(parameters[valueDot] ?? kPatternOff);

    return result;
  }

  MeterMainBloc() : super(const MeterMainState(0.0, false, false, false, [])) {
    on<_InitEvent>((event, emit) {
      // speed 監視
      _locationSubscription =
          location.onLocationChanged.handleError((dynamic err) {
        _locationSubscription?.cancel();
      }).listen((currentLocation) {
        final speedMps = currentLocation.speed;
        if (speedMps != null) {
          final speedKmh = (speedMps * 3600) / 1000;
          final info = makeInformation(input: speedKmh);

          _logger.info('speedKmh=$speedKmh');

          add(_InnerSpeedUpdated(state.copyWith(
            speedKmh: speedKmh,
            digitalMeterInformation: info,
          )));
        }
      });
    });

    // TODO: 現状は単に ig on / off で全部つけてるだけ
    List<bool> fillInformation({bool? newValue}) {
      bool value = newValue ?? state.igON;
      List<bool> result = [];

      for (int i = 0; i < kDigitalInformationMax; i++) {
        result.add(value);
      }

      return result;
    }

    on<_InnerSpeedUpdated>((event, emit) {
      emit(
        state.copyWith(
          speedKmh: event.nextState.speedKmh,
          digitalMeterInformation: event.nextState.digitalMeterInformation,
        ),
      );
    });

    on<WinkerLeftEvent>((event, emit) {
      emit(
        state.copyWith(
          winkerLeftOn: !state.winkerLeftOn,
        ),
      );
    });

    on<WinkerRightEvent>((event, emit) {
      emit(
        state.copyWith(
          winkerRightOn: !state.winkerRightOn,
        ),
      );
    });

    on<IgChangeEvent>((event, emit) {
      final igonNewStatus = !state.igON;
      emit(state.copyWith(
        igOn: igonNewStatus,
        digitalMeterInformation: fillInformation(newValue: igonNewStatus),
      ));

      if (igonNewStatus) {
        timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
          add(_InnerTestCounted());
        });
      } else {
        timer?.cancel();
        count = 0;
      }
    });

    on<_InnerTestCounted>((event, emit) {
      var newInfo = state.digitalMeterInformation;

      if (count > kDigitalInformationMax - 1) {
        count = 0;
        newInfo = fillInformation(newValue: false);
      }
      newInfo[count] = true;
      if (count > 0) {
        newInfo[count - 1] = false;
      }
      count++;

      emit(state.copyWith(
        digitalMeterInformation: newInfo,
      ));
    });

    add(_InitEvent());
  }

  Timer? timer;
  int count = 0;
}
