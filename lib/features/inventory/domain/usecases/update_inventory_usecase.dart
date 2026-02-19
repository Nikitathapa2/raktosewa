import 'package:raktosewa/features/inventory/domain/entities/blood_inventory.dart';
import 'package:raktosewa/features/inventory/domain/repositories/inventory_repository.dart';

class UpdateInventoryUsecase {
  final InventoryRepository repository;

  UpdateInventoryUsecase({required this.repository});

  Future<BloodInventory> call({
    required String token,
    required String bloodGroup,
    required int quantity,
    required String operation, // 'add', 'subtract', 'set'
  }) async {
    return await repository.updateInventory(
      token: token,
      bloodGroup: bloodGroup,
      quantity: quantity,
      operation: operation,
    );
  }
}
