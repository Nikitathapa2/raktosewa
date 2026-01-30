import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/domain/entities/donor.dart';
import 'package:raktosewa/features/auth/presentation/state/donor_state.dart';
import '../../domain/usecases/get_donor_profile.dart';
import '../../domain/usecases/update_donor_profile.dart';
import '../state/donor_profile_state.dart';
import '../providers/profile_providers.dart';

class DonorProfileViewModel extends Notifier<DonorProfileState> {
  late final GetDonorProfile _getDonorProfile;
  late final UpdateDonorProfile _updateDonorProfile;
  late final UserSessionService _session;

  @override
  DonorProfileState build() {
    _getDonorProfile = ref.read(getDonorProfileProvider);
    _updateDonorProfile = ref.read(updateDonorProfileProvider);
    _session = ref.read(userSessionServiceProvider);
    return const DonorProfileState();
  }

  Future<void> loadProfile() async {
    final userId = _session.getCurrentUserId();
    if (userId == null || userId.isEmpty) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'No logged-in donor');
      return;
    }
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final Either<Failures, Donor> result = await _getDonorProfile.execute(userId);
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message),
      (donor) => state = state.copyWith(status: AuthStatus.success, donor: donor),
    );
  }

  Future<void> updateProfile(Donor donor) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final Either<Failures, Donor> result = await _updateDonorProfile.execute(donor);
    result.fold(
      (failure) => state = state.copyWith(status: AuthStatus.error, errorMessage: failure.message),
      (updated) => state = state.copyWith(status: AuthStatus.success, donor: updated),
    );
  }
}
