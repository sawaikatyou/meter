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
