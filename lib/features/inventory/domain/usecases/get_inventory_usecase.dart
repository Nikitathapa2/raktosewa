import 'package:raktosewa/features/inventory/domain/entities/blood_inventory.dart';
import 'package:raktosewa/features/inventory/domain/repositories/inventory_repository.dart';

class GetInventoryUsecase {
  final InventoryRepository repository;

  GetInventoryUsecase({required this.repository});

  Future<List<BloodInventory>> call(String token) async {
    return await repository.getInventory(token);
  }
}
