import 'package:raktosewa/features/inventory/domain/entities/blood_inventory.dart';

class BloodInventoryModel extends BloodInventory {
  BloodInventoryModel({
    required super.id,
    required super.organization,
    required super.bloodGroup,
    required super.quantity,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BloodInventoryModel.fromJson(Map<String, dynamic> json) {
    // Handle organization field - can be String (ID) or Object (populated)
    String organizationId = '';
    if (json['organization'] != null) {
      if (json['organization'] is String) {
        organizationId = json['organization'];
      } else if (json['organization'] is Map) {
        organizationId = json['organization']['_id'] ?? '';
      }
    }
    
    return BloodInventoryModel(
      id: json['_id'] ?? '',
      organization: organizationId,
      bloodGroup: json['bloodGroup'] ?? '',
      quantity: json['quantity'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'organization': organization,
      'bloodGroup': bloodGroup,
      'quantity': quantity,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BloodInventory toEntity() {
    return BloodInventory(
      id: id,
      organization: organization,
      bloodGroup: bloodGroup,
      quantity: quantity,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
