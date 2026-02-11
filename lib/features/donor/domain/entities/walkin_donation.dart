class WalkinDonation {
  final String? id;
  final String organization;
  final String donorName;
  final String phoneNumber;
  final int age;
  final String bloodGroup;
  final String gender;
  final int unitsdonated;
  final String? notes;
  final DateTime? donationDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WalkinDonation({
    this.id,
    required this.organization,
    required this.donorName,
    required this.phoneNumber,
    required this.age,
    required this.bloodGroup,
    required this.gender,
    required this.unitsdonated,
    this.notes,
    this.donationDate,
    this.createdAt,
    this.updatedAt,
  });

  WalkinDonation copyWith({
    String? id,
    String? organization,
    String? donorName,
    String? phoneNumber,
    int? age,
    String? bloodGroup,
    String? gender,
    int? unitsdonated,
    String? notes,
    DateTime? donationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalkinDonation(
      id: id ?? this.id,
      organization: organization ?? this.organization,
      donorName: donorName ?? this.donorName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      gender: gender ?? this.gender,
      unitsdonated: unitsdonated ?? this.unitsdonated,
      notes: notes ?? this.notes,
      donationDate: donationDate ?? this.donationDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
