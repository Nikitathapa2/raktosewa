import 'package:hive/hive.dart';
import '../../models/organization_model.dart';
import '../organization_local_datasource.dart';
import '../../../domain/entities/organization.dart';

class OrganizationLocalDataSourceImpl implements IOrganizationLocalDataSource {
  final Box<OrganizationModel> organizationBox;

  OrganizationLocalDataSourceImpl(this.organizationBox);

  @override
  Future<Organization> registerOrganization(Organization organization) async {
    final model = OrganizationModel.fromEntity(organization);
    await organizationBox.put(model.id, model);
    return model.toEntity();
  }

  @override
  Future<Organization> loginOrganization(String email, String password) async {
    final matches = organizationBox.values.where((o) => o.email == email);
    if (matches.isEmpty) {
      throw Exception('No account found with this email');
    }

    final model = matches.firstWhere(
      (o) => o.password == password,
      orElse: () => throw Exception('Invalid password'),
    );

    return model.toEntity();
  }

  @override
  Future<Organization?> getOrganizationById(String id) async {
    final model = organizationBox.get(id);
    return model?.toEntity();
  }

  @override
  Future<bool> updateOrganization(Organization organization) async {
    if (!organizationBox.containsKey(organization.id)) return false;
    final model = OrganizationModel.fromEntity(organization);
    await organizationBox.put(organization.id, model);
    return true;
  }

  @override
  Future<bool> deleteOrganization(String id) async {
    if (!organizationBox.containsKey(id)) return false;
    await organizationBox.delete(id);
    return true;
  }
}
