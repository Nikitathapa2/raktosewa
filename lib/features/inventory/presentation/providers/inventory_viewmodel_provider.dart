import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/features/inventory/presentation/state/inventory_state.dart';
import 'package:raktosewa/features/inventory/presentation/viewmodels/inventory_viewmodel.dart';

final inventoryViewModelProvider = NotifierProvider<InventoryNotifier, InventoryState>(() {
  return InventoryNotifier();
});
