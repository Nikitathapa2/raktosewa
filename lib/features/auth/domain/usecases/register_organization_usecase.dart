import 'package:dartz/dartz.dart';
import '../entities/organization.dart';
import '../repositories/organization_repository.dart';
import '../../../../core/error/failures.dart';

class RegisterOrganizationUsecase {
  final OrganizationRepository repository;

  RegisterOrganizationUsecase(this.repository);

  Future<Either<Failures, bool>> execute(Organization organization) {
    return repository.registerOrganization(organization);
  }
}
