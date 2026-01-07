/// Utility class for time and duration formatting
class FormatUtils {
  /// Format a DateTime to a 12-hour time string (e.g., "2:30 PM")
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Format a duration to HH:MM:SS format
  static String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Format a duration to Xh Ym format
  static String formatTimeHM(Duration duration) {
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60);
    return '${hours}h ${minutes}m';
  }
}
