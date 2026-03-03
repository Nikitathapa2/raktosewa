import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../models/notification_model.dart';
import 'notification_datasource.dart';

class NotificationRemoteDataSourceImpl implements INotificationRemoteDataSource {
  final http.Client client;
  final String baseUrl = ApiEndpoints.baseUrl;
  String? _token;

  NotificationRemoteDataSourceImpl({
    required this.client,
    String? token,
  }) : _token = token;

  void setToken(String token) {
    _token = token;
  }

  @override
  Future<List<NotificationModel>> getMyNotifications() async {
    final url = Uri.parse('$baseUrl${ApiEndpoints.notificationsEndpoint}');

    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final dataList = jsonResponse['data'] as List? ?? [];
        return dataList
            .map((item) => NotificationModel.fromJson(item))
            .toList();
      }

      throw Exception('Failed to fetch notifications');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }
}
