import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/api/api_client.dart';

import 'package:raktosewa/core/api/api_endpoints.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/data/datasources/donor_datasource.dart';
import 'package:raktosewa/features/auth/data/models/donor_api_model.dart';
import 'package:raktosewa/features/auth/domain/entities/donor.dart';

// Provider
final donorUserRemoteProvider = Provider<IDonorRemoteDataSource>((ref) {
  return DonorUserRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
  );
});

class DonorUserRemoteDatasource implements IDonorRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;

  DonorUserRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService;

  // ✅ API MODEL directly
  @override
  Future<DonorApiModel> registerDonor(DonorApiModel donorModel) async {
    final response = await _apiClient.post(
      ApiEndpoints.donorRegister,
      data: donorModel.toJson(),
    );

    if (response.data['success'] == true) {
      final user = DonorApiModel.fromJson(response.data['data']);

      // Save session with address
      final name = user.fullName.trim();
      final parts = name.split(' ');
      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        firstName: parts.first,
        lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
        role: UserRole.donor,
        address: user.address,
      );

      return user;
    }

    throw Exception(response.data['message'] ?? 'Registration failed');
  }

  @override
  Future<DonorApiModel> loginDonor(String email, String password) async {
    final response = await _apiClient.post(
      ApiEndpoints.donorLogin,
      data: {
        "email": email,
        "password": password,
      },
    );

    if (response.data['success'] == true) {
      final user = DonorApiModel.fromJson(response.data['data']);

      // Save session with address
      final name = user.fullName.trim();
      final parts = name.split(' ');

      await _userSessionService.saveUserSession(
        userId: user.id!,
        email: user.email,
        firstName: parts.first,
        lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
        role: UserRole.donor,
        address: user.address,
      );

      return user;
    }

    throw Exception(response.data['message'] ?? 'Login failed');
  }

  @override
  Future<DonorApiModel?> getDonorById(String id) async {
    final response =
        await _apiClient.get('${ApiEndpoints.donorRegister}/$id');

    if (response.data['success'] == true) {
      return DonorApiModel.fromJson(response.data['data']);
    }
    return null;
  }

  @override
  Future<bool> updateDonor(DonorApiModel donorModel) async {
    // final response = await _apiClient.put(
    //   '${ApiEndpoints.donorRegister}/${donorModel.id}',
    //   data: donorModel.toJson(),
    // );

    // return response.data['success'] == true;
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteDonor(String id) async {
    // final response =
    //     await _apiClient.delete('${ApiEndpoints.donorRegister}/$id');

    // return response.data['success'] == true;
    throw UnimplementedError();
  }

  @override
  Future<bool> logout() async {
    await _userSessionService.clearSession();
    return true;
  }
}
