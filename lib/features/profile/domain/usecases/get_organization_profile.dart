import 'package:dartz/dartz.dart';
import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/features/auth/domain/entities/organization.dart';
import 'package:raktosewa/features/auth/domain/repositories/organization_repository.dart';

class GetOrganizationProfile {
  final OrganizationRepository _repository;
  GetOrganizationProfile(this._repository);

  Future<Either<Failures, Organization>> execute(String id) {
    return _repository.getOrganizationProfile(id);
  }
}
