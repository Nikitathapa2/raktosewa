import 'package:raktosewa/core/services/hive/hive_service.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/core/services/storage/token_service.dart';
import '../../models/donor_model.dart';
import '../donor_datasource.dart';
import '../../../domain/entities/donor.dart';

class DonorLocalDataSourceImpl implements IDonorLocalDataSource {
  final DonorHiveService _hiveService;
  final UserSessionService _userSessionService;
  final TokenService _tokenService;

  DonorLocalDataSourceImpl(
    this._hiveService,
    this._userSessionService,
    this._tokenService,
  );

  // ================= REGISTER =================
  @override
  Future<Donor> registerDonor(Donor donor) async {
    // Check if donor with same email already exists
    final existingDonors = _hiveService
        .getAllDonors()
        .where((d) => d.email == donor.email)
        .toList();

    if (existingDonors.isNotEmpty) {
      // Update existing donor instead of creating duplicate
      final existingModel = existingDonors.first;
      final updatedModel = DonorModel.fromEntity(donor).copyWith(id: existingModel.id);
      await _hiveService.updateDonor(updatedModel);
      return updatedModel.toEntity();
    }

    final model = DonorModel.fromEntity(donor);
    await _hiveService.createDonor(model);
    return model.toEntity();
  }

  // ================= LOGIN =================
  @override
  Future<Donor> loginDonor(String email, String password) async {
    final donors = _hiveService
        .getAllDonors()
        .where((d) => d.email == email)
        .toList();

    if (donors.isEmpty) {
      throw Exception("No account found with this email");
    }

    final donorModel = donors.firstWhere(
      (d) => d.password == password,
      orElse: () => throw Exception("Invalid password"),
    );

    final donor = donorModel.toEntity();

    // Save session (similar to recruiter login)
    await _userSessionService.saveUserSession(
      userId: donor.id,
      email: donor.email,
      firstName: donor.fullName,
      lastName: "",
      role: UserRole.donor,
      profilePicture: null,
    );

    return donor;
  }

  // ================= GET BY ID =================
  @override
  Future<Donor?> getDonorById(String id) async {
    final model = _hiveService.getDonorById(id);
    return model?.toEntity();
  }

  // ================= UPDATE =================
  @override
  Future<bool> updateDonor(Donor donor) async {
    final existing = _hiveService.getDonorById(donor.id);
    if (existing == null) return false;

    final model = DonorModel.fromEntity(donor);
    await _hiveService.updateDonor(model);
    return true;
  }

  // ================= DELETE =================
  @override
  Future<bool> deleteDonor(String id) async {
    final existing = _hiveService.getDonorById(id);
    if (existing == null) return false;

    await _hiveService.deleteDonor(id);
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
