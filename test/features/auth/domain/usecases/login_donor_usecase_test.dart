import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/features/auth/domain/entities/donor.dart';
import 'package:raktosewa/features/auth/domain/repositories/donor_repository.dart';
import 'package:raktosewa/features/auth/domain/usecases/login_donor_usecase.dart';

class MockDonorRepository extends Mock implements DonorRepository {}

void main() {
  late LoginDonorUsecase usecase;
  late MockDonorRepository mockRepository;

  setUp(() {
    mockRepository = MockDonorRepository();
    usecase = LoginDonorUsecase(mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  final tDonor = Donor(
    id: '1',
    fullName: 'Test User',
    bloodGroup: 'O+',
    email: tEmail,
    password: tPassword,
    terms: true,
  );

  group('LoginDonorUsecase', () {
    test('should return Donor when login is successful', () async {
      // arrange
      when(() => mockRepository.loginDonor(tEmail, tPassword))
          .thenAnswer((_) async => Right(tDonor));

      // act
      final result = await usecase.execute(tEmail, tPassword);

      // assert
      expect(result, Right(tDonor));
      verify(() => mockRepository.loginDonor(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when login fails with invalid credentials',
        () async {
      // arrange
      const tFailure = ApiFailure(
        message: 'Invalid email or password',
        statusCode: 401,
      );
      when(() => mockRepository.loginDonor(tEmail, tPassword))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.execute(tEmail, tPassword);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.loginDonor(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when there is no internet connection',
        () async {
      // arrange
      const tFailure = NetworkFailure(message: 'No internet connection');
      when(() => mockRepository.loginDonor(tEmail, tPassword))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.execute(tEmail, tPassword);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.loginDonor(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return LocalDatabaseFailure when local storage fails',
        () async {
      // arrange
      const tFailure = LocalDatabaseFailure(
        message: 'Failed to save login data locally',
      );
      when(() => mockRepository.loginDonor(tEmail, tPassword))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.execute(tEmail, tPassword);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.loginDonor(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should forward the email and password to repository correctly',
        () async {
      // arrange
      const customEmail = 'custom@test.com';
      const customPassword = 'customPassword456';
      final customDonor = Donor(
        id: '2',
        fullName: 'Custom User',
        bloodGroup: 'A+',
        email: customEmail,
        password: customPassword,
        terms: true,
      );
      when(() => mockRepository.loginDonor(customEmail, customPassword))
          .thenAnswer((_) async => Right(customDonor));

      // act
      final result = await usecase.execute(customEmail, customPassword);

      // assert
      expect(result, Right(customDonor));
      verify(() => mockRepository.loginDonor(customEmail, customPassword))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when server returns 500 error', () async {
      // arrange
      const tFailure = ApiFailure(
        message: 'Internal server error',
        statusCode: 500,
      );
      when(() => mockRepository.loginDonor(tEmail, tPassword))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.execute(tEmail, tPassword);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.loginDonor(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
