import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/features/auth/domain/entities/donor.dart';
import 'package:raktosewa/features/auth/domain/repositories/donor_repository.dart';
import 'package:raktosewa/features/auth/domain/usecases/register_donor_usecase.dart';

class MockDonorRepository extends Mock implements DonorRepository {}

void main() {
  late RegisterDonorUsecase usecase;
  late MockDonorRepository mockRepository;

  setUp(() {
    mockRepository = MockDonorRepository();
    usecase = RegisterDonorUsecase(mockRepository);
  });

  final tDonor = Donor(
    id: '1',
    fullName: 'Test User',
    bloodGroup: 'O+',
    email: 'test@example.com',
    password: 'password123',
    confirmPassword: 'password123',
    phone: '1234567890',
    address: '123 Test St',
    terms: true,
  );

  group('RegisterDonorUsecase', () {
    setUpAll(() {
      registerFallbackValue(tDonor);
    });

    test('should return true when registration is successful', () async {
      // arrange
      when(() => mockRepository.registerDonor(any()))
          .thenAnswer((_) async => const Right(true));

      // act
      final result = await usecase.execute(tDonor);

      // assert
      expect(result, const Right(true));
      verify(() => mockRepository.registerDonor(tDonor)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when email already exists', () async {
      // arrange
      const tFailure = ApiFailure(
        message: 'Email already exists',
        statusCode: 409,
      );
      when(() => mockRepository.registerDonor(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.execute(tDonor);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.registerDonor(tDonor)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when there is no internet connection',
        () async {
      // arrange
      const tFailure = NetworkFailure(message: 'No internet connection');
      when(() => mockRepository.registerDonor(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.execute(tDonor);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.registerDonor(tDonor)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return LocalDatabaseFailure when local storage fails',
        () async {
      // arrange
      const tFailure = LocalDatabaseFailure(
        message: 'Failed to save registration data locally',
      );
      when(() => mockRepository.registerDonor(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.execute(tDonor);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.registerDonor(tDonor)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should forward the donor object to repository correctly', () async {
      // arrange
      final customDonor = Donor(
        id: '2',
        fullName: 'Custom User',
        bloodGroup: 'A+',
        email: 'custom@example.com',
        password: 'customPassword456',
        confirmPassword: 'customPassword456',
        terms: true,
      );
      when(() => mockRepository.registerDonor(any()))
          .thenAnswer((_) async => const Right(true));

      // act
      final result = await usecase.execute(customDonor);

      // assert
      expect(result, const Right(true));
      verify(() => mockRepository.registerDonor(customDonor)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when server returns 500 error', () async {
      // arrange
      const tFailure = ApiFailure(
        message: 'Internal server error',
        statusCode: 500,
      );
      when(() => mockRepository.registerDonor(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.execute(tDonor);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.registerDonor(tDonor)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when validation fails on server', () async {
      // arrange
      const tFailure = ApiFailure(
        message: 'Invalid blood group',
        statusCode: 400,
      );
      when(() => mockRepository.registerDonor(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.execute(tDonor);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.registerDonor(tDonor)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should handle registration with minimal donor information', () async {
      // arrange
      final minimalDonor = Donor(
        id: '3',
        fullName: 'Minimal User',
        bloodGroup: 'B+',
        email: 'minimal@example.com',
        password: 'password123',
        terms: true,
      );
      when(() => mockRepository.registerDonor(any()))
          .thenAnswer((_) async => const Right(true));

      // act
      final result = await usecase.execute(minimalDonor);

      // assert
      expect(result, const Right(true));
      verify(() => mockRepository.registerDonor(minimalDonor)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
