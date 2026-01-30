import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/domain/entities/donor.dart';
import 'package:raktosewa/features/auth/domain/entities/organization.dart';
import 'package:raktosewa/features/auth/domain/usecases/login_donor_usecase.dart';
import 'package:raktosewa/features/auth/domain/usecases/logout_donor_usecase.dart';
import 'package:raktosewa/features/auth/domain/usecases/register_donor_usecase.dart';
import 'package:raktosewa/features/auth/presentation/pages/login_screen.dart';
import 'package:raktosewa/features/auth/presentation/providers/donor_providers.dart';

import 'package:shared_preferences/shared_preferences.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockRegisterDonorUsecase extends Mock implements RegisterDonorUsecase {}
class MockLoginDonorUsecase extends Mock implements LoginDonorUsecase {}


class MockLogoutDonorUsecase extends Mock implements LogoutDonorUsecase {}

class MockSharedPreferences extends Mock implements SharedPreferences {}


void main() {
    late MockRegisterDonorUsecase mockRegisterDonorUsecase;
  late MockSharedPreferences mockSharedPreferences;
  late MockLoginDonorUsecase mockLoginDonorUsecase;
	TestWidgetsFlutterBinding.ensureInitialized();
  
  setUp(() {
    mockRegisterDonorUsecase = MockRegisterDonorUsecase();
    mockSharedPreferences = MockSharedPreferences();
    mockLoginDonorUsecase = MockLoginDonorUsecase();

    // Stub the login usecase to return successful result
    when(() => mockLoginDonorUsecase.execute(any(), any())).thenAnswer(
      (_) async => Right(
        Donor(
          id: 'test-id',
          fullName: 'Test User',
          bloodGroup: 'A+',
          email: 'donor@test.com',
          password: 'password123',
        ),
      ),
    );
  });
	setUpAll(() {
		registerFallbackValue(
			Donor(
				id: 'id',
				fullName: 'full',
				bloodGroup: 'A+',
				email: 'user@test.com',
				password: 'password',
			),
		);

		registerFallbackValue(
			Organization(
				id: 'id',
				organizationName: 'Org',
				headOfOrganization: 'Head',
				email: 'org@test.com',
				password: 'password',
				confirmPassword: 'password',
				terms: true,
			),
		);
	});

	Widget createTestWidget() {
		return ProviderScope(
			overrides: [
  registerDonorProvider.overrideWithValue(mockRegisterDonorUsecase),
        sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        loginDonorProvider.overrideWithValue(mockLoginDonorUsecase),  
			],
			child: const MaterialApp(home: LoginScreen()),
		);
	}

	Future<void> pumpLoginPage(WidgetTester tester) async {
		tester.view.physicalSize = const Size(800, 1200);
		tester.view.devicePixelRatio = 1.0;
		await tester.pumpWidget(createTestWidget());
		await tester.pumpAndSettle();
	}

	group('LoginScreen Widget Tests', () {
		testWidgets('displays all required UI elements', (tester) async {
			await pumpLoginPage(tester);

			expect(find.text('RaktoSewa'), findsOneWidget);
			expect(find.text('Donor'), findsOneWidget);
			expect(find.text('Organization'), findsOneWidget);
			expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
			expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
			expect(find.text('Login'), findsOneWidget);
			expect(find.text("Don't have an account? Register"), findsOneWidget);
		});

		testWidgets('switches between donor and organization tabs', (tester) async {
			await pumpLoginPage(tester);

			// Verify donor tab is initially visible
			expect(find.text('Donor'), findsOneWidget);
			expect(find.text('Organization'), findsOneWidget);

			// Tap organization tab
			await tester.tap(find.text('Organization'));
			await tester.pumpAndSettle();

			// Both tabs should still be visible
			expect(find.text('Donor'), findsOneWidget);
			expect(find.text('Organization'), findsOneWidget);
		});

		testWidgets('toggles password visibility', (tester) async {
			await pumpLoginPage(tester);

			// Find the password field
			final passwordField = find.widgetWithText(TextField, 'Password');
			expect(passwordField, findsOneWidget);

			// Initially password should be obscured
			TextField textField = tester.widget(passwordField);
			expect(textField.obscureText, isTrue);

			// Tap the visibility toggle icon
			await tester.tap(find.byIcon(Icons.visibility_off));
			await tester.pumpAndSettle();

			// Password should now be visible
			textField = tester.widget(passwordField);
			expect(textField.obscureText, isFalse);

			// Tap again to hide
			await tester.tap(find.byIcon(Icons.visibility));
			await tester.pumpAndSettle();

			textField = tester.widget(passwordField);
			expect(textField.obscureText, isTrue);
		});

		testWidgets('allows user to enter email and password', (tester) async {
			await pumpLoginPage(tester);

			await tester.enterText(
				find.widgetWithText(TextField, 'Email'),
				'test@example.com',
			);
			await tester.enterText(
				find.widgetWithText(TextField, 'Password'),
				'password123',
			);

			expect(find.text('test@example.com'), findsOneWidget);
			expect(find.text('password123'), findsOneWidget);
		});

		testWidgets('submits login form with valid credentials', (tester) async {
			await pumpLoginPage(tester);

			// Enter credentials
			await tester.enterText(
				find.widgetWithText(TextField, 'Email'),
				'donor@test.com',
			);
			await tester.enterText(
				find.widgetWithText(TextField, 'Password'),
				'password123',
			);

			// Tap login button
			await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
			await tester.pumpAndSettle();

			// Should not show error message for empty fields
			expect(find.text('Please fill in all fields'), findsNothing);
		});
	});
}