import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:logging/logging.dart';

import 'meter_main_bloc.dart';

final _logger = Logger('KeyTranslateBloc');

abstract class KeyTranslateEvent {}

class _InitEvent extends KeyTranslateEvent {}

class HardwareKeyBoardEvent extends KeyTranslateEvent {
  HardwareKeyBoardEvent(this.keyEvent);

  KeyEvent keyEvent;
}

class TranslateState {
  const TranslateState();
}

class KeyTranslateBloc extends Bloc<KeyTranslateEvent, TranslateState> {
  final MeterMainBloc meterBloc;

  KeyTranslateBloc(this.meterBloc) : super(const TranslateState()) {
    on<_InitEvent>((event, emit) {});

    on<HardwareKeyBoardEvent>((event, emit) {
      final key = event.keyEvent;
      _logger.info('key=$key');
      if (key is KeyDownEvent) {
        final keyLabel = key.logicalKey.keyLabel.toUpperCase();

        switch (keyLabel) {
          case 'I':
            meterBloc.add(IgChangeEvent());
            break;
          case 'ARROW RIGHT':
            meterBloc.add(WinkerRightEvent());
            break;
          case 'ARROW LEFT':
            meterBloc.add(WinkerLeftEvent());
            break;
          default:
            break;
        }
      }
    });

    add(_InitEvent());
  }
}
