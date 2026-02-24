import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/user_aware_providers.dart';
import 'package:raktosewa/features/inventory/domain/usecases/delete_inventory_usecase.dart';
import 'package:raktosewa/features/inventory/domain/usecases/get_inventory_usecase.dart';
import 'package:raktosewa/features/inventory/domain/usecases/update_inventory_usecase.dart';
import 'package:raktosewa/features/inventory/presentation/state/inventory_state.dart';
import 'package:raktosewa/features/inventory/data/providers/inventory_providers.dart' as data_providers;

class InventoryNotifier extends Notifier<InventoryState> {
  late GetInventoryUsecase _getInventoryUsecase;
  late UpdateInventoryUsecase _updateInventoryUsecase;
  late DeleteInventoryUsecase _deleteInventoryUsecase;

  @override
  InventoryState build() {
    _getInventoryUsecase = ref.read(data_providers.getInventoryUsecaseProvider);
    _updateInventoryUsecase = ref.read(data_providers.updateInventoryUsecaseProvider);
    _deleteInventoryUsecase = ref.read(data_providers.deleteInventoryUsecaseProvider);
    return InventoryState();
  }

  Future<void> fetchInventory(String token) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final inventoryList = await _getInventoryUsecase(token);
      state = state.copyWith(
        isLoading: false,
        inventoryList: inventoryList,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateInventory({
    required String token,
    required String bloodGroup,
    required int quantity,
    required String operation,
  }) async {
    // Reset state
    state = state.copyWith(
      isLoading: false,
      isSuccess: false,
      updatedInventory: null,
      error: null,
    );

    state = state.copyWith(isLoading: true);
    try {
      final updatedInventory = await _updateInventoryUsecase(
        token: token,
        bloodGroup: bloodGroup,
        quantity: quantity,
        operation: operation,
      );
      
      // Refresh inventory list
      await fetchInventory(token);
      
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        updatedInventory: updatedInventory,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isSuccess: false,
      );
    }
  }

  Future<void> deleteInventory({
    required String token,
    required String bloodGroup,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _deleteInventoryUsecase(
        token: token,
        bloodGroup: bloodGroup,
      );
      
      // Refresh inventory list
      await fetchInventory(token);
      
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void resetState() {
    state = state.copyWith(
      isSuccess: false,
      error: null,
      updatedInventory: null,
    );
  }
}
