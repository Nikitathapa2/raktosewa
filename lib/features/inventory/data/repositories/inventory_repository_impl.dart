import 'package:raktosewa/features/inventory/data/datasources/inventory_datasource.dart';
import 'package:raktosewa/features/inventory/domain/entities/blood_inventory.dart';
import 'package:raktosewa/features/inventory/domain/entities/organization_blood_stock.dart';
import 'package:raktosewa/features/inventory/domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryDataSource dataSource;

  InventoryRepositoryImpl({required this.dataSource});

  @override
  Future<List<BloodInventory>> getInventory(String token) async {
    final models = await dataSource.getInventory(token);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<OrganizationBloodStock>> getAllBloodStock(String token) async {
    return await dataSource.getAllBloodStock(token);
  }

  @override
  Future<BloodInventory> updateInventory({
    required String token,
    required String bloodGroup,
    required int quantity,
    required String operation,
  }) async {
    final model = await dataSource.updateInventory(
      token: token,
      bloodGroup: bloodGroup,
      quantity: quantity,
      operation: operation,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteInventory({
    required String token,
    required String bloodGroup,
  }) async {
    await dataSource.deleteInventory(
      token: token,
      bloodGroup: bloodGroup,
    );
  }
}
