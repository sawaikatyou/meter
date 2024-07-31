///　100の桁を抽出
///
/// 時速 123.4 km なら "1"
int fetch100(double speedKmh) {
  var temp = speedKmh;
  if (temp < 100) {
    return -1;
  }

  if (speedKmh > 1000) {
    temp = speedKmh % 1000;
  }
  return temp ~/ 100;
}

///　10の桁を抽出
///
/// 時速 123.4 km なら "2"
int fetch010(double speedKmh) {
  var temp = speedKmh;
  if (temp < 10) {
    return -1;
  }

  if (speedKmh > 100) {
    temp = speedKmh % 100;
  }
  return temp ~/ 10;
}

///　1の桁を抽出
///
/// 時速 123.4 km なら "3"
int fetch001(double speedKmh) {
  var temp = speedKmh;
  if (temp < 0) {
    return -1;
  }

  if (speedKmh > 10) {
    temp = speedKmh % 10;
  }
  return temp.toInt();
}

///　小数点以下を抽出
///
/// 時速 123.4 km なら "4"
int fetchMinor(double speedKmh) {
  var temp = speedKmh;
  if (temp < 0) {
    return -1;
  }

  if (speedKmh > 1) {
    temp = speedKmh % 1;
  }
  temp = (temp * 10.0);
  return temp.floor().toInt();
}
