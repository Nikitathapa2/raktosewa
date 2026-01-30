import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/api/api_client.dart';
import 'package:raktosewa/core/api/api_endpoints.dart';
import 'package:raktosewa/core/services/storage/token_service.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/data/datasources/organization_remote_datasource.dart';
import 'package:raktosewa/features/auth/data/models/organization_api_model.dart';

// Provider
final organizationUserRemoteProvider = Provider<IOrganizationRemoteDataSource>((ref) {
  return OrganizationUserRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider)
  );
});

class OrganizationUserRemoteDatasource implements IOrganizationRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
    final TokenService _tokenService;


  OrganizationUserRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService,
        _tokenService= tokenService;

  // ✅ API MODEL directly
  @override
  Future<OrganizationApiModel> registerOrganization(OrganizationApiModel organizationModel) async {
    final response = await _apiClient.post(
      ApiEndpoints.organizationRegister,
      data: organizationModel.toJson(),
    );

    if (response.data['success'] == true) {
      final org = OrganizationApiModel.fromJson(response.data['data']);

      final token = response.data['token'] as String? ??
          (response.data['data'] is Map<String, dynamic>
              ? (response.data['data'] as Map<String, dynamic>)['token'] as String?
              : null);
      if (token != null && token.isNotEmpty) {
        await _tokenService.saveToken(token);
      }

      // Save session with address
      await _userSessionService.saveUserSession(
        userId: org.id ?? '',
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

      final token = response.data['token'] as String? ??
          (response.data['data'] is Map<String, dynamic>
              ? (response.data['data'] as Map<String, dynamic>)['token'] as String?
              : null);
      if (token != null && token.isNotEmpty) {
        await _tokenService.saveToken(token);
      }

      // Save session with address
      await _userSessionService.saveUserSession(
        userId: org.id ?? '',
        email: org.email,
        firstName: org.organizationName,
        lastName: '',
        role: UserRole.organization,
        address: org.address,
        phoneNumber: org.phoneNumber
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

   @override
  Future<String> uploadImage(File image) async {
   final fileName = image.path.split('/').last;
   final formData = FormData.fromMap({
     'profilePicture': await MultipartFile.fromFile(image.path, filename: fileName),
   });

   //get token from token service
   final token =  _tokenService.getToken();

   try {
     final response = await _apiClient.post(
       ApiEndpoints.organizationUploadPhoto,
       data: formData,
       options: Options(
         headers: {
           'Authorization': 'Bearer $token',
           'Content-Type': 'multipart/form-data',
         },
       ),
     );
     
     debugPrint('Upload response: ${response.data}');
     
     if (response.data['success'] == true) {
       final data = response.data['data'];
       debugPrint('Upload successful (raw): $data, type: ${data.runtimeType}');
       
       // Extract filename - backend returns full organization object with profilePicture/logo field
       String uploadedUrl = '';
       if (data is String) {
         uploadedUrl = data;
       } else if (data is Map<String, dynamic>) {
         // Try common field names first
         uploadedUrl = data['profilePicture'] ??
                      data['logo'] ??
                      data['filename'] ?? 
                      data['filePath'] ??
                      data['path'] ?? 
                      data['url'] ?? 
                      data['file'] ?? 
                      '';
       } else {
         uploadedUrl = data.toString();
       }
       
       debugPrint('Extracted URL: $uploadedUrl');
       
       if (uploadedUrl.isEmpty) {
         debugPrint('ERROR: uploadedUrl is empty after extraction from data: $data');
         throw Exception('Empty filename from upload response');
       }
       
       // Clean the path: extract just the filename
       // Backend may return: "public\profile_pictures\filename.jpg" or "public/profile_pictures/filename.jpg"
       String cleanedFilename = uploadedUrl
           .replaceAll('\\', '/')  // Normalize backslashes to forward slashes
           .split('/')             // Split by path separator
           .where((part) => part.isNotEmpty)  // Filter empty parts
           .toList()
           .last;                  // Get just the filename
       
       debugPrint('Cleaned filename: $cleanedFilename');
       return cleanedFilename;
     }
     
     throw Exception(response.data['message'] ?? 'Upload failed');
   } catch (e) {
     debugPrint('Error uploading image: $e');
     throw Exception('Error uploading image: $e');
   }
  }
}
