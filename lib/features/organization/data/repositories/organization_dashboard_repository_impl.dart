import '../../domain/entities/organization_dashboard_stats.dart';
import '../../domain/repositories/organization_dashboard_repository.dart';
import '../datasources/organization_dashboard_remote_datasource.dart';

class OrganizationDashboardRepositoryImpl
    implements OrganizationDashboardRepository {
  final OrganizationDashboardRemoteDataSource remoteDataSource;

  OrganizationDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<OrganizationDashboardStats> getDashboardStats() async {
    final model = await remoteDataSource.getDashboardStats();
    return model.toEntity();
  }
}
