import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:raktosewa/core/services/connectivity/network_info.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/organization.dart';
import '../../domain/repositories/organization_repository.dart';
import '../datasources/organization_local_datasource.dart';
import '../datasources/organization_remote_datasource.dart';
import '../models/organization_api_model.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final IOrganizationLocalDataSource _localDataSource;
  final IOrganizationRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final UserSessionService _userSessionService;

  OrganizationRepositoryImpl({
    required IOrganizationLocalDataSource localDataSource,
    required IOrganizationRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    required UserSessionService userSessionService,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo,
        _userSessionService = userSessionService;

  @override
  Future<Either<Failures, bool>> registerOrganization(Organization organization) async {
    if (await _networkInfo.isConnected) {
      // 🌐 ONLINE → API
      try {
        // Entity → ApiModel
        final apiModel = OrganizationApiModel.fromEntity(organization);

        // Remote call
        final registeredOrg = await _remoteDataSource.registerOrganization(apiModel);

        // Save user session after successful registration
        await _userSessionService.saveUserSession(
          userId: registeredOrg.id!,
          email: registeredOrg.email,
          firstName: registeredOrg.organizationName,
          lastName: '',
          role: UserRole.organization,
        );

        // Don't save to local DB during registration - only backend
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message:
                e.response?.data['message'] ??
                e.message ??
                'Organization registration failed',
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      // 📦 OFFLINE → LOCAL DB (no session saved, requires login after online)
      try {
        await _localDataSource.registerOrganization(organization);
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, Organization>> loginOrganization(
    String email,
    String password,
  ) async {
    if (await _networkInfo.isConnected) {
      // 🌐 ONLINE → Try remote login first (authenticate only, no sync)
      try {
        final apiModel = await _remoteDataSource.loginOrganization(email, password);
        final organization = apiModel.toEntity();

        return Right(organization);
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
        final result = await _localDataSource.loginOrganization(email, password);
        return Right(result);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failures, Organization>> getOrganizationProfile(String id) async {
    try {
      final result = await _localDataSource.getOrganizationById(id);
      if (result != null) return Right(result);
      return Left(LocalDatabaseFailure());
    } catch (e) {
      return Left(LocalDatabaseFailure());
    }
  }

  @override
  Future<Either<Failures, Organization>> updateOrganization(
    Organization organization,
  ) async {
    try {
      final success = await _localDataSource.updateOrganization(organization);
      if (success) return Right(organization);
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
