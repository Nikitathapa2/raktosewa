import 'package:dartz/dartz.dart';
import '../entities/donor.dart';
import '../repositories/donor_repository.dart';
import '../../../../core/error/failures.dart';

class LoginDonor {
  final DonorRepository repository;

  LoginDonor(this.repository);

  Future<Either<Failures, Donor>> execute(String email, String password) {
    return repository.loginDonor(email, password);
  }
}
