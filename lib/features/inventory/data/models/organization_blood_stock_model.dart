import 'package:raktosewa/features/inventory/domain/entities/organization_blood_stock.dart';

class BloodStockItemModel extends BloodStockItem {
  BloodStockItemModel({
    required super.bloodGroup,
    required super.quantity,
  });

  factory BloodStockItemModel.fromJson(Map<String, dynamic> json) {
    return BloodStockItemModel(
      bloodGroup: json['bloodGroup'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bloodGroup': bloodGroup,
      'quantity': quantity,
    };
  }
}

class OrganizationInfoModel extends OrganizationInfo {
  OrganizationInfoModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phoneNumber,
    required super.address,
  });

  factory OrganizationInfoModel.fromJson(Map<String, dynamic> json) {
    return OrganizationInfoModel(
      id: json['_id'] ?? '',
      name: json['organizationName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'organizationName': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
    };
  }
}

class OrganizationBloodStockModel extends OrganizationBloodStock {
  OrganizationBloodStockModel({
    required super.organization,
    required super.bloodStock,
    required super.totalUnits,
  });

  factory OrganizationBloodStockModel.fromJson(Map<String, dynamic> json) {
    return OrganizationBloodStockModel(
      organization: OrganizationInfoModel.fromJson(json['organization'] ?? {}),
      bloodStock: (json['bloodStock'] as List<dynamic>?)
              ?.map((item) => BloodStockItemModel.fromJson(item))
              .toList() ??
          [],
      totalUnits: json['totalUnits'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organization': (organization as OrganizationInfoModel).toJson(),
      'bloodStock': bloodStock
          .map((item) => (item as BloodStockItemModel).toJson())
          .toList(),
      'totalUnits': totalUnits,
    };
  }
}
