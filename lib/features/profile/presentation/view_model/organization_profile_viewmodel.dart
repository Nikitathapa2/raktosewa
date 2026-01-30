import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/domain/entities/organization.dart';
import 'package:raktosewa/features/auth/presentation/state/donor_state.dart';
import '../../domain/usecases/get_organization_profile.dart';
import '../../domain/usecases/update_organization_profile.dart';
import '../state/organization_profile_state.dart';
import '../providers/profile_providers.dart';

class OrganizationProfileViewModel extends Notifier<OrganizationProfileState> {
  late final GetOrganizationProfile _getOrganizationProfile;
  late final UpdateOrganizationProfile _updateOrganizationProfile;
  late final UserSessionService _session;

  @override
  OrganizationProfileState build() {
    _getOrganizationProfile = ref.read(getOrganizationProfileProvider);
    _updateOrganizationProfile = ref.read(updateOrganizationProfileProvider);
    _session = ref.read(userSessionServiceProvider);
    return const OrganizationProfileState();
  }

  Future<void> loadProfile() async {
    final userId = _session.getCurrentUserId();
    if (userId == null || userId.isEmpty) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'No logged-in organization');
      return;
    }
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final Either<Failures, Organization> result = await _getOrganizationProfile.execute(userId);
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message),
      (org) => state = state.copyWith(status: AuthStatus.success, organization: org),
    );
  }

  Future<void> updateProfile(Organization org) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final Either<Failures, Organization> result = await _updateOrganizationProfile.execute(org);
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message),
      (updated) => state = state.copyWith(status: AuthStatus.success, organization: updated),
    );
  }
}
