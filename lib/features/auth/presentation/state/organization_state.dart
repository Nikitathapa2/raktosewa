import '../../domain/entities/organization.dart';
import 'donor_state.dart';

class OrganizationState {
  final AuthStatus status;
  final Organization? organization;
  final String? errorMessage;
  final String? uploadedImageUrl;

  const OrganizationState({
    this.status = AuthStatus.initial,
    this.organization,
    this.errorMessage,
    this.uploadedImageUrl,
  });

  OrganizationState copyWith({
    AuthStatus? status,
    Organization? organization,
    String? errorMessage,
    String? uploadedImageUrl,
  }) {
    return OrganizationState(
      status: status ?? this.status,
      organization: organization ?? this.organization,
      errorMessage: errorMessage,
      uploadedImageUrl: uploadedImageUrl ?? this.uploadedImageUrl,
    );
  }
}
