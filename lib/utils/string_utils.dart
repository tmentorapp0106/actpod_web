import 'dart:math';

class StringUtils{
  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
  length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  static String shorten(String str, int length) {
    return str.length > length ? '${str.substring(0, length)}...' : str;
  }
}