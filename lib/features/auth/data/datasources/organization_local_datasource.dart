
import '../../domain/entities/organization.dart';

abstract class IOrganizationLocalDataSource {
  Future<Organization> registerOrganization(Organization organization);
  Future<Organization> loginOrganization(String email, String password);
  Future<Organization?> getOrganizationById(String id);
  Future<bool> updateOrganization(Organization organization);
  Future<bool> deleteOrganization(String id);
  Future<bool> logout();

}
