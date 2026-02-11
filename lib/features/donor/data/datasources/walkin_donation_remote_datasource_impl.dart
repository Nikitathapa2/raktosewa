import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../models/walkin_donation_model.dart';
import 'walkin_donation_datasource.dart';

class WalkinDonationRemoteDataSourceImpl implements IWalkinDonationRemoteDataSource {
  final http.Client client;
  final String baseUrl = ApiEndpoints.baseUrl;
  String? _token;

  WalkinDonationRemoteDataSourceImpl({
    required this.client,
    String? token,
  }) : _token = token;

  void setToken(String token) {
    _token = token;
  }

  @override
  Future<WalkinDonationModel> registerWalkinDonation(
    String organizationId,
    WalkinDonationModel donation,
  ) async {
    final url = Uri.parse('$baseUrl${ApiEndpoints.registerWalkinDonation}');
    
    print('🩸 [DEBUG] Registering walk-in donation');
    print('🩸 [DEBUG] URL: $url');
    print('🩸 [DEBUG] Organization ID: $organizationId');
    print('🩸 [DEBUG] Token available: ${_token != null}');
    print('🩸 [DEBUG] Donation data: ${jsonEncode(donation.toJson())}');
    
    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(donation.toJson()),
      );

      print('🩸 [DEBUG] Response status code: ${response.statusCode}');
      print('🩸 [DEBUG] Response body: ${response.body}');

      if (response.statusCode == 201) {
        print('🩸 [DEBUG] ✅ Walk-in donation registered successfully');
        final jsonResponse = jsonDecode(response.body);
        return WalkinDonationModel.fromJson(jsonResponse['data']);
      } else if (response.statusCode == 401) {
        print('🩸 [DEBUG] ❌ Unauthorized - Token expired');
        throw Exception('Unauthorized - Token expired');
      } else if (response.statusCode == 400) {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Failed to register donation';
        print('🩸 [DEBUG] ❌ Bad request: $errorMsg');
        throw Exception(errorMsg);
      } else if (response.statusCode == 403) {
        final errorMsg = jsonDecode(response.body)['message'] ?? 'Forbidden';
        print('🩸 [DEBUG] ❌ Forbidden: $errorMsg');
        throw Exception(errorMsg);
      } else {
        print('🩸 [DEBUG] ❌ Unexpected status code: ${response.statusCode}');
        throw Exception('Failed to register walk-in donation');
      }
    } catch (e) {
      print('🩸 [DEBUG] ❌ Exception caught: ${e.toString()}');
      print('🩸 [DEBUG] Exception type: ${e.runtimeType}');
      throw Exception('Error: ${e.toString()}');
    }
  }
}
