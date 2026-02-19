import 'package:raktosewa/features/inventory/domain/entities/organization_blood_stock.dart';
import 'package:raktosewa/features/inventory/domain/repositories/inventory_repository.dart';

class GetAllBloodStockUsecase {
  final InventoryRepository repository;

  GetAllBloodStockUsecase(this.repository);

  Future<List<OrganizationBloodStock>> call(String token) async {
    return await repository.getAllBloodStock(token);
  }
}
