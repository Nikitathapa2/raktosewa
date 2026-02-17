import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/walkin_donation.dart';

abstract class WalkinDonationRepository {
  /// Register a walk-in donation
  Future<Either<Failures, WalkinDonation>> registerWalkinDonation(
    WalkinDonation donation,
  );
}
