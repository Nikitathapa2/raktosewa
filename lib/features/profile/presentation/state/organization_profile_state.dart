import 'package:raktosewa/features/auth/domain/entities/organization.dart';
import 'package:raktosewa/features/auth/presentation/state/donor_state.dart';

class OrganizationProfileState {
  final AuthStatus status;
  final Organization? organization;
  final String? errorMessage;

  const OrganizationProfileState({
    this.status = AuthStatus.initial,
    this.organization,
    this.errorMessage,
  });

  OrganizationProfileState copyWith({
    AuthStatus? status,
    Organization? organization,
    String? errorMessage,
  }) {
    return OrganizationProfileState(
      status: status ?? this.status,
      organization: organization ?? this.organization,
      errorMessage: errorMessage,
    );
  }
}
