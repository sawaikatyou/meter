import 'dart:math' as math;

import 'package:flutter/material.dart';

enum Direction { left, top, right, bottom }

@immutable
class HalfRoundBackSheet extends StatelessWidget {
  const HalfRoundBackSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Container(
            width: screenSize.width,
            height: screenSize.height,
            color: Colors.grey),
        CustomPaint(
          painter: HalfCirclePainter(context, Direction.top),
          size: Size(screenSize.width, screenSize.height),
        ),
      ],
    );
  }
}

class HalfCirclePainter extends CustomPainter {
  HalfCirclePainter(
    this.context,
    this.direction,
  );

  BuildContext context;
  Direction direction;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.black87.withOpacity(0.5);

    final longSide = math.max(size.width, size.height);
    final circleTop = size.height * 0.1;
    final twoSize = size.height * 0.2;
    print('longside=$longSide width=${size.width} height=${size.height}');

    canvas.drawArc(Rect.fromLTWH(0, circleTop, longSide / 2, twoSize),
        math.pi, math.pi, true, p);
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.2, size.width, size.height), p);

    // rev2
    // canvas.drawCircle(Offset(size.width /2, size.height * 0.2), longSide * 0.1, p2);
    // rev1
    // canvas.drawCircle(Offset(size.width / 2, size.height),
    //     size.width * 0.1, p);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
