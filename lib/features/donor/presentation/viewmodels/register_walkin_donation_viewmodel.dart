import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/walkin_donation.dart';
import '../../domain/usecases/register_walkin_donation_usecase.dart';
import '../state/register_walkin_donation_state.dart';
import '../../data/providers/walkin_donation_providers.dart' as data_providers;

class RegisterWalkinDonationNotifier
    extends Notifier<RegisterWalkinDonationState> {
  late RegisterWalkinDonationUsecase _registerUsecase;

  @override
  RegisterWalkinDonationState build() {
    _registerUsecase = ref.read(data_providers.registerWalkinDonationProvider);
    return RegisterWalkinDonationState();
  }

  Future<void> registerDonation(WalkinDonation donation) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _registerUsecase(donation);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          isSuccess: false,
        );
      },
      (registeredDonation) {
        state = state.copyWith(
          isLoading: false,
          registeredDonation: registeredDonation,
          isSuccess: true,
          errorMessage: null,
        );
      },
    );
  }

  void resetState() {
    state = RegisterWalkinDonationState();
  }
}
