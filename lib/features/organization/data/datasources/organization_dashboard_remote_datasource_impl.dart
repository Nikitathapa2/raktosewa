import 'package:dio/dio.dart';
import 'package:raktosewa/core/api/api_client.dart';
import 'package:raktosewa/core/api/api_endpoints.dart';
import 'package:raktosewa/core/services/storage/token_service.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';

import '../models/organization_dashboard_stats_model.dart';
import 'organization_dashboard_remote_datasource.dart';

class OrganizationDashboardRemoteDataSourceImpl
    implements OrganizationDashboardRemoteDataSource {
  final ApiClient apiClient;
  final TokenService tokenService;
  final UserSessionService userSessionService;

  OrganizationDashboardRemoteDataSourceImpl({
    required this.apiClient,
    required this.tokenService,
    required this.userSessionService,
  });

  @override
  Future<OrganizationDashboardStatsModel> getDashboardStats() async {
    final token = tokenService.getToken();
    final userId = userSessionService.getCurrentUserId();

    if (token == null || token.isEmpty || userId == null || userId.isEmpty) {
      throw Exception('Unauthorized: missing session/token');
    }

    final response = await apiClient.get(
      ApiEndpoints.organizationDashboardStats,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    final payload = response.data;

    if (payload is Map<String, dynamic> && payload['success'] == true) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return OrganizationDashboardStatsModel.fromJson(data);
      }
      throw Exception('Invalid dashboard stats payload');
    }

    throw Exception(
      (payload is Map<String, dynamic>)
          ? (payload['message'] ?? 'Failed to fetch dashboard stats')
          : 'Failed to fetch dashboard stats',
    );
  }
}
