import 'package:hive/hive.dart';
import '../../domain/entities/organization.dart';

part 'organization_model.g.dart';

@HiveType(typeId: 1)
class OrganizationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String organizationName;

  @HiveField(2)
  final String headOfOrganization;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String? phoneNumber;

  @HiveField(5)
  final String? address;

  @HiveField(6)
  final String password;

  @HiveField(7)
  final String? confirmPassword;

  @HiveField(8)
  final bool? terms;

  @HiveField(9)
  final String? role;

  @HiveField(10)
  final bool? isEmailVerified;

  @HiveField(11)
  final String? googleId;

  @HiveField(12)
  final String? googleProfilePicture;

  OrganizationModel({
    required this.id,
    required this.organizationName,
    required this.headOfOrganization,
    required this.email,
    this.phoneNumber,
    this.address,
    required this.password,
    this.confirmPassword,
    this.terms,
    this.role,
    this.isEmailVerified,
    this.googleId,
    this.googleProfilePicture,
  });

  factory OrganizationModel.fromEntity(Organization organization) {
    return OrganizationModel(
      id: organization.id,
      organizationName: organization.organizationName,
      headOfOrganization: organization.headOfOrganization,
      email: organization.email,
      phoneNumber: organization.phoneNumber,
      address: organization.address,
      password: organization.password,
      confirmPassword: organization.confirmPassword,
      terms: organization.terms,
      role: organization.role,
      isEmailVerified: organization.isEmailVerified,
      googleId: organization.googleId,
      googleProfilePicture: organization.googleProfilePicture,
    );
  }

  Organization toEntity() {
    return Organization(
      id: id,
      organizationName: organizationName,
      headOfOrganization: headOfOrganization,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      password: password,
      confirmPassword: confirmPassword,
      terms: terms ?? false,
      role: role ?? "user",
      isEmailVerified: isEmailVerified ?? false,
      googleId: googleId,
      googleProfilePicture: googleProfilePicture,
    );
  }

  /// Copy with
  OrganizationModel copyWith({
    String? id,
    String? organizationName,
    String? headOfOrganization,
    String? email,
    String? phoneNumber,
    String? address,
    String? password,
    String? confirmPassword,
    bool? terms,
    String? role,
    bool? isEmailVerified,
    String? googleId,
    String? googleProfilePicture,
  }) {
    return OrganizationModel(
      id: id ?? this.id,
      organizationName: organizationName ?? this.organizationName,
      headOfOrganization: headOfOrganization ?? this.headOfOrganization,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      terms: terms ?? this.terms,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      googleId: googleId ?? this.googleId,
      googleProfilePicture: googleProfilePicture ?? this.googleProfilePicture,
    );
  }
}
