// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentHistoryAdapter extends TypeAdapter<PaymentHistory> {
  @override
  final int typeId = 2;

  @override
  PaymentHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentHistory(
      id: fields[0] as int,
      clientName: fields[1] as String,
      amount: fields[2] as double,
      frequency: fields[3] as PaymentFrequency,
      paidDate: fields[4] as DateTime,
      originalPaymentId: fields[5] as int,
      description: fields[7] as String?,
    ).._category = fields[6] as PaymentCategory?;
  }

  @override
  void write(BinaryWriter writer, PaymentHistory obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientName)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.paidDate)
      ..writeByte(5)
      ..write(obj.originalPaymentId)
      ..writeByte(6)
      ..write(obj._category)
      ..writeByte(7)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
