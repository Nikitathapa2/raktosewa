import 'package:dartz/dartz.dart';
import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/features/auth/domain/entities/organization.dart';
import 'package:raktosewa/features/auth/domain/repositories/organization_repository.dart';

class UpdateOrganizationProfile {
  final OrganizationRepository _repository;
  UpdateOrganizationProfile(this._repository);

  Future<Either<Failures, Organization>> execute(Organization organization) {
    return _repository.updateOrganization(organization);
  }
}
