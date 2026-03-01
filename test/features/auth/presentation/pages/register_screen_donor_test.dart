import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/domain/entities/donor.dart';
import 'package:raktosewa/features/auth/domain/usecases/register_donor_usecase.dart';
import 'package:raktosewa/features/auth/presentation/pages/register_screen_donor.dart';
import 'package:raktosewa/features/auth/presentation/providers/donor_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockRegisterDonorUsecase extends Mock implements RegisterDonorUsecase {}

class MockUserSessionService extends Mock implements UserSessionService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockRegisterDonorUsecase mockRegisterDonorUsecase;
  late MockUserSessionService mockUserSessionService;
  late MockSharedPreferences mockSharedPreferences;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockRegisterDonorUsecase = MockRegisterDonorUsecase();
    mockUserSessionService = MockUserSessionService();
    mockSharedPreferences = MockSharedPreferences();
    
    // Mock the execute method to return success
    when(() => mockRegisterDonorUsecase.execute(any()))
        .thenAnswer((_) async => const Right(true));
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
  });

  setUpAll(() {
    registerFallbackValue(
      Donor(
        id: 'id',
        fullName: 'John Doe',
        bloodGroup: 'A+',
        email: 'donor@test.com',
        password: 'password123',
      ),
    );
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        registerDonorProvider.overrideWithValue(mockRegisterDonorUsecase),
        userSessionServiceProvider.overrideWithValue(mockUserSessionService),
        sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
      ],
      child: const MaterialApp(home: DonorRegisterScreen()),
    );
  }

  Future<void> pumpRegisterPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
  }

  group('Donor Register Screen Widget Tests', () {
    testWidgets('displays all required UI elements', (tester) async {
      await pumpRegisterPage(tester);

      expect(find.text('Create Your Account'), findsOneWidget);
      expect(
          find.text('Join us to save lives through blood donations'),
          findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Blood Group'), findsOneWidget);
      expect(find.text('Date of Birth'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('allows user to enter donor information', (tester) async {
      await pumpRegisterPage(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'John Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'),
        'john@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number'),
        '+977-9841234567',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Address'),
        'Kathmandu',
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.text('+977-9841234567'), findsOneWidget);
      expect(find.text('Kathmandu'), findsOneWidget);
    });

    testWidgets('shows error when required fields are empty', (tester) async {
      await pumpRegisterPage(tester);

      // Try to submit without filling fields
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Full Name is required'), findsOneWidget);
      expect(find.text('Select blood group'), findsOneWidget);
      expect(find.text('Select date of birth'), findsOneWidget);
    });

    testWidgets('shows error when passwords do not match', (tester) async {
      await pumpRegisterPage(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'John Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'),
        'john@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number'),
        '+977-9841234567',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Address'),
        'Kathmandu',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password456',
      );

      // Select blood group
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A+').last);
      await tester.pumpAndSettle();

      // Select date
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Accept terms
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Try to submit
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      // Should not proceed with registration
      verifyNever(() => mockRegisterDonorUsecase.execute(any()));
    });

    testWidgets('navigates to login when already have account link is tapped',
        (tester) async {
      await pumpRegisterPage(tester);

      expect(find.text('Already have an account?'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.byType(DonorRegisterScreen), findsNothing);
      expect(find.text('Welcome Back!'), findsOneWidget);
    });

    testWidgets('requires terms acceptance before submission', (tester) async {
      await pumpRegisterPage(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        'John Doe',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'),
        'john@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone Number'),
        '+977-9841234567',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Address'),
        'Kathmandu',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password123',
      );

      // Select blood group
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('A+').last);
      await tester.pumpAndSettle();

      // Select date
      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();
      await tester.tap(find.text('15'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Try to submit without accepting terms
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      // Should not proceed with registration
      verifyNever(() => mockRegisterDonorUsecase.execute(any()));
    });
  });
}
