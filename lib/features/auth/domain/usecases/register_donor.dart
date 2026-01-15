import 'package:dartz/dartz.dart';
import '../entities/donor.dart';
import '../repositories/donor_repository.dart';
import '../../../../core/error/failures.dart';

class RegisterDonor {
  final DonorRepository repository;

  RegisterDonor(this.repository);

  Future<Either<Failures, bool>> execute(Donor donor) {
    return repository.registerDonor(donor);
  }
}
