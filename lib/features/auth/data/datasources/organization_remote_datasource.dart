import 'package:raktosewa/features/auth/data/models/organization_api_model.dart';

abstract class IOrganizationRemoteDataSource {
  /// Register/save an organization remotely
  Future<OrganizationApiModel> registerOrganization(
    OrganizationApiModel organization,
  );
  Future<OrganizationApiModel> loginOrganization(String email, String password);
  Future<OrganizationApiModel?> getOrganizationById(String id);
  Future<bool> updateOrganization(OrganizationApiModel organization);
  Future<bool> deleteOrganization(String id);
  Future<bool> logout();
}
