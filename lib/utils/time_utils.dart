import 'package:intl/intl.dart';

class TimeUtils {
  static String formatDuration(Duration duration, String format) {
    final formatter = DateFormat(format);
    if(duration.inHours > 0) {
      return formatter.format(DateTime(0).add(duration));
    } else {
      final minFormatter = DateFormat("mm:ss");
      return minFormatter.format(DateTime(0).add(duration));
    }
  }

  static String convertToUtcFormat(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime.toUtc());
  }

  static String convertToFormat(String format, DateTime dateTime) {
    return DateFormat(format).format(dateTime);
  }

  static String timeAgo(DateTime time, {bool numericDates = true}) {
    final date2 = DateTime.now();
    final difference = date2.difference(time);

    if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '${(difference.inDays / 7).floor()}w' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays}d';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1d' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours}h';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1h' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes}m';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1m' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds}s';
    } else {
      return 'Just now';
    }
  }

  static String dayAgo(DateTime time) {
    final date2 = DateTime.now();
    final difference = date2.difference(time);

    if((difference.inDays / 30).floor() >= 1) {
      return "${(difference.inDays / 30).floor()}月前";
    } else if ((difference.inDays / 7).floor() >= 1) {
      return '${(difference.inDays / 7).floor()}周前';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}天前';
    } else {
      return '今天';
    }
  }
}