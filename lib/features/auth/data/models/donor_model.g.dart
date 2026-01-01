// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'donor_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DonorModelAdapter extends TypeAdapter<DonorModel> {
  @override
  final int typeId = 2;

  @override
  DonorModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DonorModel(
      id: fields[0] as String,
      fullName: fields[1] as String,
      bloodGroup: fields[2] as String,
      dob: fields[3] as String,
      email: fields[4] as String,
      phone: fields[5] as String,
      address: fields[6] as String,
      password: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DonorModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.bloodGroup)
      ..writeByte(3)
      ..write(obj.dob)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.address)
      ..writeByte(7)
      ..write(obj.password);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DonorModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
