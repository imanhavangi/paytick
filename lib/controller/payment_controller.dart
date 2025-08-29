import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;
import '../model/payment.dart';
import '../model/payment_history.dart';
import '../model/payment_category.dart';
import '../utils/date_utils.dart';

class PaymentController extends GetxController {
  static const String _paymentsBoxName = 'payments';
  static const String _settingsBoxName = 'settings';
  static const String _historyBoxName = 'payment_history';

  final RxList<Payment> _payments = <Payment>[].obs;
  final RxList<PaymentHistory> _paymentHistory = <PaymentHistory>[].obs;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late Box<Payment> _paymentsBox;
  late Box<PaymentHistory> _historyBox;
  late Box _settingsBox;

  List<Payment> get payments => _payments;
  List<PaymentHistory> get paymentHistory => _paymentHistory;

  /// Get total amount due this month
  double get totalDueThisMonth {
    return _payments
        .where((payment) => isInCurrentMonth(payment.nextDue))
        .fold(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get payments due this month
  List<Payment> get paymentsDueThisMonth {
    return _payments
        .where((payment) => isInCurrentMonth(payment.nextDue))
        .toList();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeNotifications();
    await _initializeHive();
    await _loadPayments();
  }

  /// Initialize local notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);

    // Request notification permissions for Android 13+
    if (Platform.isAndroid) {
      await _requestNotificationPermissions();
    }
  }

  /// Request notification permissions for Android 13+
  Future<void> _requestNotificationPermissions() async {
    try {
      final bool? result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      if (result == false) {
        print('Notification permissions denied by user');
      }

      // Also request exact alarm permission on Android 12+
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
    } catch (e) {
      print('Error requesting notification permissions: $e');
    }
  }

  /// Initialize Hive boxes
  Future<void> _initializeHive() async {
    _paymentsBox = await Hive.openBox<Payment>(_paymentsBoxName);
    _historyBox = await Hive.openBox<PaymentHistory>(_historyBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  /// Load payments from Hive
  Future<void> _loadPayments() async {
    _payments.clear();
    _payments.addAll(_paymentsBox.values);

    // Migrate old payments that don't have category field
    await _migrateOldPayments();

    _payments.sort((a, b) => a.nextDue.compareTo(b.nextDue));

    _paymentHistory.clear();
    _paymentHistory.addAll(_historyBox.values);
    _paymentHistory.sort((a, b) => b.paidDate.compareTo(a.paidDate));
  }

  /// Migrate old payments to have default category
  Future<void> _migrateOldPayments() async {
    bool needsSave = false;

    for (final payment in _payments) {
      // Check if category is null (for old records)
      try {
        final _ = payment.category; // This will return default if null
      } catch (e) {
        // If there's any issue, set default category
        payment.category = PaymentCategory.general;
        needsSave = true;
      }
    }

    if (needsSave) {
      for (final payment in _payments) {
        await _paymentsBox.put(payment.id, payment);
      }
      print('Migrated ${_payments.length} payments to include category field');
    }
  }

  /// Add a new payment
  Future<void> addPayment({
    required String clientName,
    required double amount,
    required PaymentFrequency frequency,
    required DateTime nextDue,
    PaymentCategory category = PaymentCategory.general,
    String? description,
  }) async {
    final id = _generateId();
    final payment = Payment(
      id: id,
      clientName: clientName,
      amount: amount,
      frequency: frequency,
      nextDue: nextDue,
      category: category,
      description: description,
    );

    await _paymentsBox.put(id, payment);
    _payments.add(payment);
    _payments.sort((a, b) => a.nextDue.compareTo(b.nextDue));

    await _scheduleNotification(payment);
  }

  /// Update an existing payment
  Future<void> updatePayment(
    Payment payment, {
    required String clientName,
    required double amount,
    required PaymentFrequency frequency,
    required DateTime nextDue,
    PaymentCategory? category,
    String? description,
  }) async {
    // Cancel existing notification
    await _cancelNotification(payment.id);

    // Update payment properties
    payment.clientName = clientName;
    payment.amount = amount;
    payment.frequency = frequency;
    payment.nextDue = nextDue;
    if (category != null) payment.category = category;
    payment.description = description;

    // Save to Hive
    await _paymentsBox.put(payment.id, payment);

    // Update UI
    _payments.refresh();
    _payments.sort((a, b) => a.nextDue.compareTo(b.nextDue));

    // Schedule new notification
    await _scheduleNotification(payment);
  }

  /// Toggle payment as paid
  Future<void> togglePaid(Payment payment) async {
    // Cancel existing notification
    await _cancelNotification(payment.id);

    // Create payment history record
    final historyId = _generateId();
    final history = PaymentHistory(
      id: historyId,
      clientName: payment.clientName,
      amount: payment.amount,
      frequency: payment.frequency,
      paidDate: DateTime.now(),
      originalPaymentId: payment.id,
      category: payment.category,
      description: payment.description,
    );

    // Save history
    await _historyBox.put(historyId, history);
    _paymentHistory.insert(0, history);

    // Mark as paid and calculate next due date
    payment.markAsPaid();

    // Save to Hive
    await _paymentsBox.put(payment.id, payment);

    // Update UI
    _payments.refresh();
    _payments.sort((a, b) => a.nextDue.compareTo(b.nextDue));

    // Schedule new notification
    await _scheduleNotification(payment);
  }

  /// Delete a payment
  Future<void> deletePayment(Payment payment) async {
    await _cancelNotification(payment.id);
    await _paymentsBox.delete(payment.id);
    _payments.remove(payment);
  }

  /// Generate unique ID for new payments
  int _generateId() {
    final lastId = _settingsBox.get('lastId', defaultValue: 0) as int;
    final newId = lastId + 1;
    _settingsBox.put('lastId', newId);
    return newId;
  }

  /// Schedule notification one day before due date
  Future<void> _scheduleNotification(Payment payment) async {
    final notificationDate = payment.nextDue.subtract(const Duration(days: 1));

    // Don't schedule notifications for past dates
    if (notificationDate.isBefore(DateTime.now())) {
      return;
    }

    final scheduledDate = tz.TZDateTime.from(
      DateTime(
        notificationDate.year,
        notificationDate.month,
        notificationDate.day,
        9, // 9 AM
      ),
      tz.local,
    );

    try {
      // Try to schedule exact notification first
      await _notificationsPlugin.zonedSchedule(
        payment.id,
        'Payment Due Tomorrow',
        '${payment.clientName} - ${payment.formattedAmount}',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'payment_reminders',
            'Payment Reminders',
            channelDescription: 'Notifications for upcoming payment due dates',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      // If exact scheduling fails, try without exact timing (fallback for Android 12+)
      try {
        await _notificationsPlugin.zonedSchedule(
          payment.id,
          'Payment Due Tomorrow',
          '${payment.clientName} - ${payment.formattedAmount}',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'payment_reminders',
              'Payment Reminders',
              channelDescription:
                  'Notifications for upcoming payment due dates',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          // Remove exact time matching to allow inexact scheduling
        );
      } catch (e2) {
        // If all scheduling fails, just log the error but don't crash the app
        print(
            'Warning: Could not schedule notification for payment ${payment.id}: $e2');
        print(
            'Notifications may not work properly. Please check app permissions.');
      }
    }
  }

  /// Cancel notification for a payment
  Future<void> _cancelNotification(int paymentId) async {
    await _notificationsPlugin.cancel(paymentId);
  }

  @override
  void onClose() {
    _paymentsBox.close();
    _historyBox.close();
    _settingsBox.close();
    super.onClose();
  }
}
