import 'package:intl/intl.dart';

/// Check if two dates are on the same day
bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

/// Check if a date is in the current month
bool isInCurrentMonth(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year && date.month == now.month;
}

/// Format date in short format (e.g., "Dec 25")
String formatDateShort(DateTime date) {
  return DateFormat('MMM d').format(date);
}

/// Format date in full format (e.g., "December 25, 2023")
String formatDateFull(DateTime date) {
  return DateFormat('MMMM d, y').format(date);
}

/// Check if a date is overdue (before today)
bool isOverdue(DateTime date) {
  final today = DateTime.now();
  return date.isBefore(DateTime(today.year, today.month, today.day));
}

/// Check if a date is due today
bool isDueToday(DateTime date) {
  return isSameDay(date, DateTime.now());
}

/// Check if a date is due tomorrow
bool isDueTomorrow(DateTime date) {
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  return isSameDay(date, tomorrow);
} 