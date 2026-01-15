import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/api/api_client.dart';
import 'package:raktosewa/core/api/api_endpoints.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/data/datasources/organization_remote_datasource.dart';
import 'package:raktosewa/features/auth/data/models/organization_api_model.dart';

// Provider
final organizationUserRemoteProvider = Provider<IOrganizationRemoteDataSource>((ref) {
  return OrganizationUserRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class OrganizationUserRemoteDatasource implements IOrganizationRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  OrganizationUserRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService;

  // ✅ API MODEL directly
  @override
  Future<OrganizationApiModel> registerOrganization(OrganizationApiModel organizationModel) async {
    final response = await _apiClient.post(
      ApiEndpoints.organizationRegister,
      data: organizationModel.toJson(),
    );

    if (response.data['success'] == true) {
      final org = OrganizationApiModel.fromJson(response.data['data']);

      // Save session with address
      await _userSessionService.saveUserSession(
        userId: org.id!,
        email: org.email,
        firstName: org.organizationName,
        lastName: '',
        role: UserRole.organization,
        address: org.address,
      );

      return org;
    }

    throw Exception(response.data['message'] ?? 'Registration failed');
  }

  @override
  Future<OrganizationApiModel> loginOrganization(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.organizationLogin,
      data: {
        "email": email,
        "password": password,
      },
    );

    if (response.data['success'] == true) {
      final org = OrganizationApiModel.fromJson(response.data['data']);

      // Save session with address
      await _userSessionService.saveUserSession(
        userId: org.id!,
        email: org.email,
        firstName: org.organizationName,
        lastName: '',
        role: UserRole.organization,
        address: org.address,
      );

      return org;
    }

    throw Exception(response.data['message'] ?? 'Login failed');
  }

  @override
  Future<OrganizationApiModel?> getOrganizationById(String id) async {
    final response =
        await _apiClient.get('${ApiEndpoints.organizationRegister}/$id');

    if (response.data['success'] == true) {
      return OrganizationApiModel.fromJson(response.data['data']);
    }
    return null;
  }

  @override
  Future<bool> updateOrganization(OrganizationApiModel organizationModel) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteOrganization(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> logout() async {
    await _userSessionService.clearSession();
    return true;
  }
}
