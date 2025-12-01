import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// Wrapper that routes to login or home based on authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading indicator while checking auth state
        if (authProvider.isLoading && authProvider.user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If authenticated, show home screen
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        // Otherwise, show login screen
        return const LoginScreen();
      },
    );
  }
}
