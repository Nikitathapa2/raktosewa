import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/core/usecases/usecase_without_params';
import 'package:raktosewa/features/auth/domain/repositories/organization_repository.dart';
import 'package:raktosewa/features/auth/presentation/providers/organization_providers.dart';


// Create Provider
final logoutOrganizationUsecaseProvider = Provider<LogoutOrganizationUsecase>((ref) {
  final organizationRepository = ref.read(organizationRepositoryProvider);
  return LogoutOrganizationUsecase(organizationRepository);
});

class LogoutOrganizationUsecase implements UsecaseWithoutParms<bool> {
  final OrganizationRepository _organizationRepository;

  LogoutOrganizationUsecase(this._organizationRepository);

  @override
  Future<Either<Failures, bool>> call() {
    return _organizationRepository.logout();
  }
}
