import '../../domain/entities/organization_dashboard_stats.dart';

class OrganizationDashboardStatsState {
  final bool isLoading;
  final String? error;
  final OrganizationDashboardStats? stats;

  const OrganizationDashboardStatsState({
    this.isLoading = false,
    this.error,
    this.stats,
  });

  OrganizationDashboardStatsState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    OrganizationDashboardStats? stats,
  }) {
    return OrganizationDashboardStatsState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      stats: stats ?? this.stats,
    );
  }
}
