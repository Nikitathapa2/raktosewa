import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/features/inventory/presentation/viewmodels/blood_stock_list_viewmodel.dart';
import 'package:raktosewa/features/inventory/presentation/state/blood_stock_list_state.dart';

final bloodStockListNotifierProvider =
    NotifierProvider<BloodStockListNotifier, BloodStockListState>(() {
  return BloodStockListNotifier();
});
