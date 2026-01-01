import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:raktosewa/core/error/failures.dart';
import '../../domain/entities/donor.dart';
import '../../domain/usecases/register_donor.dart';
import '../../domain/usecases/login_donor.dart';
import '../state/donor_state.dart';
import '../providers/donor_providers.dart';

class DonorViewModel extends Notifier<DonorState> {
  late final RegisterDonor _registerDonor;
  late final LoginDonor _loginDonor;

  @override
  DonorState build() {
    _registerDonor = ref.read(registerDonorProvider);
    _loginDonor = ref.read(loginDonorProvider);
    return const DonorState();
  }

  /// Register donor
  Future<void> registerDonor(Donor donor) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final Either<Failures, Donor> result = await _registerDonor.execute(donor);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (donor) {
        state = state.copyWith(status: AuthStatus.success, donor: donor);
      },
    );
  }

  /// Login donor
  Future<void> loginDonor(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final Either<Failures, Donor> result = await _loginDonor.execute(
      email,
      password,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (donor) {
        state = state.copyWith(status: AuthStatus.success, donor: donor);
      },
    );
  }
}
