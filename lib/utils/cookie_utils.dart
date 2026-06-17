import 'package:web/web.dart';

class CookieUtils {
  static const _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String? getCookie(String name) {
    final cookies = document.cookie.split('; ');
    for (final c in cookies) {
      final idx = c.indexOf('=');
      if (idx == -1) continue;
      final k = c.substring(0, idx);
      if (k == name) return Uri.decodeComponent(c.substring(idx + 1));
    }
    return null;
  }

  /// Set a cookie
  static void setCookie(
    String name,
    String value, {
    Duration? maxAge,
    DateTime? expires, // either maxAge or expires
    String path = '/',
    String? domain, // e.g. ".yourdomain.com" (must match current host rules)
    String sameSite = 'Lax', // 'Lax' | 'Strict' | 'None'
    bool secure = false, // must be true when sameSite=None
  }) {
    final encoded = Uri.encodeComponent(value);
    final parts = <String>[
      '$name=$encoded',
      if (expires != null) 'Expires=${_formatCookieDate(expires)}',
      if (maxAge != null) 'Max-Age=${maxAge.inSeconds}',
      'Path=$path',
      if (domain != null) 'Domain=$domain',
      'SameSite=$sameSite',
      if (secure) 'Secure',
    ];
    document.cookie = parts.join('; ');
  }

  static String _formatCookieDate(DateTime dateTime) {
    final utc = dateTime.toUtc();
    final day = utc.day.toString().padLeft(2, '0');
    final hour = utc.hour.toString().padLeft(2, '0');
    final minute = utc.minute.toString().padLeft(2, '0');
    final second = utc.second.toString().padLeft(2, '0');
    return '${_weekdays[utc.weekday - 1]}, $day ${_months[utc.month - 1]} '
        '${utc.year} $hour:$minute:$second GMT';
  }

  /// Delete a cookie
  static void deleteCookie(String name, {String path = '/', String? domain}) {
    document.cookie = [
      '$name=',
      'Max-Age=0',
      'Path=$path',
      if (domain != null) 'Domain=$domain',
    ].join('; ');
  }
}
