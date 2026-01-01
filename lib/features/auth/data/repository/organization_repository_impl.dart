import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/organization.dart';
import '../../domain/repositories/organization_repository.dart';
import '../datasources/organization_local_datasource.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final IOrganizationLocalDataSource localDataSource;

  OrganizationRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failures, Organization>> registerOrganization(
    Organization organization,
  ) async {
    try {
      final result = await localDataSource.registerOrganization(organization);
      return Right(result);
    } catch (_) {
      return Left(LocalDatabaseFailure());
    }
  }

  @override
  Future<Either<Failures, Organization>> loginOrganization(
    String email,
    String password,
  ) async {
    try {
      final result = await localDataSource.loginOrganization(email, password);
      return Right(result);
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, Organization>> getOrganizationProfile(String id) async {
    try {
      final result = await localDataSource.getOrganizationById(id);
      if (result != null) return Right(result);
      return Left(LocalDatabaseFailure());
    } catch (_) {
      return Left(LocalDatabaseFailure());
    }
  }

  @override
  Future<Either<Failures, Organization>> updateOrganization(
    Organization organization,
  ) async {
    try {
      final success = await localDataSource.updateOrganization(organization);
      if (success) return Right(organization);
      return Left(LocalDatabaseFailure());
    } catch (_) {
      return Left(LocalDatabaseFailure());
    }
  }
}
