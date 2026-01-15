import '../../domain/entities/donor.dart';

class DonorApiModel {
  final String? id;
  final String fullName;
  final String bloodGroup;
  final String? dob;
  final String email;
  final String? phone;
  final String? address;
  final String? password;
  final String? confirmPassword;
  final bool terms;

  DonorApiModel({
    this.id,
    required this.fullName,
    required this.bloodGroup,
    this.dob,
    required this.email,
    this.phone,
    this.address,
    this.password,
    this.confirmPassword,
    this.terms = false,
  });

  // ================= JSON → MODEL =================
  factory DonorApiModel.fromJson(Map<String, dynamic> json) {
    return DonorApiModel(
      id: json['_id'] as String?,
      fullName: json['fullName'] as String,
      bloodGroup: json['bloodGroup'] as String,
      dob: json['dob'] as String?,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      terms: json['terms'] as bool? ?? false,
    );
  }

  // ================= MODEL → JSON =================
  Map<String, dynamic> toJson() {
    final json = {
      "fullName": fullName,
      "bloodGroup": bloodGroup,
      "email": email,
      "terms": terms,
    };
    
    if (dob != null) json["dob"] = dob!;
    if (phone != null) json["phone"] = phone!;
    if (address != null) json["address"] = address!;
    if (password != null) json["password"] = password!;
    if (confirmPassword != null) json["confirmPassword"] = confirmPassword!;
    
    return json;
  }

  // ================= MODEL → ENTITY =================
  Donor toEntity() {
    return Donor(
      id: id ?? '',
      fullName: fullName,
      bloodGroup: bloodGroup,
      dob: dob,
      email: email,
      phone: phone,
      address: address,
      password: password ?? '',
      confirmPassword: confirmPassword,
      terms: terms,
    );
  }

  // ================= ENTITY → MODEL =================
  factory DonorApiModel.fromEntity(Donor donor) {
    return DonorApiModel(
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
    );
  }
}
