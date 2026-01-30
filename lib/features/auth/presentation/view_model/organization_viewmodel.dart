import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'dart:io';
import '../../domain/entities/organization.dart';
import '../../domain/usecases/register_organization_usecase.dart';
import '../../domain/usecases/login_organization_usecase.dart';
import '../../domain/usecases/logout_organization_usecase.dart';
import '../state/donor_state.dart';
import '../state/organization_state.dart';
import '../../../../core/error/failures.dart';
import '../providers/organization_providers.dart';
import '../../domain/usecases/upload_organization_photo_usecase.dart';

class OrganizationViewModel extends Notifier<OrganizationState> {
  late final RegisterOrganizationUsecase _registerOrganization;
  late final LoginOrganizationUsecase _loginOrganization;
  late final LogoutOrganizationUsecase _logoutOrganizationUsecase;
  late final UploadOrganizationPhotoUsecase _uploadOrganizationPhotoUsecase;

  @override
  OrganizationState build() {
    _registerOrganization = ref.read(registerOrganizationProvider);
    _loginOrganization = ref.read(loginOrganizationProvider);
    _logoutOrganizationUsecase = ref.read(logoutOrganizationUsecaseProvider);
    _uploadOrganizationPhotoUsecase = ref.read(uploadOrganizationPhotoUsecaseProvider);
    return const OrganizationState();
  }

  Future<void> registerOrganization(Organization organization) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    final Either<Failures, bool> result =
        await _registerOrganization.execute(organization);

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

  Future<void> logout() async {
    // Keep UI responsive on logout; no loading spinner
    final result = await _logoutOrganizationUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (success) => state = state.copyWith(
        status: AuthStatus.initial,
        organization: null,
        errorMessage: null,
      ),
    );
  }

  Future<void> uploadPhoto(File photo) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    final result = await _uploadOrganizationPhotoUsecase(photo);
    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (photoUrl) => state = state.copyWith(
        status: AuthStatus.success,
        uploadedImageUrl: photoUrl,
      ),
    );
  }
}
