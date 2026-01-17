import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/core/usecases/usecase_without_params';
import 'package:raktosewa/features/auth/domain/repositories/donor_repository.dart';
import 'package:raktosewa/features/auth/presentation/providers/donor_providers.dart';


// Create Provider
final logoutDonorUsecaseProvider = Provider<LogoutUsecase>((ref) {
  final donorRepository = ref.read(donorRepositoryProvider);
  return LogoutUsecase(donorRepository: donorRepository);
});

class LogoutUsecase implements UsecaseWithoutParms<bool> {
  final DonorRepository _donorRepository;

  LogoutUsecase({required DonorRepository donorRepository})
    : _donorRepository = donorRepository;

  @override
  Future<Either<Failures, bool>> call() {
    return _donorRepository.logout();
  }
}
