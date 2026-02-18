class BloodStockItem {
  final String bloodGroup;
  final int quantity;

  BloodStockItem({
    required this.bloodGroup,
    required this.quantity,
  });
}

class OrganizationInfo {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;

  OrganizationInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
  });
}

class OrganizationBloodStock {
  final OrganizationInfo organization;
  final List<BloodStockItem> bloodStock;
  final int totalUnits;

  OrganizationBloodStock({
    required this.organization,
    required this.bloodStock,
    required this.totalUnits,
  });
}
