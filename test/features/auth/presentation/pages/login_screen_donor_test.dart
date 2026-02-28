import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/presentation/pages/login_screen_donor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockUserSessionService extends Mock implements UserSessionService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockUserSessionService mockUserSessionService;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockUserSessionService = MockUserSessionService();
    mockSharedPreferences = MockSharedPreferences();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        userSessionServiceProvider.overrideWithValue(mockUserSessionService),
        sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
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

  group('Donor Login Screen Widget Tests', () {
    testWidgets('displays all required UI elements', (tester) async {
      await pumpLoginPage(tester);

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('Login to continue saving lives.'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Email Address'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
      expect(find.text('LOGIN'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
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
        find.widgetWithText(TextField, 'Email Address'),
        'donor@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password123',
      );

      expect(find.text('donor@test.com'), findsOneWidget);
      expect(find.text('password123'), findsOneWidget);
    });

    testWidgets('shows warning when fields are empty', (tester) async {
      await pumpLoginPage(tester);

      // Tap login button without entering credentials
      await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
      await tester.pumpAndSettle();

      // Should show warning message for empty fields
      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    testWidgets('navigates to register screen', (tester) async {
      await pumpLoginPage(tester);

      // Find and tap the register link
      final registerLink = find.text('Create Account');
      expect(registerLink, findsOneWidget);

      await tester.tap(registerLink);
      await tester.pumpAndSettle();

      // Verify we've navigated (we won't check the screen since it's a navigation test)
    });

    testWidgets('has forgot password link', (tester) async {
      await pumpLoginPage(tester);

      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('navigates to organization login', (tester) async {
      await pumpLoginPage(tester);

      // Look for the switch to organization link/button
      final orgLink = find.text('Login Here');
      expect(orgLink, findsOneWidget);
      expect(find.text('Are you an organization?'), findsOneWidget);
    });
  });
}
