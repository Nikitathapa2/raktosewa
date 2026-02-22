import '../entities/organization_dashboard_stats.dart';

abstract class OrganizationDashboardRepository {
  Future<OrganizationDashboardStats> getDashboardStats();
}
