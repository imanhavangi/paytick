import 'package:hive/hive.dart';
import 'payment.dart';
import 'payment_category.dart';

part 'payment_history.g.dart';

@HiveType(typeId: 2)
class PaymentHistory extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  String clientName;

  @HiveField(2)
  double amount;

  @HiveField(3)
  PaymentFrequency frequency;

  @HiveField(4)
  DateTime paidDate;

  @HiveField(5)
  int originalPaymentId;

  @HiveField(6)
  PaymentCategory? _category;

  @HiveField(7)
  String? description;

  PaymentHistory({
    required this.id,
    required this.clientName,
    required this.amount,
    required this.frequency,
    required this.paidDate,
    required this.originalPaymentId,
    PaymentCategory? category,
    this.description,
  }) : _category = category;

  // Getter for category with default value
  PaymentCategory get category => _category ?? PaymentCategory.general;

  // Setter for category
  set category(PaymentCategory value) => _category = value;

  @override
  String toString() {
    return 'PaymentHistory(id: $id, clientName: $clientName, amount: $amount, frequency: $frequency, paidDate: $paidDate, originalPaymentId: $originalPaymentId, category: $category, description: $description)';
  }
}
