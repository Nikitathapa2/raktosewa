import 'package:dartz/dartz.dart';
import '../entities/organization.dart';
import '../repositories/organization_repository.dart';
import '../../../../core/error/failures.dart';

class LoginOrganization {
  final OrganizationRepository repository;

  LoginOrganization(this.repository);

  Future<Either<Failures, Organization>> execute(
    String email,
    String password,
  ) {
    return repository.loginOrganization(email, password);
  }
}
