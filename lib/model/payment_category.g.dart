// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentCategoryAdapter extends TypeAdapter<PaymentCategory> {
  @override
  final int typeId = 3;

  @override
  PaymentCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentCategory.general;
      case 1:
        return PaymentCategory.client;
      case 2:
        return PaymentCategory.subscription;
      case 3:
        return PaymentCategory.rental;
      case 4:
        return PaymentCategory.loan;
      case 5:
        return PaymentCategory.maintenance;
      case 6:
        return PaymentCategory.consulting;
      case 7:
        return PaymentCategory.freelance;
      default:
        return PaymentCategory.general;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentCategory obj) {
    switch (obj) {
      case PaymentCategory.general:
        writer.writeByte(0);
        break;
      case PaymentCategory.client:
        writer.writeByte(1);
        break;
      case PaymentCategory.subscription:
        writer.writeByte(2);
        break;
      case PaymentCategory.rental:
        writer.writeByte(3);
        break;
      case PaymentCategory.loan:
        writer.writeByte(4);
        break;
      case PaymentCategory.maintenance:
        writer.writeByte(5);
        break;
      case PaymentCategory.consulting:
        writer.writeByte(6);
        break;
      case PaymentCategory.freelance:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
