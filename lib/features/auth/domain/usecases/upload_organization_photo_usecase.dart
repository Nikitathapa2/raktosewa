import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/features/auth/domain/repositories/organization_repository.dart';
import 'package:raktosewa/features/auth/presentation/providers/organization_providers.dart';

final uploadOrganizationPhotoUsecaseProvider = Provider<UploadOrganizationPhotoUsecase>((ref) {
  final repository = ref.read(organizationRepositoryProvider);
  return UploadOrganizationPhotoUsecase(repository: repository);
});

class UploadOrganizationPhotoUsecase {
  final OrganizationRepository _repository;
  UploadOrganizationPhotoUsecase({required OrganizationRepository repository}) : _repository = repository;

  Future<Either<Failures, String>> call(File photo) {
    return _repository.uploadImage(photo);
  }
}
