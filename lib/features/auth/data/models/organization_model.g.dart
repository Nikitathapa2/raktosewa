// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'organization_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrganizationModelAdapter extends TypeAdapter<OrganizationModel> {
  @override
  final int typeId = 1;

  @override
  OrganizationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrganizationModel(
      id: fields[0] as String,
      organizationName: fields[1] as String,
      headOfOrganization: fields[2] as String,
      email: fields[3] as String,
      phoneNumber: fields[4] as String?,
      address: fields[5] as String?,
      password: fields[6] as String,
      confirmPassword: fields[7] as String?,
      terms: fields[8] as bool?,
      role: fields[9] as String?,
      isEmailVerified: fields[10] as bool?,
      googleId: fields[11] as String?,
      googleProfilePicture: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, OrganizationModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.organizationName)
      ..writeByte(2)
      ..write(obj.headOfOrganization)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.phoneNumber)
      ..writeByte(5)
      ..write(obj.address)
      ..writeByte(6)
      ..write(obj.password)
      ..writeByte(7)
      ..write(obj.confirmPassword)
      ..writeByte(8)
      ..write(obj.terms)
      ..writeByte(9)
      ..write(obj.role)
      ..writeByte(10)
      ..write(obj.isEmailVerified)
      ..writeByte(11)
      ..write(obj.googleId)
      ..writeByte(12)
      ..write(obj.googleProfilePicture);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrganizationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
