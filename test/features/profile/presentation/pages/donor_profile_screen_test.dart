import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';
import 'package:raktosewa/features/auth/presentation/providers/donor_providers.dart';
import 'package:raktosewa/features/auth/presentation/state/donor_state.dart';
import 'package:raktosewa/features/auth/presentation/view_model/donor_viewmodel.dart';
import 'package:raktosewa/features/profile/presentation/pages/donor_profile_screen.dart';
import 'package:raktosewa/features/profile/presentation/providers/profile_providers.dart';
import 'package:raktosewa/features/profile/presentation/state/donor_profile_state.dart';
import 'package:raktosewa/features/profile/presentation/view_model/donor_profile_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockUserSessionService extends Mock implements UserSessionService {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class FakeDonorProfileViewModel extends DonorProfileViewModel {
  @override
  DonorProfileState build() => const DonorProfileState();

  @override
  Future<void> loadProfile() async {
    state = state.copyWith(status: AuthStatus.loaded);
  }
}

class FakeDonorViewModel extends DonorViewModel {
  @override
  DonorState build() => const DonorState();

  @override
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
        .thenReturn('John Doe');
    when(() => mockUserSessionService.getCurrentUserEmail())
        .thenReturn('john@example.com');
    when(() => mockUserSessionService.getUserAddress())
        .thenReturn('123 Main Street, City');
    when(() => mockUserSessionService.getCurrentUserPhoneNumber())
        .thenReturn('+1234567890');
    when(() => mockUserSessionService.getProfilePicture())
        .thenReturn(null);
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        userSessionServiceProvider.overrideWithValue(mockUserSessionService),
        sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        donorProfileViewModelProvider.overrideWith(FakeDonorProfileViewModel.new),
        donorViewModelProvider.overrideWith(FakeDonorViewModel.new),
      ],
      child: const MaterialApp(home: DonorProfileScreen()),
    );
  }

  Future<void> pumpProfilePage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();
  }

  group('DonorProfileScreen Widget Tests', () {
    testWidgets('displays all required UI elements', (tester) async {
      await pumpProfilePage(tester);

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Blood Group: A+'), findsOneWidget);
      expect(find.text('Donations'), findsOneWidget);
      expect(find.text('Lives Saved'), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('displays contact information correctly', (tester) async {
      await pumpProfilePage(tester);

      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('+1234567890'), findsOneWidget);
      expect(find.text('Residential Address'), findsOneWidget);
      expect(find.text('123 Main Street, City'), findsOneWidget);
    });

    testWidgets('displays stats cards with correct values', (tester) async {
      await pumpProfilePage(tester);

      expect(find.text('12'), findsOneWidget);
      expect(find.text('Donations'), findsOneWidget);
      expect(find.text('36'), findsOneWidget);
      expect(find.text('Lives Saved'), findsOneWidget);
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
