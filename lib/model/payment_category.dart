import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'payment_category.g.dart';

@HiveType(typeId: 3)
enum PaymentCategory {
  @HiveField(0)
  general,
  @HiveField(1)
  client,
  @HiveField(2)
  subscription,
  @HiveField(3)
  rental,
  @HiveField(4)
  loan,
  @HiveField(5)
  maintenance,
  @HiveField(6)
  consulting,
  @HiveField(7)
  freelance;

  String get displayName {
    switch (this) {
      case PaymentCategory.general:
        return 'General';
      case PaymentCategory.client:
        return 'Client Payment';
      case PaymentCategory.subscription:
        return 'Subscription';
      case PaymentCategory.rental:
        return 'Rental Income';
      case PaymentCategory.loan:
        return 'Loan Repayment';
      case PaymentCategory.maintenance:
        return 'Maintenance';
      case PaymentCategory.consulting:
        return 'Consulting';
      case PaymentCategory.freelance:
        return 'Freelance Work';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentCategory.general:
        return Icons.payment;
      case PaymentCategory.client:
        return Icons.person;
      case PaymentCategory.subscription:
        return Icons.subscriptions;
      case PaymentCategory.rental:
        return Icons.home;
      case PaymentCategory.loan:
        return Icons.account_balance;
      case PaymentCategory.maintenance:
        return Icons.build;
      case PaymentCategory.consulting:
        return Icons.business;
      case PaymentCategory.freelance:
        return Icons.work;
    }
  }

  Color get color {
    switch (this) {
      case PaymentCategory.general:
        return Colors.blue;
      case PaymentCategory.client:
        return Colors.green;
      case PaymentCategory.subscription:
        return Colors.purple;
      case PaymentCategory.rental:
        return Colors.orange;
      case PaymentCategory.loan:
        return Colors.red;
      case PaymentCategory.maintenance:
        return Colors.brown;
      case PaymentCategory.consulting:
        return Colors.teal;
      case PaymentCategory.freelance:
        return Colors.indigo;
    }
  }
}
