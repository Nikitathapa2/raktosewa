import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/organization.dart';
import '../../domain/usecases/register_organization.dart';
import '../../domain/usecases/login_organization.dart';
import '../state/donor_state.dart';
import '../state/organization_state.dart';
import '../../../../../core/error/failures.dart';
import '../providers/organization_providers.dart';

class OrganizationViewModel extends Notifier<OrganizationState> {
  late final RegisterOrganization _registerOrganization;
  late final LoginOrganization _loginOrganization;

  @override
  OrganizationState build() {
    _registerOrganization = ref.read(registerOrganizationProvider);
    _loginOrganization = ref.read(loginOrganizationProvider);
    return const OrganizationState();
  }

  Future<void> registerOrganization(Organization organization) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final Either<Failures, Organization> result =
        await _registerOrganization.execute(organization);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (org) {
        state = state.copyWith(status: AuthStatus.success, organization: org);
      },
    );
  }

  Future<void> loginOrganization(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final Either<Failures, Organization> result =
        await _loginOrganization.execute(email, password);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (org) {
        state = state.copyWith(status: AuthStatus.success, organization: org);
      },
    );
  }
}
