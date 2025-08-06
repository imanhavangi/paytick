import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:paytick/controller/payment_controller.dart';
import 'package:paytick/model/payment.dart';

void main() {
  group('PaymentController', () {
    late PaymentController controller;

    setUpAll(() async {
      // Initialize Hive for testing
      await Hive.initFlutter();
      Hive.registerAdapter(PaymentFrequencyAdapter());
      Hive.registerAdapter(PaymentAdapter());
    });

    setUp(() async {
      // Clean up any existing boxes
      if (Hive.isBoxOpen('payments')) {
        await Hive.box('payments').clear();
      }
      if (Hive.isBoxOpen('settings')) {
        await Hive.box('settings').clear();
      }
      
      // Create fresh controller for each test
      controller = PaymentController();
      Get.put(controller);
      controller.onInit();
    });

    tearDown(() {
      controller.onClose();
      Get.delete<PaymentController>();
    });

    group('togglePaid', () {
      test('should update nextDue date for monthly payment', () async {
        // Add a monthly payment
        final originalDate = DateTime(2023, 1, 15);
        await controller.addPayment(
          clientName: 'Test Client',
          amount: 100.0,
          frequency: PaymentFrequency.monthly,
          nextDue: originalDate,
        );

        final payment = controller.payments.first;
        expect(payment.nextDue, equals(originalDate));

        // Mark as paid
        await controller.togglePaid(payment);

        // Check that nextDue moved to next month
        expect(payment.nextDue, equals(DateTime(2023, 2, 15)));
      });

      test('should update nextDue date for weekly payment', () async {
        // Add a weekly payment
        final originalDate = DateTime(2023, 1, 15); // Sunday
        await controller.addPayment(
          clientName: 'Test Client',
          amount: 50.0,
          frequency: PaymentFrequency.weekly,
          nextDue: originalDate,
        );

        final payment = controller.payments.first;
        expect(payment.nextDue, equals(originalDate));

        // Mark as paid
        await controller.togglePaid(payment);

        // Check that nextDue moved to next week
        expect(payment.nextDue, equals(DateTime(2023, 1, 22)));
      });

      test('should persist changes to Hive', () async {
        // Add a payment
        final originalDate = DateTime(2023, 1, 15);
        await controller.addPayment(
          clientName: 'Test Client',
          amount: 100.0,
          frequency: PaymentFrequency.monthly,
          nextDue: originalDate,
        );

        final payment = controller.payments.first;
        final paymentId = payment.id;

        // Mark as paid
        await controller.togglePaid(payment);

        // Create new controller to verify persistence
        final newController = PaymentController();
        newController.onInit();

        // Find the payment and verify it was updated
        final persistedPayment = newController.payments
            .firstWhere((p) => p.id == paymentId);
        expect(persistedPayment.nextDue, equals(DateTime(2023, 2, 15)));

        newController.onClose();
      });

      test('should maintain weekday for weekly payments', () async {
        // Test different weekdays
        final testDates = [
          DateTime(2023, 1, 16), // Monday
          DateTime(2023, 1, 17), // Tuesday
          DateTime(2023, 1, 18), // Wednesday
          DateTime(2023, 1, 19), // Thursday
          DateTime(2023, 1, 20), // Friday
          DateTime(2023, 1, 21), // Saturday
          DateTime(2023, 1, 22), // Sunday
        ];

        for (final date in testDates) {
          // Clear previous payments
          for (final payment in controller.payments.toList()) {
            await controller.deletePayment(payment);
          }

          await controller.addPayment(
            clientName: 'Test Client',
            amount: 50.0,
            frequency: PaymentFrequency.weekly,
            nextDue: date,
          );

          final payment = controller.payments.first;
          await controller.togglePaid(payment);

          // Verify weekday is maintained
          expect(payment.nextDue.weekday, equals(date.weekday));
        }
      });
    });

    group('totalDueThisMonth', () {
      test('should calculate total for current month payments', () async {
        final now = DateTime.now();
        final thisMonth = DateTime(now.year, now.month, 15);
        final nextMonth = DateTime(now.year, now.month + 1, 15);

        // Add payments for this month
        await controller.addPayment(
          clientName: 'Client 1',
          amount: 100.0,
          frequency: PaymentFrequency.monthly,
          nextDue: thisMonth,
        );

        await controller.addPayment(
          clientName: 'Client 2',
          amount: 50.0,
          frequency: PaymentFrequency.weekly,
          nextDue: thisMonth,
        );

        // Add payment for next month (should not be included)
        await controller.addPayment(
          clientName: 'Client 3',
          amount: 75.0,
          frequency: PaymentFrequency.monthly,
          nextDue: nextMonth,
        );

        expect(controller.totalDueThisMonth, equals(150.0));
      });

      test('should return 0 when no payments due this month', () async {
        final nextMonth = DateTime.now().add(const Duration(days: 35));
        
        await controller.addPayment(
          clientName: 'Client 1',
          amount: 100.0,
          frequency: PaymentFrequency.monthly,
          nextDue: nextMonth,
        );

        expect(controller.totalDueThisMonth, equals(0.0));
      });
    });
  });
} 