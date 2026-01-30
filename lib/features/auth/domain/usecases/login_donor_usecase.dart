import 'package:dartz/dartz.dart';
import '../entities/donor.dart';
import '../repositories/donor_repository.dart';
import '../../../../core/error/failures.dart';

class LoginDonorUsecase {
  final DonorRepository repository;

  LoginDonorUsecase(this.repository);

  Future<Either<Failures, Donor>> execute(String email, String password) {
    return repository.loginDonor(email, password);
  }
}
