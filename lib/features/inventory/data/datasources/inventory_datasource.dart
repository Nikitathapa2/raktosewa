import 'package:raktosewa/features/inventory/data/models/blood_inventory_model.dart';
import 'package:raktosewa/features/inventory/data/models/organization_blood_stock_model.dart';

abstract class InventoryDataSource {
  Future<List<BloodInventoryModel>> getInventory(String token);
  Future<List<OrganizationBloodStockModel>> getAllBloodStock(String token);
  Future<BloodInventoryModel> updateInventory({
    required String token,
    required String bloodGroup,
    required int quantity,
    required String operation, // 'add', 'subtract', 'set'
  });
  Future<void> deleteInventory({
    required String token,
    required String bloodGroup,
  });
}
