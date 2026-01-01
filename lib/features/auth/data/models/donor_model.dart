import 'package:hive/hive.dart';
import '../../domain/entities/donor.dart';

part 'donor_model.g.dart'; // Hive generated adapter

@HiveType(typeId: 2) // Unique typeId for Donor
class DonorModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String bloodGroup;

  @HiveField(3)
  final String dob;

  @HiveField(4)
  final String email;

  @HiveField(5)
  final String phone;

  @HiveField(6)
  final String address;

  @HiveField(7)
  final String password;

  DonorModel({
    required this.id,
    required this.fullName,
    required this.bloodGroup,
    required this.dob,
    required this.email,
    required this.phone,
    required this.address,
    required this.password,
  });

  /// Convert from Entity
  factory DonorModel.fromEntity(Donor donor) {
    return DonorModel(
      id: donor.id,
      fullName: donor.fullName,
      bloodGroup: donor.bloodGroup,
      dob: donor.dob,
      email: donor.email,
      phone: donor.phone,
      address: donor.address,
      password: donor.password,
    );
  }

  /// Convert to Entity
  Donor toEntity() {
    return Donor(
      id: id,
      fullName: fullName,
      bloodGroup: bloodGroup,
      dob: dob,
      email: email,
      phone: phone,
      address: address,
      password: password,
    );
  }
}
