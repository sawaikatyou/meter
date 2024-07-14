import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'meter_state.dart';

/// Event being processed by [CounterBloc].
abstract class MeterEvent {}

class _InitEvent extends MeterEvent {}

class _InnerSpeedUpdated extends MeterEvent {
  _InnerSpeedUpdated(this.nextState);

  MeterState nextState;
}

class MeterBloc extends Bloc<MeterEvent, MeterState> {
  Timer? timer;

  MeterBloc() : super(const MeterState(0, 0.0)) {
    on<_InitEvent>((event, emit) {
      print('[sasaki]InitEvent call');
      var rng = Random();
      timer = Timer.periodic(const Duration(milliseconds: 1000), (Timer t) {
        print('[sasaki]periodic call');
        add(_InnerSpeedUpdated(state.copyWith(speed: rng.nextInt(60))));
      });
    });

    on<_InnerSpeedUpdated>((event, emit) {
      print('[sasaki]_InnerSpeedUpdated call');

      emit(
        state.copyWith(
          speed: event.nextState.speed,
          speedAccuracy: event.nextState.speedAccuracy,
        ),
      );
    });

    add(_InitEvent());
  }
}
