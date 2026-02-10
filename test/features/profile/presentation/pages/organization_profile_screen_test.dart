import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/presentation/providers/organization_providers.dart';
import 'package:raktosewa/features/auth/presentation/state/donor_state.dart';
import 'package:raktosewa/features/auth/presentation/state/organization_state.dart';
import 'package:raktosewa/features/auth/presentation/view_model/organization_viewmodel.dart';
import 'package:raktosewa/features/profile/presentation/pages/organization_profile_screen.dart';
import 'package:raktosewa/features/profile/presentation/providers/profile_providers.dart';
import 'package:raktosewa/features/profile/presentation/state/organization_profile_state.dart';
import 'package:raktosewa/features/profile/presentation/view_model/organization_profile_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockUserSessionService extends Mock implements UserSessionService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class FakeOrganizationProfileViewModel extends OrganizationProfileViewModel {
  @override
  OrganizationProfileState build() => const OrganizationProfileState();

  Future<void> loadProfile() async {
    state = state.copyWith(status: AuthStatus.loaded);
  }
}

class FakeOrganizationViewModel extends OrganizationViewModel {
  @override
  OrganizationState build() => const OrganizationState();

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.success);
  }
}

void main() {
  late MockUserSessionService mockUserSessionService;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockUserSessionService = MockUserSessionService();
    mockSharedPreferences = MockSharedPreferences();

    // Stub user session service methods
    when(() => mockUserSessionService.getCurrentUserFullName())
        .thenReturn('Red Cross Organization');
    when(() => mockUserSessionService.getCurrentUserEmail())
        .thenReturn('contact@redcross.org');
    when(() => mockUserSessionService.getUserAddress())
        .thenReturn('456 Health Street, Medical City');
    when(() => mockUserSessionService.getCurrentUserPhoneNumber())
        .thenReturn('+0987654321');
    when(() => mockUserSessionService.getProfilePicture())
        .thenReturn(null);
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        userSessionServiceProvider.overrideWithValue(mockUserSessionService),
        sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        organizationProfileViewModelProvider.overrideWith(FakeOrganizationProfileViewModel.new),
        organizationViewModelProvider.overrideWith(FakeOrganizationViewModel.new),
      ],
      child: const MaterialApp(home: OrganizationProfileScreen()),
    );
  }

  Future<void> pumpProfilePage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
  }

  group('OrganizationProfileScreen Widget Tests', () {
    testWidgets('displays all required UI elements', (tester) async {
      await pumpProfilePage(tester);

      expect(find.text('Organization Profile'), findsOneWidget);
      expect(find.text('Red Cross Organization'), findsOneWidget);
      expect(find.text('CERTIFIED BLOOD BANK'), findsOneWidget);
      expect(find.text('Edit Organization Info'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('displays contact information correctly', (tester) async {
      await pumpProfilePage(tester);

      expect(find.text('Contact Information'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('contact@redcross.org'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('+0987654321'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('456 Health Street, Medical City'), findsWidgets);
      expect(find.text('Operating Hours'), findsOneWidget);
    });

    testWidgets('displays stats cards with correct values', (tester) async {
      await pumpProfilePage(tester);

      expect(find.text('Total Requests'), findsOneWidget);
      expect(find.text('1,240'), findsOneWidget);
      expect(find.text('Successful Donations'), findsOneWidget);
      expect(find.text('850'), findsOneWidget);
    });

    testWidgets('shows logout confirmation dialog when logout tapped', (tester) async {
      await pumpProfilePage(tester);

      // Tap logout button
      await tester.tap(find.text('Logout').last);
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('dismisses logout dialog when cancel is tapped', (tester) async {
      await pumpProfilePage(tester);

      // Open logout dialog
      await tester.tap(find.text('Logout').last);
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to logout?'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.text('Are you sure you want to logout?'), findsNothing);
    });
  });
}
