import 'package:dartz/dartz.dart';
import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/features/auth/domain/entities/donor.dart';
import 'package:raktosewa/features/auth/domain/repositories/donor_repository.dart';

class GetDonorProfile {
  final DonorRepository _repository;
  GetDonorProfile(this._repository);

  Future<Either<Failures, Donor>> execute(String id) {
    return _repository.getDonorProfile(id);
  }
}
