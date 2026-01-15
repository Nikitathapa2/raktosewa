import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:raktosewa/core/services/connectivity/network_info.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/data/datasources/donor_datasource.dart';
import 'package:raktosewa/features/auth/data/models/donor_api_model.dart';
import 'package:raktosewa/features/auth/domain/entities/donor.dart';
import 'package:raktosewa/features/auth/domain/repositories/donor_repository.dart';
import '../../../../core/error/failures.dart';


class DonorRepositoryImpl implements DonorRepository {
  final IDonorLocalDataSource _localDataSource;
  final IDonorRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final UserSessionService _userSessionService;

  DonorRepositoryImpl({
    required IDonorLocalDataSource localDataSource,
    required IDonorRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    required UserSessionService userSessionService,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo,
        _userSessionService = userSessionService;

@override
Future<Either<Failures, bool>> registerDonor(Donor donor) async {
  if (await _networkInfo.isConnected) {
    try {
      // Entity → ApiModel
      final apiModel = DonorApiModel.fromEntity(donor);

      // Remote call
      final registeredDonor = await _remoteDataSource.registerDonor(apiModel);

      // Save user session after successful registration
      final name = registeredDonor.fullName.trim();
      final parts = name.split(' ');
      await _userSessionService.saveUserSession(
        userId: registeredDonor.id!,
        email: registeredDonor.email,
        firstName: parts.first,
        lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
        role: UserRole.donor,
      );

      // Don't save to local DB during registration - only backend
      return const Right(true);
    } on DioException catch (e) {
      return Left(
        ApiFailure(
          message:
              e.response?.data['message'] ??
              e.message ??
              'Donor registration failed',
        ),
      );
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  } else {
    // 📦 OFFLINE → LOCAL DB (no session saved, requires login after online)
    try {
      await _localDataSource.registerDonor(donor);
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}


  @override
  Future<Either<Failures, Donor>> loginDonor(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      // 🌐 ONLINE → Try remote login first (authenticate only, no sync)
      try {
        final apiModel = await _remoteDataSource.loginDonor(email, password);
        final donor = apiModel.toEntity();

        return Right(donor);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ??
                e.message ??
                'Login failed',
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // 📦 OFFLINE → Local login only
      try {
        final result = await _localDataSource.loginDonor(email, password);
        return Right(result);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, Donor>> getDonorProfile(String id) async {
    try {
      final result = await _localDataSource.getDonorById(id);
      if (result != null) return Right(result);
      return Left(LocalDatabaseFailure());
    } catch (e) {
      return Left(LocalDatabaseFailure());
    }
  }

  @override
  Future<Either<Failures, Donor>> updateDonorProfile(Donor donor) async {
    try {
      final success = await _localDataSource.updateDonor(donor);
      if (success) return Right(donor);
      return Left(LocalDatabaseFailure());
    } catch (e) {
      return Left(LocalDatabaseFailure());
    }
  }
  
  @override
  Future<Either<Failures, bool>> logout() async {
    try {
      await _localDataSource.logout();
      return const Right(true);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
