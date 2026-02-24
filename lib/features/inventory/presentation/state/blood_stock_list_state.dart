import 'package:raktosewa/features/inventory/domain/entities/organization_blood_stock.dart';

class BloodStockListState {
  final List<OrganizationBloodStock> organizations;
  final bool isLoading;
  final bool hasError;
  final String errorMessage;

  BloodStockListState({
    required this.organizations,
    required this.isLoading,
    required this.hasError,
    required this.errorMessage,
  });

  factory BloodStockListState.initial() {
    return BloodStockListState(
      organizations: [],
      isLoading: false,
      hasError: false,
      errorMessage: '',
    );
  }

  BloodStockListState copyWith({
    List<OrganizationBloodStock>? organizations,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return BloodStockListState(
      organizations: organizations ?? this.organizations,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
