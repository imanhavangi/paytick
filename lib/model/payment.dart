import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'payment_category.dart';

part 'payment.g.dart';

@HiveType(typeId: 0)
enum PaymentFrequency {
  @HiveField(0)
  monthly,
  @HiveField(1)
  weekly,
  @HiveField(2)
  biweekly,
  @HiveField(3)
  quarterly,
  @HiveField(4)
  yearly;

  /// Calculate the next due date based on frequency
  DateTime nextDate(DateTime from) {
    switch (this) {
      case PaymentFrequency.monthly:
        // Same calendar day next month
        int targetYear = from.year;
        int targetMonth = from.month + 1;

        // Handle year overflow
        if (targetMonth > 12) {
          targetYear++;
          targetMonth = 1;
        }

        // Get the last day of the target month
        final lastDayOfTargetMonth =
            DateTime(targetYear, targetMonth + 1, 0).day;

        // Use the original day or the last day of the month if the day doesn't exist
        final targetDay =
            from.day <= lastDayOfTargetMonth ? from.day : lastDayOfTargetMonth;

        return DateTime(targetYear, targetMonth, targetDay);
      case PaymentFrequency.weekly:
        // Add 7 days
        return from.add(const Duration(days: 7));
      case PaymentFrequency.biweekly:
        // Add 14 days
        return from.add(const Duration(days: 14));
      case PaymentFrequency.quarterly:
        // Add 3 months
        int targetYear = from.year;
        int targetMonth = from.month + 3;

        // Handle year overflow
        while (targetMonth > 12) {
          targetYear++;
          targetMonth -= 12;
        }

        // Get the last day of the target month
        final lastDayOfTargetMonth =
            DateTime(targetYear, targetMonth + 1, 0).day;

        // Use the original day or the last day of the month if the day doesn't exist
        final targetDay =
            from.day <= lastDayOfTargetMonth ? from.day : lastDayOfTargetMonth;

        return DateTime(targetYear, targetMonth, targetDay);
      case PaymentFrequency.yearly:
        // Add 1 year
        int targetYear = from.year + 1;
        int targetMonth = from.month;

        // Handle leap year edge case for Feb 29
        if (targetMonth == 2 && from.day == 29) {
          // Check if target year is leap year
          final isLeapYear = (targetYear % 4 == 0 && targetYear % 100 != 0) ||
              (targetYear % 400 == 0);
          if (!isLeapYear) {
            return DateTime(targetYear, targetMonth, 28);
          }
        }

        return DateTime(targetYear, targetMonth, from.day);
    }
  }

  String get displayName {
    switch (this) {
      case PaymentFrequency.monthly:
        return 'Monthly';
      case PaymentFrequency.weekly:
        return 'Weekly';
      case PaymentFrequency.biweekly:
        return 'Bi-weekly';
      case PaymentFrequency.quarterly:
        return 'Quarterly';
      case PaymentFrequency.yearly:
        return 'Yearly';
    }
  }
}

@HiveType(typeId: 1)
class Payment extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String clientName;

  @HiveField(2)
  double amount;

  @HiveField(3)
  PaymentFrequency frequency;

  @HiveField(4)
  DateTime nextDue;

  @HiveField(5)
  PaymentCategory? _category;

  @HiveField(6)
  String? description;

  Payment({
    required this.id,
    required this.clientName,
    required this.amount,
    required this.frequency,
    required this.nextDue,
    PaymentCategory? category,
    this.description,
  }) : _category = category;

  // Getter for category with default value
  PaymentCategory get category => _category ?? PaymentCategory.general;

  // Setter for category
  set category(PaymentCategory value) => _category = value;

  /// Format amount as currency
  String get formattedAmount {
    return NumberFormat.simpleCurrency(locale: 'en_US').format(amount);
  }

  /// Mark payment as paid and calculate next due date
  void markAsPaid() {
    nextDue = frequency.nextDate(nextDue);
  }

  @override
  String toString() {
    return 'Payment(id: $id, clientName: $clientName, amount: $amount, frequency: $frequency, nextDue: $nextDue, category: $category, description: $description)';
  }
}
