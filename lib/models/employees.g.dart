// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employees.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmployeeAdapter extends TypeAdapter<Employee> {
  @override
  final int typeId = 0;

  @override
  Employee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Employee(
      xodim_id: fields[0] as int,
      name: fields[1] as String,
      password: fields[2] as String,
      zakaz: fields[3] as int,
      tarqatildi: fields[4] as int,
      atmen: fields[5] as int,
      naqd: fields[6] as int,
      karta: fields[7] as int,
      qarz: fields[8] as int,
      ortiqchapul: fields[9] as int,
      kassa_sanasi: fields[10] as String,
      createdAt: fields[11] as DateTime,
      id: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Employee obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.xodim_id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.zakaz)
      ..writeByte(4)
      ..write(obj.tarqatildi)
      ..writeByte(5)
      ..write(obj.atmen)
      ..writeByte(6)
      ..write(obj.naqd)
      ..writeByte(7)
      ..write(obj.karta)
      ..writeByte(8)
      ..write(obj.qarz)
      ..writeByte(9)
      ..write(obj.ortiqchapul)
      ..writeByte(10)
      ..write(obj.kassa_sanasi)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
