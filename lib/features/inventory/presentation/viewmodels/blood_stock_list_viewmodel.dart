import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/features/inventory/domain/usecases/get_all_blood_stock_usecase.dart';
import 'package:raktosewa/features/inventory/presentation/state/blood_stock_list_state.dart';
import 'package:raktosewa/features/inventory/data/providers/inventory_providers.dart';

class BloodStockListNotifier extends Notifier<BloodStockListState> {
  late GetAllBloodStockUsecase _getAllBloodStockUsecase;

  @override
  BloodStockListState build() {
    _getAllBloodStockUsecase = ref.read(getAllBloodStockUsecaseProvider);
    return BloodStockListState.initial();
  }

  Future<void> getAllBloodStock(String token) async {
    state = state.copyWith(isLoading: true, hasError: false);

    try {
      final organizations = await _getAllBloodStockUsecase(token);
      state = state.copyWith(
        isLoading: false,
        organizations: organizations,
        hasError: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  void refresh(String token) {
    getAllBloodStock(token);
  }
}
