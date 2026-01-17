import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/donor.dart';

abstract class DonorRepository {
  /// Registers a new donor
  Future<Either<Failures, bool>> registerDonor(Donor donor);

  /// Login donor using email and password
  Future<Either<Failures, Donor>> loginDonor(String email, String password);

  /// Get donor profile by ID
  Future<Either<Failures, Donor>> getDonorProfile(String id);

  /// Update donor profile
  Future<Either<Failures, Donor>> updateDonorProfile(Donor donor);

  Future<Either<Failures, bool>> logout();
}
