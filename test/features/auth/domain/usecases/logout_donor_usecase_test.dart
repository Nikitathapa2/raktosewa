import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/features/auth/domain/repositories/donor_repository.dart';
import 'package:raktosewa/features/auth/domain/usecases/logout_donor_usecase.dart';

class MockDonorRepository extends Mock implements DonorRepository {}

void main() {
  late LogoutDonorUsecase usecase;
  late MockDonorRepository mockRepository;

  setUp(() {
    mockRepository = MockDonorRepository();
    usecase = LogoutDonorUsecase(donorRepository: mockRepository);
  });

  group('LogoutDonorUsecase', () {
    test('should return true when logout is successful', () async {
      // arrange
      when(() => mockRepository.logout())
          .thenAnswer((_) async => const Right(true));

      // act
      final result = await usecase.call();

      // assert
      expect(result, const Right(true));
      verify(() => mockRepository.logout()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return LocalDatabaseFailure when clearing local storage fails',
        () async {
      // arrange
      const tFailure = LocalDatabaseFailure(
        message: 'Failed to clear local storage',
      );
      when(() => mockRepository.logout())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.call();

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.logout()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when server logout fails', () async {
      // arrange
      const tFailure = ApiFailure(
        message: 'Server error during logout',
        statusCode: 500,
      );
      when(() => mockRepository.logout())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.call();

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.logout()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when there is no internet connection',
        () async {
      // arrange
      const tFailure = NetworkFailure(message: 'No internet connection');
      when(() => mockRepository.logout())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.call();

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.logout()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return false when logout partially fails', () async {
      // arrange
      when(() => mockRepository.logout())
          .thenAnswer((_) async => const Right(false));

      // act
      final result = await usecase.call();

      // assert
      expect(result, const Right(false));
      verify(() => mockRepository.logout()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
