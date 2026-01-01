class Donor {
  final String id; // Unique ID for donor
  final String fullName;
  final String bloodGroup;
  final String dob;
  final String email;
  final String phone;
  final String address;
  final String password; // Store hashed password in real app

  Donor({
    required this.id,
    required this.fullName,
    required this.bloodGroup,
    required this.dob,
    required this.email,
    required this.phone,
    required this.address,
    required this.password,
  });
}
