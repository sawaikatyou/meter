import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';

import 'meter_main_bloc.dart';

abstract class MeterEvent {}

class _InitEvent extends MeterEvent {}

class HardwareKeyBoardEvent extends MeterEvent {
  HardwareKeyBoardEvent(this.keyEvent);

  KeyEvent keyEvent;
}

class TranslateState {
  const TranslateState();
}

class KeyTranslateBloc extends Bloc<MeterEvent, TranslateState> {
  final MeterMainBloc meterbloc;

  KeyTranslateBloc(this.meterbloc) : super(const TranslateState()) {
    on<_InitEvent>((event, emit) {});

    on<HardwareKeyBoardEvent>((event, emit) {
      final key = event.keyEvent;
      print('key=$key');
      if (key is KeyDownEvent) {
        final keyLabel = key.logicalKey.keyLabel.toUpperCase();

        switch (keyLabel) {
          case 'I':
            meterbloc.add(IgChangeEvent());
            break;
          case 'ARROW RIGHT':
            meterbloc.add(WinkerRightEvent());
            break;
          case 'ARROW LEFT':
            meterbloc.add(WinkerLeftEvent());
            break;
          default:
            break;
        }
      }
    });

    add(_InitEvent());
  }
}
