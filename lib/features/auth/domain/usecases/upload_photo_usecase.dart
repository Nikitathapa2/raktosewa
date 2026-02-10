
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/features/auth/domain/repositories/donor_repository.dart';
import 'package:raktosewa/features/auth/domain/usecases/upload_photo_params.dart';
import 'package:raktosewa/features/auth/presentation/providers/donor_providers.dart';

//provider 
final uploadPhotoUsecaseProvider = Provider<UploadPhotoUsecase>((ref) {
  final repository = ref.read(donorRepositoryProvider);
  return UploadPhotoUsecase(repository: repository);
});

class UploadPhotoUsecase {
  final DonorRepository _repository;

  UploadPhotoUsecase({required DonorRepository repository}) : 
  _repository = repository;
  Future<Either<Failures, String>> call(UploadPhotoParams params) {
    return _repository.uploadImage(params.photo);
  }
  
}