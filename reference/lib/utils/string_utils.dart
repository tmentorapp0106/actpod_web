import 'dart:math';

class StringUtils{
  final _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
  length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  static String shorten(String str, int length) {
    return str.length > length ? '${str.substring(0, length)}...' : str;
  }

  static String approximateNumberString(int number) {
    if(number < 10) {
      return "0~10";
    } else if(number < 50) {
      return "10~50";
    } else if(number < 100) {
      return "50~100";
    } else if(number < 1000) {
      return "${(number / 100).toInt().toString()}00以上";
    } else {
      return "${(number / 100).toInt().toString()}k";
    }
  }
}