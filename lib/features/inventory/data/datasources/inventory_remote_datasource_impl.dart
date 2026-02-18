import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:raktosewa/core/api/api_endpoints.dart';
import 'package:raktosewa/features/inventory/data/datasources/inventory_datasource.dart';
import 'package:raktosewa/features/inventory/data/models/blood_inventory_model.dart';
import 'package:raktosewa/features/inventory/data/models/organization_blood_stock_model.dart';

class InventoryRemoteDataSourceImpl implements InventoryDataSource {
  final http.Client client;

  InventoryRemoteDataSourceImpl({required this.client});

  @override
  Future<List<BloodInventoryModel>> getInventory(String token) async {
    final response = await client.get(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.getInventory}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> inventoryData = jsonResponse['data'] ?? [];
      return inventoryData
          .map((json) => BloodInventoryModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch inventory');
    }
  }

  @override
  Future<List<OrganizationBloodStockModel>> getAllBloodStock(String token) async {
    final response = await client.get(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.getAllBloodStock}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> stockData = jsonResponse['data'] ?? [];
      return stockData
          .map((json) => OrganizationBloodStockModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to fetch blood stock');
    }
  }

  @override
  Future<BloodInventoryModel> updateInventory({
    required String token,
    required String bloodGroup,
    required int quantity,
    required String operation,
  }) async {
    final response = await client.post(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.updateInventory}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'bloodGroup': bloodGroup,
        'quantity': quantity,
        'operation': operation,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return BloodInventoryModel.fromJson(jsonResponse['data']);
    } else {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      throw Exception(jsonResponse['message'] ?? 'Failed to update inventory');
    }
  }

  @override
  Future<void> deleteInventory({
    required String token,
    required String bloodGroup,
  }) async {
    final response = await client.delete(
      Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.deleteInventory}/$bloodGroup'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      throw Exception(jsonResponse['message'] ?? 'Failed to delete inventory');
    }
  }
}
