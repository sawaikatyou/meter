import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meter/src/bloc/key_translate_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:meter/src/bloc/meter_main_bloc.dart';

import 'key_translate_bloc_test.mocks.dart';

class MockMeterMainBloc extends MockBloc<MeterEvent, MeterMainState>
    implements MeterMainBloc {
  final List<MeterEvent> values = [];

  @override
  void add(MeterEvent e) {
    values.add(e);
  }

  void verifyRuntimeType(MeterEvent expectedCallEvent) {
    expect(values.first.runtimeType, expectedCallEvent.runtimeType);
  }
}

@GenerateMocks([KeyDownEvent])
void main() {
// Create a mock instance
  late MockMeterMainBloc meterBloc;

  late MockKeyDownEvent mockI, mockRight, mockLeft;

  setUp(() {
    meterBloc = MockMeterMainBloc();

    mockI = MockKeyDownEvent();
    when(mockI.logicalKey).thenReturn(LogicalKeyboardKey.keyI);

    mockRight = MockKeyDownEvent();
    when(mockRight.logicalKey).thenReturn(LogicalKeyboardKey.arrowRight);

    mockLeft = MockKeyDownEvent();
    when(mockLeft.logicalKey).thenReturn(LogicalKeyboardKey.arrowLeft);
  });

  group('KeyTranslateBloc', () {
    blocTest(
      'emits [] when nothing is added',
      build: () => KeyTranslateBloc(meterBloc),
      expect: () => [],
    );

    blocTest(
      'key I',
      build: () => KeyTranslateBloc(meterBloc),
      act: (bloc) => bloc.add(HardwareKeyBoardEvent(mockI)),
      verify: (bloc) {
        meterBloc.verifyRuntimeType(IgChangeEvent());
      },
    );

    blocTest(
      'key ARROW_LEFT',
      build: () => KeyTranslateBloc(meterBloc),
      act: (bloc) => bloc.add(HardwareKeyBoardEvent(mockLeft)),
      verify: (bloc) {
        meterBloc.verifyRuntimeType(WinkerLeftEvent());
      },
    );

    blocTest(
      'key ARROW_RIGHT',
      build: () => KeyTranslateBloc(meterBloc),
      act: (bloc) => bloc.add(HardwareKeyBoardEvent(mockRight)),
      verify: (bloc) {
        meterBloc.verifyRuntimeType(WinkerRightEvent());
      },
    );
  });
}
