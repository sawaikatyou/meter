import 'dart:io';

bool isUnitTestMode() {
  return Platform.environment.containsKey('FLUTTER_TEST');
}
