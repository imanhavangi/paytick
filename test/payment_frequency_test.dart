import 'package:flutter_test/flutter_test.dart';
import 'package:paytick/model/payment.dart';

void main() {
  group('PaymentFrequency', () {
    group('nextDate', () {
      test('monthly frequency should move to same day next month', () {
        final startDate = DateTime(2023, 1, 15);
        final nextDate = PaymentFrequency.monthly.nextDate(startDate);
        
        expect(nextDate, equals(DateTime(2023, 2, 15)));
      });

      test('monthly frequency should handle month end properly', () {
        final startDate = DateTime(2023, 1, 31);
        final nextDate = PaymentFrequency.monthly.nextDate(startDate);
        
        // February doesn't have 31 days, so should go to last day of February
        expect(nextDate, equals(DateTime(2023, 2, 28)));
      });

      test('monthly frequency should handle leap year February', () {
        final startDate = DateTime(2024, 1, 31); // 2024 is leap year
        final nextDate = PaymentFrequency.monthly.nextDate(startDate);
        
        expect(nextDate, equals(DateTime(2024, 2, 29)));
      });

      test('monthly frequency should handle year transition', () {
        final startDate = DateTime(2023, 12, 15);
        final nextDate = PaymentFrequency.monthly.nextDate(startDate);
        
        expect(nextDate, equals(DateTime(2024, 1, 15)));
      });

      test('weekly frequency should add 7 days', () {
        final startDate = DateTime(2023, 1, 15); // Sunday
        final nextDate = PaymentFrequency.weekly.nextDate(startDate);
        
        expect(nextDate, equals(DateTime(2023, 1, 22))); // Next Sunday
      });

      test('weekly frequency should maintain weekday', () {
        final startDate = DateTime(2023, 1, 16); // Monday
        final nextDate = PaymentFrequency.weekly.nextDate(startDate);
        
        expect(nextDate.weekday, equals(startDate.weekday));
        expect(nextDate, equals(DateTime(2023, 1, 23))); // Next Monday
      });

      test('weekly frequency should handle month transition', () {
        final startDate = DateTime(2023, 1, 30); // Monday
        final nextDate = PaymentFrequency.weekly.nextDate(startDate);
        
        expect(nextDate, equals(DateTime(2023, 2, 6))); // Next Monday
      });

      test('weekly frequency should handle year transition', () {
        final startDate = DateTime(2023, 12, 25); // Monday
        final nextDate = PaymentFrequency.weekly.nextDate(startDate);
        
        expect(nextDate, equals(DateTime(2024, 1, 1))); // Next Monday
      });
    });

    group('displayName', () {
      test('monthly should return "Monthly"', () {
        expect(PaymentFrequency.monthly.displayName, equals('Monthly'));
      });

      test('weekly should return "Weekly"', () {
        expect(PaymentFrequency.weekly.displayName, equals('Weekly'));
      });
    });
  });
} 