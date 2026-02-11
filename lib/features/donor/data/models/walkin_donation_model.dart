import '../../domain/entities/walkin_donation.dart';

class WalkinDonationModel extends WalkinDonation {
  WalkinDonationModel({
    String? id,
    required String organization,
    required String donorName,
    required String phoneNumber,
    required int age,
    required String bloodGroup,
    required String gender,
    required int unitsdonated,
    String? notes,
    DateTime? donationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super(
          id: id,
          organization: organization,
          donorName: donorName,
          phoneNumber: phoneNumber,
          age: age,
          bloodGroup: bloodGroup,
          gender: gender,
          unitsdonated: unitsdonated,
          notes: notes,
          donationDate: donationDate,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Convert from JSON (API response)
  factory WalkinDonationModel.fromJson(Map<String, dynamic> json) {
    return WalkinDonationModel(
      id: json['_id'] ?? json['id'],
      organization: json['organization'] ?? '',
      donorName: json['walkinDonor']?['name'] ?? json['donorName'] ?? '',
      phoneNumber: json['walkinDonor']?['phone'] ?? json['phoneNumber'] ?? '',
      age: json['walkinDonor']?['age'] ?? json['age'] ?? 0,
      bloodGroup: json['bloodGroup'] ?? '',
      gender: json['walkinDonor']?['gender'] ?? json['gender'] ?? '',
      unitsdonated: json['units'] ?? 0,
      notes: json['notes'],
      donationDate: json['donationDate'] != null
          ? DateTime.parse(json['donationDate'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  /// Convert to JSON (for API request)
  Map<String, dynamic> toJson() {
    return {
      'walkinDonor': {
        'name': donorName,
        'phone': phoneNumber,
        'age': age,
        'bloodGroup': bloodGroup,
        'gender': gender,
      },
      'bloodGroup': bloodGroup,
      'units': unitsdonated,
      if (notes != null) 'notes': notes,
    };
  }

  /// Convert from Entity
  factory WalkinDonationModel.fromEntity(WalkinDonation donation) {
    return WalkinDonationModel(
      id: donation.id,
      organization: donation.organization,
      donorName: donation.donorName,
      phoneNumber: donation.phoneNumber,
      age: donation.age,
      bloodGroup: donation.bloodGroup,
      gender: donation.gender,
      unitsdonated: donation.unitsdonated,
      notes: donation.notes,
      donationDate: donation.donationDate,
      createdAt: donation.createdAt,
      updatedAt: donation.updatedAt,
    );
  }

  /// Convert to Entity
  WalkinDonation toEntity() {
    return WalkinDonation(
      id: id,
      organization: organization,
      donorName: donorName,
      phoneNumber: phoneNumber,
      age: age,
      bloodGroup: bloodGroup,
      gender: gender,
      unitsdonated: unitsdonated,
      notes: notes,
      donationDate: donationDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
