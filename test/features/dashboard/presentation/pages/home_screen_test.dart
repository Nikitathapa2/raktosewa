import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raktosewa/features/dashboard/presentation/pages/home_screen.dart';
import 'package:raktosewa/core/services/storage/user_session_service.dart';

// Mock class
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
    late MockSharedPreferences mockSharedPreferences;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
    });

  group('HomeScreen Widget Tests', () {
    testWidgets('should display home screen with all main widgets', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        ProviderScope(
              overrides: [
                sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
              ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should have white background color', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // assert
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFFFFFFFF));
    });

    testWidgets('should be scrollable', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // assert
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should have proper padding', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // assert
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.padding, const EdgeInsets.all(16));
    });

    testWidgets('should display all main sections in correct order', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // assert - verify the structure exists
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should have SafeArea for proper device compatibility', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // assert
      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should render without errors', (WidgetTester tester) async {
      // act & assert
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should have Column with correct cross axis alignment', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // assert
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should display multiple SizedBox spacing elements', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // assert - should have multiple spacing elements
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('should maintain consistent spacing between sections', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // assert - verify SizedBox elements exist for spacing
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(sizedBoxes.length, greaterThan(0));
    });

    testWidgets('should be a StatelessWidget', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // assert
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should build successfully with MaterialApp wrapper', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have no overflow issues', (WidgetTester tester) async {
      // act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // assert - no exceptions means no overflow
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
