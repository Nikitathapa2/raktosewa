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
  final String? dob;

  @HiveField(4)
  final String email;

  @HiveField(5)
  final String? phone;

  @HiveField(6)
  final String? address;

  @HiveField(7)
  final String password;

  @HiveField(8)
  final String? confirmPassword;

  @HiveField(9)
  final bool? terms;

  @HiveField(10)
  final String? profilePicture;

  DonorModel({
    required this.id,
    required this.fullName,
    required this.bloodGroup,
    this.dob,
    required this.email,
    this.phone,
    this.address,
    required this.password,
    this.confirmPassword,
    this.terms,
    this.profilePicture,
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
      confirmPassword: donor.confirmPassword,
      terms: donor.terms,
      profilePicture: donor.profilePicture,
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
      confirmPassword: confirmPassword,
      profilePicture: profilePicture,
      terms: terms ?? false,
    );
  }

  /// Copy with
  DonorModel copyWith({
    String? id,
    String? fullName,
    String? bloodGroup,
    String? dob,
    String? email,
    String? phone,
    String? address,
    String? password,
    String? confirmPassword,
    bool? terms,
    String? profilePicture,
  }) {
    return DonorModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      dob: dob ?? this.dob,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      terms: terms ?? this.terms,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
