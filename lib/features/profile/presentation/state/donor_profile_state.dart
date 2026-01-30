import 'package:raktosewa/features/auth/domain/entities/donor.dart';
import 'package:raktosewa/features/auth/presentation/state/donor_state.dart';

class DonorProfileState {
  final AuthStatus status;
  final Donor? donor;
  final String? errorMessage;

  const DonorProfileState({
    this.status = AuthStatus.initial,
    this.donor,
    this.errorMessage,
  });

  DonorProfileState copyWith({
    AuthStatus? status,
    Donor? donor,
    String? errorMessage,
  }) {
    return DonorProfileState(
      status: status ?? this.status,
      donor: donor ?? this.donor,
      errorMessage: errorMessage,
    );
  }
}
