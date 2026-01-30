import '../../domain/entities/donor.dart';

enum AuthStatus { initial, loading, success, error,loaded }

class DonorState {
  final AuthStatus status;
  final Donor? donor;
  final String? errorMessage;
  final String? uploadedImageUrl;


  const DonorState({
    this.status = AuthStatus.initial,
    this.donor,
    this.errorMessage,
    this.uploadedImageUrl
  });

  DonorState copyWith({
    AuthStatus? status,
    Donor? donor,
    String? errorMessage,
       String? uploadedImageUrl

  }) {
    return DonorState(
      status: status ?? this.status,
      donor: donor ?? this.donor,
      errorMessage: errorMessage,
      uploadedImageUrl: uploadedImageUrl
    );
  }
}
