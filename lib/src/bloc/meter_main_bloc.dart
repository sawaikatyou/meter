import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';

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
          add(_InnerSpeedUpdated(state.copyWith(speedKmh: speedKmh)));
        }
      });
    });

    // TODO: ここにしかるべき処理を作る
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
        digitalMeterInformation: fillInformation(newValue: false),
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
