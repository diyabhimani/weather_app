import 'package:intl/intl.dart';

class DateTimeUtils {
  /// Format: Saturday, 12 September
  static String formatFullDate(DateTime dateTime) {
    return DateFormat('EEEE, d MMMM').format(dateTime);
  }

  /// Format: 2:45 PM
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Format: 2 PM or 12 AM
  static String formatHour(DateTime dateTime) {
    return DateFormat('h a').format(dateTime);
  }

  /// Format: Mon, Tue, etc., or 'Today' if matching today
  static String formatDayName(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return 'Today';
    }
    return DateFormat('E').format(dateTime);
  }

  /// Parses Open-Meteo ISO strings like "2026-09-12T04:30" or "2026-09-12"
  static DateTime parseDateTime(String isoString) {
    try {
      return DateTime.parse(isoString);
    } catch (_) {
      return DateTime.now();
    }
  }
}
