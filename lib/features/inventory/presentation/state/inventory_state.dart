import 'package:raktosewa/features/inventory/domain/entities/blood_inventory.dart';

class InventoryState {
  final bool isLoading;
  final List<BloodInventory> inventoryList;
  final String? error;
  final bool isSuccess;
  final BloodInventory? updatedInventory;

  InventoryState({
    this.isLoading = false,
    this.inventoryList = const [],
    this.error,
    this.isSuccess = false,
    this.updatedInventory,
  });

  InventoryState copyWith({
    bool? isLoading,
    List<BloodInventory>? inventoryList,
    String? error,
    bool? isSuccess,
    BloodInventory? updatedInventory,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      inventoryList: inventoryList ?? this.inventoryList,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
      updatedInventory: updatedInventory,
    );
  }
}
