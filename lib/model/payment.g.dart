// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentAdapter extends TypeAdapter<Payment> {
  @override
  final int typeId = 1;

  @override
  Payment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Payment(
      id: fields[0] as int,
      clientName: fields[1] as String,
      amount: fields[2] as double,
      frequency: fields[3] as PaymentFrequency,
      nextDue: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Payment obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.nextDue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentFrequencyAdapter extends TypeAdapter<PaymentFrequency> {
  @override
  final int typeId = 0;

  @override
  PaymentFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentFrequency.monthly;
      case 1:
        return PaymentFrequency.weekly;
      default:
        return PaymentFrequency.monthly;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentFrequency obj) {
    switch (obj) {
      case PaymentFrequency.monthly:
        writer.writeByte(0);
        break;
      case PaymentFrequency.weekly:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
