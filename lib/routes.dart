// lib/routes.dart
import 'package:flutter/material.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/profile_update_page.dart';
import 'domain/entities/user.dart';
import 'domain/entities/user_profile.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String profileUpdate = '/profile-update';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case home:
        final args = settings.arguments as Map<String, dynamic>?;
        final userId = args?['userId'] as String?;
        return MaterialPageRoute(
          builder: (_) => HomePage(userId: userId ?? ''),
        );
      case profileUpdate:
        final args = settings.arguments as Map<String, dynamic>?;
        final user = args?['user'] as User?;
        final profile = args?['profile'] as UserProfile?;
        return MaterialPageRoute(
          builder: (_) => ProfileUpdatePage(user: user!, profile: profile),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }
}
