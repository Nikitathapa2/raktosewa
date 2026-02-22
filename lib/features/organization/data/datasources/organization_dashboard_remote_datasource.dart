import '../models/organization_dashboard_stats_model.dart';

abstract class OrganizationDashboardRemoteDataSource {
  Future<OrganizationDashboardStatsModel> getDashboardStats();
}
