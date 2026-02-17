import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/walkin_donation.dart';
import '../repositories/walkin_donation_repository.dart';

class RegisterWalkinDonationUsecase {
  final WalkinDonationRepository repository;

  RegisterWalkinDonationUsecase(this.repository);

  Future<Either<Failures, WalkinDonation>> call(WalkinDonation donation) {
    return repository.registerWalkinDonation(donation);
  }
}
