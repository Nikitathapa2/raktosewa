import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/api/api_client.dart';
import 'package:raktosewa/core/services/storage/token_service.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';

import '../../domain/repositories/organization_dashboard_repository.dart';
import '../../domain/usecases/get_organization_dashboard_stats_usecase.dart';
import '../datasources/organization_dashboard_remote_datasource.dart';
import '../datasources/organization_dashboard_remote_datasource_impl.dart';
import '../repositories/organization_dashboard_repository_impl.dart';

final organizationDashboardRemoteDataSourceProvider =
    Provider<OrganizationDashboardRemoteDataSource>((ref) {
      return OrganizationDashboardRemoteDataSourceImpl(
        apiClient: ref.read(apiClientProvider),
        tokenService: ref.read(tokenServiceProvider),
        userSessionService: ref.read(userSessionServiceProvider),
      );
    });

final organizationDashboardRepositoryProvider =
    Provider<OrganizationDashboardRepository>((ref) {
      return OrganizationDashboardRepositoryImpl(
        remoteDataSource: ref.read(organizationDashboardRemoteDataSourceProvider),
      );
    });

final getOrganizationDashboardStatsUsecaseProvider =
    Provider<GetOrganizationDashboardStatsUsecase>((ref) {
      return GetOrganizationDashboardStatsUsecase(
        ref.read(organizationDashboardRepositoryProvider),
      );
    });
