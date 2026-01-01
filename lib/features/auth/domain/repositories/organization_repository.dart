import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/organization.dart';

abstract class OrganizationRepository {
  Future<Either<Failures, Organization>> registerOrganization(
    Organization organization,
  );

  Future<Either<Failures, Organization>> loginOrganization(
    String email,
    String password,
  );

  Future<Either<Failures, Organization>> getOrganizationProfile(String id);

  Future<Either<Failures, Organization>> updateOrganization(
    Organization organization,
  );
}
