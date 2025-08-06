import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../model/payment.dart';
import '../utils/date_utils.dart';

class PaymentController extends GetxController {
  static const String _paymentsBoxName = 'payments';
  static const String _settingsBoxName = 'settings';
  
  final RxList<Payment> _payments = <Payment>[].obs;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  late Box<Payment> _paymentsBox;
  late Box _settingsBox;
  
  List<Payment> get payments => _payments;
  
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
  }
  
  /// Initialize Hive boxes
  Future<void> _initializeHive() async {
    _paymentsBox = await Hive.openBox<Payment>(_paymentsBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }
  
  /// Load payments from Hive
  Future<void> _loadPayments() async {
    _payments.clear();
    _payments.addAll(_paymentsBox.values);
    _payments.sort((a, b) => a.nextDue.compareTo(b.nextDue));
  }
  
  /// Add a new payment
  Future<void> addPayment({
    required String clientName,
    required double amount,
    required PaymentFrequency frequency,
    required DateTime nextDue,
  }) async {
    final id = _generateId();
    final payment = Payment(
      id: id,
      clientName: clientName,
      amount: amount,
      frequency: frequency,
      nextDue: nextDue,
    );
    
    await _paymentsBox.put(id, payment);
    _payments.add(payment);
    _payments.sort((a, b) => a.nextDue.compareTo(b.nextDue));
    
    await _scheduleNotification(payment);
  }
  
  /// Toggle payment as paid
  Future<void> togglePaid(Payment payment) async {
    // Cancel existing notification
    await _cancelNotification(payment.id);
    
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
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
  
  /// Cancel notification for a payment
  Future<void> _cancelNotification(int paymentId) async {
    await _notificationsPlugin.cancel(paymentId);
  }
  
  @override
  void onClose() {
    _paymentsBox.close();
    _settingsBox.close();
    super.onClose();
  }
} 