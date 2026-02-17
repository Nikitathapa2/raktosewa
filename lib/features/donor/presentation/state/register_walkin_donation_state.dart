import '../../domain/entities/walkin_donation.dart';

class RegisterWalkinDonationState {
  final bool isLoading;
  final WalkinDonation? registeredDonation;
  final String? errorMessage;
  final bool isSuccess;

  RegisterWalkinDonationState({
    this.isLoading = false,
    this.registeredDonation,
    this.errorMessage,
    this.isSuccess = false,
  });

  RegisterWalkinDonationState copyWith({
    bool? isLoading,
    WalkinDonation? registeredDonation,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return RegisterWalkinDonationState(
      isLoading: isLoading ?? this.isLoading,
      registeredDonation: registeredDonation ?? this.registeredDonation,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
