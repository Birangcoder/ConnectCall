import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  /// Formats a timestamp the way the Call History screen expects:
  /// "Today, 11:45 AM" / "Yesterday, 6:20 PM" / "Mon 3, 6:20 PM"
  static String relativeCallTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final timeStr = DateFormat('h:mm a').format(dateTime);

    if (date == today) return 'Today, $timeStr';
    if (date == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, $timeStr';
    }
    return '${DateFormat('MMM d').format(dateTime)}, $timeStr';
  }

  /// Formats an in-call duration as mm:ss, e.g. "02:35".
  static String callDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
