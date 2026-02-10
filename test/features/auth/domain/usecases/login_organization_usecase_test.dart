import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raktosewa/core/error/failures.dart';
import 'package:raktosewa/features/auth/domain/entities/organization.dart';
import 'package:raktosewa/features/auth/domain/repositories/organization_repository.dart';
import 'package:raktosewa/features/auth/domain/usecases/login_organization_usecase.dart';

class MockOrganizationRepository extends Mock implements OrganizationRepository {}

void main() {
  late LoginOrganizationUsecase usecase;
  late MockOrganizationRepository mockRepository;

  setUp(() {
    mockRepository = MockOrganizationRepository();
    usecase = LoginOrganizationUsecase(mockRepository);
  });

  const tEmail = 'org@example.com';
  const tPassword = 'password123';
  final tOrganization = Organization(
    id: '1',
    organizationName: 'Test Organization',
    headOfOrganization: 'John Doe',
    email: tEmail,
    password: tPassword,
    terms: true,
  );

  group('LoginOrganizationUsecase', () {
    test('should return Organization when login is successful', () async {
      // arrange
      when(() => mockRepository.loginOrganization(tEmail, tPassword))
          .thenAnswer((_) async => Right(tOrganization));

      // act
      final result = await usecase.execute(tEmail, tPassword);

      // assert
      expect(result, Right(tOrganization));
      verify(() => mockRepository.loginOrganization(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when login fails with invalid credentials',
        () async {
      // arrange
      const tFailure = ApiFailure(
        message: 'Invalid email or password',
        statusCode: 401,
      );
      when(() => mockRepository.loginOrganization(tEmail, tPassword))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.execute(tEmail, tPassword);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.loginOrganization(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when there is no internet connection',
        () async {
      // arrange
      const tFailure = NetworkFailure(message: 'No internet connection');
      when(() => mockRepository.loginOrganization(tEmail, tPassword))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.execute(tEmail, tPassword);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.loginOrganization(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return LocalDatabaseFailure when local storage fails',
        () async {
      // arrange
      const tFailure = LocalDatabaseFailure(
        message: 'Failed to save login data locally',
      );
      when(() => mockRepository.loginOrganization(tEmail, tPassword))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.execute(tEmail, tPassword);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.loginOrganization(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should forward the email and password to repository correctly',
        () async {
      // arrange
      const customEmail = 'custom@org.com';
      const customPassword = 'customPassword456';
      final customOrganization = Organization(
        id: '2',
        organizationName: 'Custom Organization',
        headOfOrganization: 'Jane Smith',
        email: customEmail,
        password: customPassword,
        terms: true,
      );
      when(() => mockRepository.loginOrganization(customEmail, customPassword))
          .thenAnswer((_) async => Right(customOrganization));

      // act
      final result = await usecase.execute(customEmail, customPassword);

      // assert
      expect(result, Right(customOrganization));
      verify(() => mockRepository.loginOrganization(customEmail, customPassword))
          .called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when server returns 500 error', () async {
      // arrange
      const tFailure = ApiFailure(
        message: 'Internal server error',
        statusCode: 500,
      );
      when(() => mockRepository.loginOrganization(tEmail, tPassword))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.execute(tEmail, tPassword);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.loginOrganization(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when organization account is not verified',
        () async {
      // arrange
      const tFailure = ApiFailure(
        message: 'Email not verified',
        statusCode: 403,
      );
      when(() => mockRepository.loginOrganization(tEmail, tPassword))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase.execute(tEmail, tPassword);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockRepository.loginOrganization(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
