import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/api/api_client.dart';

import 'package:raktosewa/core/api/api_endpoints.dart';
import 'package:raktosewa/core/services/storage/token_service.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/data/datasources/donor_datasource.dart';
import 'package:raktosewa/features/auth/data/models/donor_api_model.dart';

// Provider
final donorUserRemoteProvider = Provider<IDonorRemoteDataSource>((ref) {
  return DonorUserRemoteDatasource(
    apiClient: ref.read(apiClientProvider),
    userSessionService: ref.read(userSessionServiceProvider),
    tokenService: ref.read(tokenServiceProvider)
  );
});

class DonorUserRemoteDatasource implements IDonorRemoteDataSource {
  final ApiClient _apiClient;
  final UserSessionService _userSessionService;
      final TokenService _tokenService;


  DonorUserRemoteDatasource({
    required ApiClient apiClient,
    required UserSessionService userSessionService,
    required TokenService tokenService,
  })  : _apiClient = apiClient,
        _userSessionService = userSessionService,
        _tokenService=tokenService;

  // ✅ API MODEL directly
  @override
  Future<DonorApiModel> registerDonor(DonorApiModel donorModel) async {
    final response = await _apiClient.post(
      ApiEndpoints.donorRegister,
      data: donorModel.toJson(),
    );

    if (response.data['success'] == true) {
      final user = DonorApiModel.fromJson(response.data['data']);

      // Save auth token if provided
      final token = response.data['token'] as String? ??
          (response.data['data'] is Map<String, dynamic>
              ? (response.data['data'] as Map<String, dynamic>)['token'] as String?
              : null);
      if (token != null && token.isNotEmpty) {
        await _tokenService.saveToken(token);
      }

      // Save session with address
      final name = user.fullName.trim();
      final parts = name.split(' ');
      await _userSessionService.saveUserSession(
        userId: user.id ?? '',
        email: user.email,
        firstName: parts.first,
        lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
        role: UserRole.donor,
        address: user.address,
        phoneNumber: user.phone
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

      final token = response.data['token'] as String? ??
          (response.data['data'] is Map<String, dynamic>
              ? (response.data['data'] as Map<String, dynamic>)['token'] as String?
              : null);
      if (token != null && token.isNotEmpty) {
        await _tokenService.saveToken(token);
      }

      // Save session with address
      final name = user.fullName.trim();
      final parts = name.split(' ');

      await _userSessionService.saveUserSession(
        userId: user.id ?? '',
        email: user.email,
        firstName: parts.first,
        lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
        role: UserRole.donor,
        address: user.address,
        profilePicture: user.profilePicture,
        phoneNumber: user.phone
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
       ApiEndpoints.donorUploadPhoto,
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
       
       // Extract filename - backend returns full donor object with profilePicture field
       String uploadedUrl = '';
       if (data is String) {
         uploadedUrl = data;
       } else if (data is Map<String, dynamic>) {
         // Try common field names first
         uploadedUrl = data['profilePicture'] ??
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
