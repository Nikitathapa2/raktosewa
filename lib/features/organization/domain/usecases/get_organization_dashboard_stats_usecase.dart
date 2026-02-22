import '../entities/organization_dashboard_stats.dart';
import '../repositories/organization_dashboard_repository.dart';

class GetOrganizationDashboardStatsUsecase {
  final OrganizationDashboardRepository repository;

  GetOrganizationDashboardStatsUsecase(this.repository);

  Future<OrganizationDashboardStats> call() {
    return repository.getDashboardStats();
  }
}
