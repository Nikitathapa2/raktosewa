import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/features/auth/domain/repositories/donor_repository.dart';
import 'package:raktosewa/features/auth/domain/usecases/upload_photo_params.dart';
import 'package:raktosewa/features/auth/domain/usecases/upload_photo_usecase.dart';

class MockDonorRepository extends Mock implements DonorRepository {}

class MockFile extends Mock implements File {}

void main() {
  late UploadPhotoUsecase usecase;
  late MockDonorRepository mockRepository;
  late MockFile mockFile;
  late UploadPhotoParams tParams;

  setUp(() {
    mockRepository = MockDonorRepository();
    mockFile = MockFile();
    usecase = UploadPhotoUsecase(repository: mockRepository);
    tParams = UploadPhotoParams(photo: mockFile);
  });

  const tImageUrl = 'https://example.com/images/photo123.jpg';

  group('UploadPhotoUsecase', () {
    setUpAll(() {
      // Register a safe fallback instance for File-type arguments used by mocktail
      registerFallbackValue(MockFile());
    });

    test('should return image URL when upload is successful', () async {
      // arrange
      when(() => mockRepository.uploadImage(any()))
          .thenAnswer((_) async => const Right(tImageUrl));

      // act
      final result = await usecase.call(tParams);

      // assert
      expect(result, const Right(tImageUrl));
      verify(() => mockRepository.uploadImage(mockFile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when upload fails on server', () async {
      // arrange
      const tFailure = ApiFailure(
        message: 'Failed to upload image',
        statusCode: 500,
      );
      when(() => mockRepository.uploadImage(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.call(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.uploadImage(mockFile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when there is no internet connection',
        () async {
      // arrange
      const tFailure = NetworkFailure(message: 'No internet connection');
      when(() => mockRepository.uploadImage(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.call(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.uploadImage(mockFile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when file size exceeds limit', () async {
      // arrange
      const tFailure = ApiFailure(
        message: 'File size exceeds maximum limit',
        statusCode: 413,
      );
      when(() => mockRepository.uploadImage(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.call(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.uploadImage(mockFile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when file type is not supported', () async {
      // arrange
      const tFailure = ApiFailure(
        message: 'Unsupported file format',
        statusCode: 415,
      );
      when(() => mockRepository.uploadImage(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.call(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.uploadImage(mockFile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should forward the file to repository correctly', () async {
      // arrange
      final customFile = MockFile();
      final customParams = UploadPhotoParams(photo: customFile);
      const customUrl = 'https://example.com/images/custom456.jpg';
      
      when(() => mockRepository.uploadImage(customFile))
          .thenAnswer((_) async => const Right(customUrl));

      // act
      final result = await usecase.call(customParams);

      // assert
      expect(result, const Right(customUrl));
      verify(() => mockRepository.uploadImage(customFile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return LocalDatabaseFailure when local storage fails',
        () async {
      // arrange
      const tFailure = LocalDatabaseFailure(
        message: 'Failed to cache image locally',
      );
      when(() => mockRepository.uploadImage(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.call(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.uploadImage(mockFile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when authentication token is invalid',
        () async {
      // arrange
      const tFailure = ApiFailure(
        message: 'Unauthorized',
        statusCode: 401,
      );
      when(() => mockRepository.uploadImage(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.call(tParams);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.uploadImage(mockFile)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
