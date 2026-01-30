import 'package:raktosewa/core/services/hive/hive_service.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/core/services/storage/token_service.dart';
import '../../models/organization_model.dart';
import '../organization_local_datasource.dart';
import '../../../domain/entities/organization.dart';

class OrganizationLocalDataSourceImpl implements IOrganizationLocalDataSource {
  final DonorHiveService _hiveService;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  OrganizationLocalDataSourceImpl(
    this._hiveService,
    this._userSessionService,
    this._tokenService,
  );

  // ================= REGISTER =================
  @override
  Future<Organization> registerOrganization(Organization organization) async {
    // Check if organization with same email already exists
    final existingOrgs = _hiveService
      .getAllOrganizations()
      .where((o) => o.email == organization.email)
      .toList();

    if (existingOrgs.isNotEmpty) {
      // Update existing organization instead of creating duplicate
      final existingModel = existingOrgs.first;
      final updatedModel =
          OrganizationModel.fromEntity(organization).copyWith(id: existingModel.id);
      await _hiveService.updateOrganization(updatedModel);
      return updatedModel.toEntity();
    }

    final model = OrganizationModel.fromEntity(organization);
    await _hiveService.createOrganization(model);
    return model.toEntity();
  }

  // ================= LOGIN =================
  @override
  Future<Organization> loginOrganization(String email, String password) async {
    final matches = _hiveService.getAllOrganizations().where((o) => o.email == email);
    if (matches.isEmpty) {
      throw Exception('No account found with this email');
    }

    final model = matches.firstWhere(
      (o) => o.password == password,
      orElse: () => throw Exception('Invalid password'),
    );

    final org = model.toEntity();

    // Save session (similar to donor login)
    await _userSessionService.saveUserSession(
      userId: org.id,
      email: org.email,
      firstName: org.organizationName,
      lastName: '',
      role: UserRole.organization,
      profilePicture: null,
    );

    return org;
  }

  // ================= GET BY ID =================
  @override
  Future<Organization?> getOrganizationById(String id) async {
    final model = _hiveService.getOrganizationById(id);
    return model?.toEntity();
  }

  // ================= UPDATE =================
  @override
  Future<bool> updateOrganization(Organization organization) async {
    if (_hiveService.getOrganizationById(organization.id) == null) return false;
    final model = OrganizationModel.fromEntity(organization);
    await _hiveService.updateOrganization(model);
    return true;
  }

  // ================= DELETE =================
  @override
  Future<bool> deleteOrganization(String id) async {
    if (_hiveService.getOrganizationById(id) == null) return false;
    await _hiveService.deleteOrganization(id);
    return true;
  }

  // ================= LOGOUT =================
  @override
  Future<bool> logout() async {
    await _userSessionService.clearSession();
    await _tokenService.clearToken();
    return true;
  }
}
