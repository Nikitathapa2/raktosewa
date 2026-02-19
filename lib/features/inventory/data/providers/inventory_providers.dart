import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:raktosewa/features/inventory/data/datasources/inventory_datasource.dart';
import 'package:raktosewa/features/inventory/data/datasources/inventory_remote_datasource_impl.dart';
import 'package:raktosewa/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:raktosewa/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:raktosewa/features/inventory/domain/usecases/get_inventory_usecase.dart';
import 'package:raktosewa/features/inventory/domain/usecases/get_all_blood_stock_usecase.dart';
import 'package:raktosewa/features/inventory/domain/usecases/update_inventory_usecase.dart';
import 'package:raktosewa/features/inventory/domain/usecases/delete_inventory_usecase.dart';

// DataSource provider
final inventoryDataSourceProvider = Provider<InventoryDataSource>((ref) {
  return InventoryRemoteDataSourceImpl(client: http.Client());
});

// Repository provider
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  return InventoryRepositoryImpl(
    dataSource: ref.read(inventoryDataSourceProvider),
  );
});

// Usecase providers
final getInventoryUsecaseProvider = Provider<GetInventoryUsecase>((ref) {
  return GetInventoryUsecase(
    repository: ref.read(inventoryRepositoryProvider),
  );
});

final getAllBloodStockUsecaseProvider = Provider<GetAllBloodStockUsecase>((ref) {
  return GetAllBloodStockUsecase(
    ref.read(inventoryRepositoryProvider),
  );
});

final updateInventoryUsecaseProvider = Provider<UpdateInventoryUsecase>((ref) {
  return UpdateInventoryUsecase(
    repository: ref.read(inventoryRepositoryProvider),
  );
});

final deleteInventoryUsecaseProvider = Provider<DeleteInventoryUsecase>((ref) {
  return DeleteInventoryUsecase(
    repository: ref.read(inventoryRepositoryProvider),
  );
});
