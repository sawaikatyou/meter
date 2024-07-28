import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meter/src/bloc/key_translate_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:bloc_test/bloc_test.dart';
import 'package:meter/src/bloc/meter_main_bloc.dart';

import 'key_translate_bloc_test.mocks.dart';

@GenerateMocks([KeyDownEvent])
void main() {
  setUp(() {});

  group('MeterMainBloc', () {
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

    int fetchThree(double speedKmh) {
      var temp = speedKmh;
      if (speedKmh > 10) {
        temp = speedKmh % 10;
      }
      return temp.toInt();
    }

    int fetchMinor(double speedKmh) {
      var temp = speedKmh;
      if (speedKmh > 1) {
        temp = speedKmh % 1;
      }
      temp = (temp * 10.0);
      return temp.ceil().toInt();
    }

    test('test', () {
      // final speedSample = 2123.45678;
      final speedSample = 456.7;

      final one = fetchOne(speedSample);
      expect(one, 4);
      final two = fetchTwo(speedSample);
      expect(two, 5);
      final three = fetchThree(speedSample);
      expect(three, 6);
      final minor = fetchMinor(speedSample);
      expect(minor, 7);
    });
  });
}
