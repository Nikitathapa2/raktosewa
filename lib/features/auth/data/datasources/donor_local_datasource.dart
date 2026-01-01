// lib/features/auth/data/datasources/donor_local_datasource.dart
import '../../domain/entities/donor.dart';

abstract class IDonorLocalDataSource {
  /// Register/save a donor locally
  Future<Donor> registerDonor(Donor donor);

  /// Login donor locally (check email & password)
  Future<Donor> loginDonor(String email, String password);

  /// Get donor profile by ID
  Future<Donor?> getDonorById(String id);

  /// Update donor locally
  Future<bool> updateDonor(Donor donor);

  /// Delete donor by ID
  Future<bool> deleteDonor(String id);
}
