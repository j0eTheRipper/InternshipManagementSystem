import 'package:intl/intl.dart';

DateTime? parseServerTime(String? iso) {
  if (iso == null) return null;
  final dt = DateTime.tryParse(iso);
  if (dt == null) return null;
  return DateTime.utc(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, dt.millisecond).toLocal();
}

String formatTime12(DateTime dt) {
  final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final minute = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $ampm';
}

String formatTime24(DateTime dt) {
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

String formatRelativeTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) {
    return DateFormat('h:mm a').format(dt);
  } else if (diff.inDays == 1) {
    return 'Yesterday';
  } else if (diff.inDays < 7) {
    return DateFormat('EEE').format(dt);
  } else {
    return DateFormat('MMM d').format(dt);
  }
}
