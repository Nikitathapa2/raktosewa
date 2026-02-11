import '../models/walkin_donation_model.dart';

abstract class IWalkinDonationRemoteDataSource {
  /// Register a walk-in donation
  Future<WalkinDonationModel> registerWalkinDonation(
    String organizationId,
    WalkinDonationModel donation,
  );
}
