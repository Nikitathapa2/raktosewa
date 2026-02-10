import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/features/auth/domain/usecases/logout_donor_usecase.dart';
import 'package:raktosewa/features/auth/domain/usecases/upload_photo_params.dart';
import 'package:raktosewa/features/auth/domain/usecases/upload_photo_usecase.dart';
import '../../domain/entities/donor.dart';
import '../../domain/usecases/register_donor_usecase.dart';
import '../../domain/usecases/login_donor_usecase.dart';
import '../state/donor_state.dart';
import '../providers/donor_providers.dart';

class DonorViewModel extends Notifier<DonorState> {
  late final RegisterDonorUsecase _registerDonor;
  late final LoginDonorUsecase _loginDonor;
  late final LogoutDonorUsecase _logoutUsecase;
    late final UploadPhotoUsecase _uploadPhotoUsecase;


  @override
  DonorState build() {
    _registerDonor = ref.read(registerDonorProvider);
    _loginDonor = ref.read(loginDonorProvider);
    _logoutUsecase = ref.read(logoutDonorUsecaseProvider);
        _uploadPhotoUsecase = ref.read(uploadPhotoUsecaseProvider);


    return const DonorState();
  }

  /// Register donor
  Future<void> registerDonor(Donor donor) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final Either<Failures, bool> result = await _registerDonor.execute(donor);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (success) {
        state = state.copyWith(status: AuthStatus.success);
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

    
  Future<void> logout() async {
    // Keep UI responsive on logout; no loading spinner
    final result = await _logoutUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.initial,
        donor: null,
        errorMessage: null,
      ),
    );
  }


   Future<void> uploadPhoto(File photo)async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _uploadPhotoUsecase(UploadPhotoParams(photo: photo));
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (photoUrl) {
        state = state.copyWith(
          status: AuthStatus.loaded,
          uploadedImageUrl: photoUrl,
        );
      },
    );
  }

}
