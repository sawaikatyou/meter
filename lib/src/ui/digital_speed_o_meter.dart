import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter/src/bloc/meter_main_bloc.dart';

/// OFF表示の色
const sToneDownColor = Colors.black87;

/// OFF表示の[Paint] オブジェクト
final sToneDownPaint = Paint()..color = sToneDownColor;

///　デジタル表示を行うWidget
/// [MeterMainState] の値に応じて挙動する
@immutable
class DigitalSpeedOMeter extends StatelessWidget {
  const DigitalSpeedOMeter(
      {super.key,
      required this.width,
      required this.height,
      required this.color,
      required this.offset});

  /// 画面横幅(point)
  final double width;

  /// 画面縦幅(point)
  final double height;

  /// ON表示の色
  final Color color;

  /// [MeterMainState.digitalMeterInformation] のどこからどこまでを取得するか？
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeterMainBloc, MeterMainState>(
      builder: (context, state) {
        late List<bool> inputValues;
        if (state.digitalMeterInformation.isEmpty) {
          inputValues = <bool>[];
          for (int i = 0; i < 7; i++) {
            inputValues.add(false);
          }
        } else {
          final innerStart = offset.dx.toInt();
          inputValues = <bool>[];
          for (int i = 0; i < 7; i++) {
            inputValues.add(state.digitalMeterInformation[i + innerStart]);
          }
        }

        return CustomPaint(
          painter: DigitalMeterPainter(context, inputValues, color),
          size: Size(width, height),
        );
      },
    );
  }
}

/// デバッグ用機能 デジタル表示の際の表示設定を指定する
enum _GraphPaintSetting {
  normal, // デフォルト on,off 描画を使い分ける
  translucent, // 描画しない(透明)
  disable, // off描画
  color, // on描画
  rect, // Pathでなく rect で描画
}

/// デジタル８の字式表示ロジックの本体
class DigitalMeterPainter extends CustomPainter {
  DigitalMeterPainter(
    this.context,
    this.values,
    this.color,
  );

  BuildContext context;
  List<bool> values;
  Color color;

  // 内枠のPadding
  static const kPadding = 5.0;

  // 枠線の太さ
  static const kBarWidth = 20.0;

  // 各線ごとの固定設定、この値は values よりも優先させる
  static const kEnabledSetting = <_GraphPaintSetting>[
    _GraphPaintSetting.normal,
    _GraphPaintSetting.normal,
    _GraphPaintSetting.normal,
    _GraphPaintSetting.normal,
    _GraphPaintSetting.normal,
    _GraphPaintSetting.normal,
    _GraphPaintSetting.normal,
  ];

  /// 桁数の中で線を演算
  @override
  void paint(Canvas canvas, Size size) {
    final colorPaint = Paint()..color = color;
    final width = size.width;
    final height = size.height;
    final halfH = (height * 0.5);
    const halfBar = (kBarWidth * 0.5);

    //   00000
    // 1       2
    // 1       2
    //   33333
    // 4       5
    // 4       5
    //   66666
    final rightBase = width - kBarWidth;
    final drawRect = <Rect>[
      Rect.fromLTWH(0, 0, width, kBarWidth),
      Rect.fromLTWH(0, 0, kBarWidth, halfH),
      Rect.fromLTWH(rightBase, 0, kBarWidth, halfH),
      Rect.fromLTWH(0, halfH - halfBar, width, kBarWidth),
      Rect.fromLTWH(0, halfH, kBarWidth, halfH),
      Rect.fromLTWH(rightBase, halfH, kBarWidth, halfH),
      Rect.fromLTWH(0, height - kBarWidth, width, kBarWidth),
    ];

    for (int i = 0; i < drawRect.length; i++) {
      final rect = drawRect[i];
      final l = rect.left;
      final t = rect.top;
      final w = rect.width;
      final h = rect.height;

      Path? path;
      switch (i) {
        case 0:
          // (0-1) ------- (0-2)
          //   ＼           ／
          //   (0-4) --- (0-3)
          path = Path()
            ..moveTo(l + kPadding, t) // 0-1
            ..lineTo(l + w - kPadding, t) // 0-2
            ..lineTo(l + w - kBarWidth - kPadding, t + kBarWidth) // 0-3
            ..lineTo(l + kBarWidth + kPadding, t + kBarWidth) // 0-4
            ..close();
          break;

        case 1:
          // (1-1) ＼
          //   |     (1-2)
          //   |       |
          //   |       |
          //   |     (1-3)
          //   |   ／
          // (1-4)
          path = Path()
            ..moveTo(l, t + kPadding) // 1-1
            ..lineTo(l + kBarWidth, t + kBarWidth + kPadding) // 1-2
            ..lineTo(l + kBarWidth, t + h - halfBar - kPadding) // 1-3
            ..lineTo(l, t + h - kPadding) // 1-4
            ..close();
          break;

        case 2:
          //       (2-2)
          //     ／  |
          // (2-1)   |
          //   |     |
          // (2-4)   |
          //     ＼  |
          //       (2-3)
          path = Path()
            ..moveTo(l, t + kBarWidth + kPadding) // 2-1
            ..lineTo(l + w, t + kPadding) // 2-2
            ..lineTo(l + w, t + h - kPadding) // 2-3
            ..lineTo(l, t + h - halfBar - kPadding) // 2-4
            ..close();
          break;

        case 4:
          // (4-1) ＼
          //   |     (4-2)
          //   |       |
          //   |       |
          //   |     (4-3)
          //   |   ／
          // (4-4)
          path = Path()
            ..moveTo(l, t + kPadding) // 4-1
            ..lineTo(l + kBarWidth, t + kBarWidth - kPadding) // 4-2
            ..lineTo(l + kBarWidth, t + h - kBarWidth - kPadding) // 4-3
            ..lineTo(l, t + h - kPadding) // 4-4
            ..close();
          break;

        case 5:
          //       (5-2)
          //     ／  |
          // (５-1)  |
          //   |     |
          // (5-4)   |
          //     ＼  |
          //       (5-3)
          path = Path()
            ..moveTo(l, t + kBarWidth - kPadding) // 5-1
            ..lineTo(l + w, t + kPadding) // 5-2
            ..lineTo(l + w, t + h - kPadding) // 5-3
            ..lineTo(l, t + h - kBarWidth - kPadding) // 5-4
            ..close();
          break;

        case 3:
          //      (3-2) --- (3-3)
          //     ／             ＼
          // (3-1)              (3-4)
          //     ＼             ／
          //      (3-6) --- (3-5)
          path = Path()
            ..moveTo(l + kPadding, t + halfBar) // 3-1
            ..lineTo(l + kBarWidth + kPadding * 2, t) // 3-2
            ..lineTo(l + w - kBarWidth - kPadding * 2, t) // 3-3
            ..lineTo(l + w - kPadding, t + h * 0.5) // 3-4
            ..lineTo(l + w - kBarWidth - kPadding * 2, t + h) // 3-3
            ..lineTo(l + kBarWidth + kPadding * 2, t + h) // 3-2
            ..close();
          break;

        case 6:
          //   (6-1) --- (6-2)
          //   ／           ＼
          // (6-4) ------- (6-3)
          path = Path()
            ..moveTo(l + kPadding + kBarWidth, t) // 6-1
            ..lineTo(l + w - kBarWidth - kPadding, t) // 6-2
            ..lineTo(l + w - kPadding, t + h) // 6-3
            ..lineTo(l + kPadding, t + h) // 6-4
            ..close();
          break;
        default:
          break;
      }

      switch (kEnabledSetting[i]) {
        case _GraphPaintSetting.normal:
          canvas.drawPath(path!, values[i] ? colorPaint : sToneDownPaint);
          break;
        // coverage:ignore-start
        case _GraphPaintSetting.disable:
          canvas.drawPath(path!, sToneDownPaint);
          break;
        case _GraphPaintSetting.color:
          canvas.drawPath(path!, colorPaint);
          break;
        case _GraphPaintSetting.rect:
          canvas.drawRect(rect, Paint()..color = Colors.red);
          break;
        case _GraphPaintSetting.translucent:
        default:
          break;
        // coverage:ignore-end
      }
    }
  }

// coverage:ignore-start
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
// coverage:ignore-end
}

class DigitalSpeedOMeterDot extends StatelessWidget {
  const DigitalSpeedOMeterDot({
    super.key,
    required this.index,
    required this.color,
  });

  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeterMainBloc, MeterMainState>(
        builder: (context, state) {
      final list = state.digitalMeterInformation;
      return Icon(
        Icons.circle,
        color: (list.length > index && list[index])
            ? Colors.green
            : sToneDownColor,
      );
    });
  }
}
