import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/core/usecases/usecase_without_params';
import 'package:raktosewa/features/auth/domain/repositories/donor_repository.dart';
import 'package:raktosewa/features/auth/presentation/providers/donor_providers.dart';


// Create Provider
final logoutDonorUsecaseProvider = Provider<LogoutDonorUsecase>((ref) {
  final donorRepository = ref.read(donorRepositoryProvider);
  return LogoutDonorUsecase(donorRepository: donorRepository);
});

class LogoutDonorUsecase implements UsecaseWithoutParms<bool> {
  final DonorRepository _donorRepository;

  LogoutDonorUsecase({required DonorRepository donorRepository})
    : _donorRepository = donorRepository;

  @override
  Future<Either<Failures, bool>> call() {
    return _donorRepository.logout();
  }
}
