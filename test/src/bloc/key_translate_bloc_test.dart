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

  void verify(MeterEvent expectedCallEvent) {
    expect(values.first.runtimeType, expectedCallEvent.runtimeType);
  }
}

@GenerateMocks([KeyDownEvent])
void main() {
// Create a mock instance
  late MockMeterMainBloc meterBloc;

  late MockKeyDownEvent mockI;

  setUp(() {
    mockI = MockKeyDownEvent();
    meterBloc = MockMeterMainBloc();
    when(mockI.logicalKey).thenReturn(LogicalKeyboardKey.keyI);
  });

  group('CounterBloc', () {
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
        meterBloc.verify(IgChangeEvent());
      },
    );
  });
}
