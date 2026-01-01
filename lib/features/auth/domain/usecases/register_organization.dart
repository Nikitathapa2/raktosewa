import 'package:dartz/dartz.dart';
import '../entities/organization.dart';
import '../repositories/organization_repository.dart';
import '../../../../core/error/failures.dart';

class RegisterOrganization {
  final OrganizationRepository repository;

  RegisterOrganization(this.repository);

  Future<Either<Failures, Organization>> execute(Organization organization) {
    return repository.registerOrganization(organization);
  }
}
