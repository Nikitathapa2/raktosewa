import '../../domain/entities/organization.dart';
import 'donor_state.dart';

class OrganizationState {
  final AuthStatus status;
  final Organization? organization;
  final String? errorMessage;

  const OrganizationState({
    this.status = AuthStatus.initial,
    this.organization,
    this.errorMessage,
  });

  OrganizationState copyWith({
    AuthStatus? status,
    Organization? organization,
    String? errorMessage,
  }) {
    return OrganizationState(
      status: status ?? this.status,
      organization: organization ?? this.organization,
      errorMessage: errorMessage,
    );
  }
}
