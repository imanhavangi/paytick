import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'payment.g.dart';

@HiveType(typeId: 0)
enum PaymentFrequency {
  @HiveField(0)
  monthly,
  @HiveField(1)
  weekly;

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
        final lastDayOfTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
        
        // Use the original day or the last day of the month if the day doesn't exist
        final targetDay = from.day <= lastDayOfTargetMonth ? from.day : lastDayOfTargetMonth;
        
        return DateTime(targetYear, targetMonth, targetDay);
      case PaymentFrequency.weekly:
        // Add 7 days
        return from.add(const Duration(days: 7));
    }
  }

  String get displayName {
    switch (this) {
      case PaymentFrequency.monthly:
        return 'Monthly';
      case PaymentFrequency.weekly:
        return 'Weekly';
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

  Payment({
    required this.id,
    required this.clientName,
    required this.amount,
    required this.frequency,
    required this.nextDue,
  });

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
    return 'Payment(id: $id, clientName: $clientName, amount: $amount, frequency: $frequency, nextDue: $nextDue)';
  }
} 