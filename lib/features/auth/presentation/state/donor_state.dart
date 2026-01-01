import '../../domain/entities/donor.dart';

enum AuthStatus { initial, loading, success, error }

class DonorState {
  final AuthStatus status;
  final Donor? donor;
  final String? errorMessage;

  const DonorState({
    this.status = AuthStatus.initial,
    this.donor,
    this.errorMessage,
  });

  DonorState copyWith({
    AuthStatus? status,
    Donor? donor,
    String? errorMessage,
  }) {
    return DonorState(
      status: status ?? this.status,
      donor: donor ?? this.donor,
      errorMessage: errorMessage,
    );
  }
}
