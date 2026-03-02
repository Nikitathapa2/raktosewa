import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/domain/entities/organization.dart';
import 'package:raktosewa/features/auth/domain/usecases/register_organization_usecase.dart';
import 'package:raktosewa/features/auth/presentation/pages/register_screen_organization.dart';
import 'package:raktosewa/features/auth/presentation/providers/organization_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockRegisterOrganizationUsecase extends Mock
    implements RegisterOrganizationUsecase {}

class MockUserSessionService extends Mock implements UserSessionService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockRegisterOrganizationUsecase mockRegisterOrganizationUsecase;
  late MockUserSessionService mockUserSessionService;
  late MockSharedPreferences mockSharedPreferences;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockRegisterOrganizationUsecase = MockRegisterOrganizationUsecase();
    mockUserSessionService = MockUserSessionService();
    mockSharedPreferences = MockSharedPreferences();
    
    // Mock the execute method to return success
    when(() => mockRegisterOrganizationUsecase.execute(any()))
        .thenAnswer((_) async => const Right(true));
  });

  setUpAll(() {
    registerFallbackValue(
      Organization(
        id: 'id',
        organizationName: 'Red Cross',
        headOfOrganization: 'Dr. Smith',
        email: 'org@test.com',
        password: 'password123',
        confirmPassword: 'password123',
        terms: true,
      ),
    );
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        registerOrganizationProvider
            .overrideWithValue(mockRegisterOrganizationUsecase),
        userSessionServiceProvider.overrideWithValue(mockUserSessionService),
        sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
      ],
      child: const MaterialApp(home: OrganizationRegisterScreen()),
    );
  }

  Future<void> pumpRegisterPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
  }

  group('Organization Register Screen Widget Tests', () {
    testWidgets('displays all required UI elements', (tester) async {
      await pumpRegisterPage(tester);

      expect(find.text('Register Organization'), findsWidgets);
      expect(
          find.text(
              'Manage your blood donation campaigns and reach more donors'),
          findsOneWidget);
      expect(find.text('Organization Name'), findsOneWidget);
      expect(find.text('Head of Organization'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Phone Number (Optional)'), findsOneWidget);
      expect(find.text('Address (Optional)'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Register Organization'), findsWidgets);
    });

    testWidgets('allows user to enter organization information',
        (tester) async {
      await pumpRegisterPage(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Organization Name'),
        'Red Cross Nepal',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Head of Organization'),
        'Dr. John Smith',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'),
        'redcross@example.com',
      );

      expect(find.text('Red Cross Nepal'), findsOneWidget);
      expect(find.text('Dr. John Smith'), findsOneWidget);
      expect(find.text('redcross@example.com'), findsOneWidget);
    });

    testWidgets('allows optional phone and address fields to be empty',
        (tester) async {
      await pumpRegisterPage(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Organization Name'),
        'Red Cross Nepal',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Head of Organization'),
        'Dr. John Smith',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'),
        'redcross@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password123',
      );

      // Accept terms
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Try to submit - phone and address are optional, so this should work
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register Organization'));
      await tester.pumpAndSettle();

      // Should not show any error for optional fields
      expect(find.text('Phone Number (Optional) is required'), findsNothing);
      expect(find.text('Address (Optional) is required'), findsNothing);
    });

  
    testWidgets('shows error when required fields are empty', (tester) async {
      await pumpRegisterPage(tester);

      // Try to submit without filling fields
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register Organization'));
      await tester.pumpAndSettle();

      // Should show validation errors for required fields
      expect(find.text('Organization Name is required'), findsOneWidget);
      expect(find.text('Head of Organization is required'), findsOneWidget);
      expect(find.text('Email Address is required'), findsOneWidget);
    });

    testWidgets('shows error when passwords do not match', (tester) async {
      await pumpRegisterPage(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Organization Name'),
        'Red Cross Nepal',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Head of Organization'),
        'Dr. John Smith',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'),
        'redcross@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password456',
      );

      // Accept terms
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Try to submit
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register Organization'));
      await tester.pumpAndSettle();

      // Should show password mismatch error
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('navigates to login when already registered link is tapped',(tester) async {
      await pumpRegisterPage(tester);

      expect(find.text('Already registered?'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('requires terms acceptance before submission', (tester) async {
      await pumpRegisterPage(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Organization Name'),
        'Red Cross Nepal',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Head of Organization'),
        'Dr. John Smith',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email Address'),
        'redcross@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password123',
      );

      // Try to submit without accepting terms
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register Organization'));
      await tester.pumpAndSettle();

      // Should show terms error
      expect(
          find.text('Please accept the terms and conditions'), findsOneWidget);
    });
  });
}
