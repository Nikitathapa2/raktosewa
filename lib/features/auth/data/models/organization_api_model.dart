import '../../domain/entities/organization.dart';

class OrganizationApiModel {
  final String? id;
  final String organizationName;
  final String headOfOrganization;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? password;
  final String? confirmPassword;
  final bool terms;
  final String role;
  final bool isEmailVerified;
  final String? googleId;
  final String? googleProfilePicture;

  OrganizationApiModel({
    this.id,
    required this.organizationName,
    required this.headOfOrganization,
    required this.email,
    this.phoneNumber,
    this.address,
    this.password,
    this.confirmPassword,
    this.terms = false,
    this.role = "user",
    this.isEmailVerified = false,
    this.googleId,
    this.googleProfilePicture,
  });

  // ================= JSON → MODEL =================
  factory OrganizationApiModel.fromJson(Map<String, dynamic> json) {
    return OrganizationApiModel(
      id: json['_id'] as String?,
      organizationName: json['organizationName'] as String,
      headOfOrganization: json['headOfOrganization'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      role: json['role'] as String? ?? "user",
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      googleId: json['googleId'] as String?,
      googleProfilePicture: json['googleProfilePicture'] as String?,
      terms: json['terms'] as bool? ?? false,
    );
  }

  // ================= MODEL → JSON =================
  Map<String, dynamic> toJson() {
    final json = {
      "organizationName": organizationName,
      "headOfOrganization": headOfOrganization,
      "email": email,
      "role": role,
      "isEmailVerified": isEmailVerified,
      "terms": terms,
    };

    if (phoneNumber != null) json["phoneNumber"] = phoneNumber!;
    if (address != null) json["address"] = address!;
    if (password != null) json["password"] = password!;
    if (confirmPassword != null) json["confirmPassword"] = confirmPassword!;
    if (googleId != null) json["googleId"] = googleId!;
    if (googleProfilePicture != null) json["googleProfilePicture"] = googleProfilePicture!;

    return json;
  }

  // ================= MODEL → ENTITY =================
  Organization toEntity() {
    return Organization(
      id: id ?? '',
      organizationName: organizationName,
      headOfOrganization: headOfOrganization,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      password: password ?? '',
      confirmPassword: confirmPassword,
      terms: terms,
      role: role,
      isEmailVerified: isEmailVerified,
      googleId: googleId,
      googleProfilePicture: googleProfilePicture,
    );
  }

  // ================= ENTITY → MODEL =================
  factory OrganizationApiModel.fromEntity(Organization organization) {
    return OrganizationApiModel(
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

  /// Copy with
  OrganizationApiModel copyWith({
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
    return OrganizationApiModel(
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
