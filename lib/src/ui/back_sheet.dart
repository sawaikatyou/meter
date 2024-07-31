import 'dart:math' as math;

import 'package:flutter/material.dart';

enum Direction { left, top, right, bottom }

@immutable
class BackSheet extends StatelessWidget {
  const BackSheet({super.key});

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

    final circleTop = size.height * 0.1;
    final twoSize = size.height * 0.2;
    final arcWidth = (size.width > size.height) ? size.width : size.height / 2;

    canvas.drawArc(Rect.fromLTWH(0, circleTop, arcWidth, twoSize), math.pi,
        math.pi, true, p);
    canvas.drawRect(
        Rect.fromLTWH(0, size.height * 0.2, size.width, size.height), p);
  }

// coverage:ignore-start
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
// coverage:ignore-end
}
