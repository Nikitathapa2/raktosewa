class Donor {
  final String id; // Unique ID for donor
  final String fullName;
  final String bloodGroup;
  final String? dob;
  final String email;
  final String? phone;
  final String? address;
  final String password; // Store hashed password in real app
  final String? confirmPassword;
  final bool terms;

  Donor({
    required this.id,
    required this.fullName,
    required this.bloodGroup,
    this.dob,
    required this.email,
    this.phone,
    this.address,
    required this.password,
    this.confirmPassword,
    this.terms = false,
  });
}
