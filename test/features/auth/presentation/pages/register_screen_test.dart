import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/domain/entities/donor.dart';
import 'package:raktosewa/features/auth/domain/entities/organization.dart';
import 'package:raktosewa/features/auth/domain/usecases/logout_donor_usecase.dart';
import 'package:raktosewa/features/auth/domain/usecases/register_donor_usecase.dart';
import 'package:raktosewa/features/auth/presentation/pages/register_screen.dart';
import 'package:raktosewa/features/auth/presentation/providers/donor_providers.dart';

import 'package:shared_preferences/shared_preferences.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockRegisterDonorUsecase extends Mock implements RegisterDonorUsecase {}



class MockLogoutDonorUsecase extends Mock implements LogoutDonorUsecase {}

class MockSharedPreferences extends Mock implements SharedPreferences {}


void main() {
    late MockRegisterDonorUsecase mockRegisterDonorUsecase;
  late MockSharedPreferences mockSharedPreferences;
	TestWidgetsFlutterBinding.ensureInitialized();
  
  setUp(() {
    mockRegisterDonorUsecase = MockRegisterDonorUsecase();
    mockSharedPreferences = MockSharedPreferences();

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

	group('DonorRegisterScreen', () {
		testWidgets('shows donor form by default', (tester) async {
			await pumpRegisterPage(tester);

			expect(find.text('Register to Raktosewa'), findsOneWidget);
			expect(find.text('Blood Donor'), findsOneWidget);
			expect(find.text('Organization'), findsOneWidget);
			expect(find.text('Full Name'), findsOneWidget);
			expect(find.text('Blood Group'), findsOneWidget);
			expect(find.text('Register Now'), findsOneWidget);
		});

		testWidgets('switches to organization form when tab selected', (tester) async {
			await pumpRegisterPage(tester);

			await tester.tap(find.text('Organization'));
			await tester.pumpAndSettle();

			expect(find.text('Organization Name'), findsOneWidget);
			expect(find.text('Head of Organization'), findsOneWidget);
			expect(find.text('Full Name'), findsNothing);
		});

		testWidgets('submits organization form with valid inputs', (tester) async {
			await pumpRegisterPage(tester);

			await tester.tap(find.text('Organization'));
			await tester.pumpAndSettle();

			await tester.enterText(
				find.widgetWithText(TextFormField, 'Organization Name'),
				'Acme Org',
			);
			await tester.enterText(
				find.widgetWithText(TextFormField, 'Head of Organization'),
				'Alice',
			);
			await tester.enterText(
				find.widgetWithText(TextFormField, 'Email'),
				'org@example.com',
			);
			await tester.enterText(
				find.widgetWithText(TextFormField, 'Password'),
				'password123',
			);
			await tester.enterText(
				find.widgetWithText(TextFormField, 'Confirm Password'),
				'password123',
			);

			await tester.tap(find.byType(Checkbox));
			await tester.pump();

			await tester.tap(find.text('Register Now'));
			await tester.pump();

			expect(find.text('Required field'), findsNothing);
		});
	});
}
