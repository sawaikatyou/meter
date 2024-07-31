// coverage:ignore-file
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';

void loggerSetup() {
  // すべてログ出力する
  Logger.root.level = Level.ALL;

  // ログ出力内容を定義する（実装必須）
  Logger.root.onRecord.listen((LogRecord rec) {
    debugPrint(
        '[${rec.loggerName}] ${rec.level.name}: ${rec.time}: ${rec.message}');
  });
}

extension LoggeerEx on Logger {
  String dump(List<bool> input) {
    final buf = StringBuffer();
    buf.write('[');
    for (final e in input) {
      if (e == true) {
        buf.write('*');
      } else {
        buf.write(' ');
      }
    }
    buf.write(']');
    return buf.toString();
  }
}
