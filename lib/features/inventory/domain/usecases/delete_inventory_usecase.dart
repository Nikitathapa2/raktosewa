import 'package:raktosewa/features/inventory/domain/repositories/inventory_repository.dart';

class DeleteInventoryUsecase {
  final InventoryRepository repository;

  DeleteInventoryUsecase({required this.repository});

  Future<void> call({
    required String token,
    required String bloodGroup,
  }) async {
    await repository.deleteInventory(
      token: token,
      bloodGroup: bloodGroup,
    );
  }
}
