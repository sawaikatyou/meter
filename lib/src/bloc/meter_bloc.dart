import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';

abstract class MeterEvent {}

class _InitEvent extends MeterEvent {}

class _InnerSpeedUpdated extends MeterEvent {
  _InnerSpeedUpdated(this.nextState);

  MeterState nextState;
}

class MeterState {
  const MeterState(this.speed, this.speedAccuracy, this.speedKmh);

  final double speedKmh;
  final double speed;
  final double speedAccuracy;

  MeterState copyWith({
    double? speed,
    double? speedAccuracy,
    double? speedKmh,
  }) {
    return MeterState(
      speed ?? this.speed,
      speedAccuracy ?? this.speedAccuracy,
      speedKmh ?? this.speedKmh,
    );
  }
}

class MeterBloc extends Bloc<MeterEvent, MeterState> {
  final Location location = Location();
  StreamSubscription<LocationData>? _locationSubscription;

  MeterBloc() : super(const MeterState(0.0, 0.0, 0.0)) {
    on<_InitEvent>((event, emit) {
      _locationSubscription =
          location.onLocationChanged.handleError((dynamic err) {
        _locationSubscription?.cancel();
      }).listen((currentLocation) {
        final speedMps = currentLocation.speed;
        if (speedMps != null) {
          final speedKmh = (speedMps * 3600) / 1000;
          add(_InnerSpeedUpdated(state.copyWith(
            speedKmh: speedKmh,
            speed: currentLocation.speed,
            speedAccuracy: currentLocation.speedAccuracy,
          )));
        }
      });
    });

    on<_InnerSpeedUpdated>((event, emit) {
      emit(
        state.copyWith(
          speedKmh: event.nextState.speedKmh,
          speed: event.nextState.speed,
          speedAccuracy: event.nextState.speedAccuracy,
        ),
      );
    });

    add(_InitEvent());
  }
}
