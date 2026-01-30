import 'package:dartz/dartz.dart';
import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/features/auth/domain/entities/donor.dart';
import 'package:raktosewa/features/auth/domain/repositories/donor_repository.dart';

class UpdateDonorProfile {
  final DonorRepository _repository;
  UpdateDonorProfile(this._repository);

  Future<Either<Failures, Donor>> execute(Donor donor) {
    return _repository.updateDonorProfile(donor);
  }
}
