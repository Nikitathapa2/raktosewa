// lib/features/auth/data/datasources/donor_local_datasource.dart
import 'package:raktosewa/features/auth/data/models/donor_api_model.dart';

import '../../domain/entities/donor.dart';

abstract class IDonorLocalDataSource {
  /// Register/save a donor locally (returns void for simplicity, updates if exists)
  Future<Donor> registerDonor(Donor donor);
  Future<Donor> loginDonor(String email, String password);
  Future<Donor?> getDonorById(String id);
  Future<bool> updateDonor(Donor donor);
  Future<bool> deleteDonor(String id);
  Future<bool> logout();

}


abstract class IDonorRemoteDataSource {
  /// Register/save a donor remotely
  Future<DonorApiModel> registerDonor(DonorApiModel donor);
  Future<DonorApiModel> loginDonor(String email, String password);
  Future<DonorApiModel?> getDonorById(String id);
  Future<bool> updateDonor(DonorApiModel donor);
  Future<bool> deleteDonor(String id);
  Future<bool> logout();


}
