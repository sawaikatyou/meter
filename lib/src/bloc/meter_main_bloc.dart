import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';

abstract class MeterEvent {}

class _InitEvent extends MeterEvent {}

class IgChangeEvent extends MeterEvent {}

class WinkerRightEvent extends MeterEvent {}

class WinkerLeftEvent extends MeterEvent {}

class _InnerSpeedUpdated extends MeterEvent {
  _InnerSpeedUpdated(this.nextState);

  MeterMainState nextState;
}

class MeterMainState {
  const MeterMainState(
    this.speedKmh,
    this.igON,
    this.winkerLeftOn,
    this.winkerRightOn,
  );

  final double speedKmh;
  final bool igON;
  final bool winkerLeftOn;
  final bool winkerRightOn;

  MeterMainState copyWith(
      {double? speedKmh, bool? igOn, bool? winkerLeftOn, bool? winkerRightOn}) {
    return MeterMainState(
      speedKmh ?? this.speedKmh,
      igOn ?? this.igON,
      winkerLeftOn ?? this.winkerLeftOn,
      winkerRightOn ?? this.winkerRightOn,
    );
  }
}

class MeterMainBloc extends Bloc<MeterEvent, MeterMainState> {
  final Location location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  MeterMainBloc() : super(const MeterMainState(0.0, false, false, false)) {
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
      emit(state.copyWith(igOn: !state.igON));
    });

    add(_InitEvent());
  }
}
