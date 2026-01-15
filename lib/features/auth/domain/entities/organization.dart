class Organization {
  final String id;
  final String organizationName;
  final String headOfOrganization;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String password;
  final String? confirmPassword;
  final bool terms;
  final String role;
  final bool isEmailVerified;
  final String? googleId;
  final String? googleProfilePicture;

  Organization({
    required this.id,
    required this.organizationName,
    required this.headOfOrganization,
    required this.email,
    this.phoneNumber,
    this.address,
    required this.password,
    this.confirmPassword,
    this.terms = false,
    this.role = "user",
    this.isEmailVerified = false,
    this.googleId,
    this.googleProfilePicture,
  });
}
