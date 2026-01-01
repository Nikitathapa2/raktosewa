import 'package:dartz/dartz.dart';
import 'package:raktosewa/features/auth/data/datasources/donor_local_datasource.dart';
import 'package:raktosewa/features/auth/domain/entities/donor.dart';
import 'package:raktosewa/features/auth/domain/repositories/donor_repository.dart';
import '../../../../core/error/failures.dart';

class DonorRepositoryImpl implements DonorRepository {
  final IDonorLocalDataSource localDataSource;

  DonorRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failures, Donor>> registerDonor(Donor donor) async {
    try {
      final result = await localDataSource.registerDonor(donor);
      return Right(result); // Already a Donor entity
    } catch (e) {
      return Left(LocalDatabaseFailure());
    }
  }

  @override
  Future<Either<Failures, Donor>> loginDonor(
    String email,
    String password,
  ) async {
    try {
      final result = await localDataSource.loginDonor(email, password);
      return Right(result);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, Donor>> getDonorProfile(String id) async {
    try {
      final result = await localDataSource.getDonorById(id);
      if (result != null) return Right(result);
      return Left(LocalDatabaseFailure());
    } catch (e) {
      return Left(LocalDatabaseFailure());
    }
  }

  @override
  Future<Either<Failures, Donor>> updateDonorProfile(Donor donor) async {
    try {
      final success = await localDataSource.updateDonor(donor);
      if (success) return Right(donor);
      return Left(LocalDatabaseFailure());
    } catch (e) {
      return Left(LocalDatabaseFailure());
    }
  }
}
