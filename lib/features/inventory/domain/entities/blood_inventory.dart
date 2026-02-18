class BloodInventory {
  final String id;
  final String organization;
  final String bloodGroup;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;

  BloodInventory({
    required this.id,
    required this.organization,
    required this.bloodGroup,
    required this.quantity,
    required this.createdAt,
    required this.updatedAt,
  });
}
