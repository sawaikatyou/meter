import 'package:flutter/cupertino.dart';

@immutable
class MeterState {
  const MeterState(this.speed, this.speedAccuracy);

  final int speed;
  final double speedAccuracy;

  MeterState copyWith({
    int? speed,
    double? speedAccuracy,
  }) {
    return MeterState(
      speed ?? this.speed,
      speedAccuracy ?? this.speedAccuracy,
    );
  }
}
