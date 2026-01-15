import 'package:flutter/material.dart';
import 'package:raktosewa/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:raktosewa/screens/hive_screen.dart';

class AppRoutes {
  // Named route constants
  static const String signup = '/signup';
  static const String login = '/login';
  static const String home = '/home';
  static const String hiveView = '/hive_view';
  static const String profile = '/profile';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case signup:
      //   return MaterialPageRoute(builder: (_) => const register_form());
      // case login:
      //   return MaterialPageRoute(builder: (_) => const JobPortalLoginPage());
      // case home:
      //   return MaterialPageRoute(builder: (_) =>  HomeScreen());
      case hiveView:
        // Assuming HiveViewScreen is defined elsewhere
        return MaterialPageRoute(builder: (_) => DonorHiveScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  /// Replace current route with a new one
  static void pushReplacement(BuildContext context, Widget page) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }
}
