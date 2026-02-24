import 'package:raktosewa/features/inventory/domain/entities/blood_inventory.dart';
import 'package:raktosewa/features/inventory/domain/entities/organization_blood_stock.dart';

abstract class InventoryRepository {
  Future<List<BloodInventory>> getInventory(String token);
  Future<List<OrganizationBloodStock>> getAllBloodStock(String token);
  Future<BloodInventory> updateInventory({
    required String token,
    required String bloodGroup,
    required int quantity,
    required String operation,
  });
  Future<void> deleteInventory({
    required String token,
    required String bloodGroup,
  });
}
