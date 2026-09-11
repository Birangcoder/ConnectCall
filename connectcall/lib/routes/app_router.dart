import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/splash/splash_screen.dart';

/// Central router. Redirect logic reads the live auth state so that:
/// - While Firebase is still resolving auth -> show Splash
/// - Logged out -> force to /login
/// - Logged in -> force away from /login /register to /home
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      // Additional routes (contacts, profile, call screens, history)
      // are added here as each screen is built.
    ],
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final User? user = authState.asData?.value;
      final loggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final onSplash = state.matchedLocation == '/splash';

      if (isLoading) return onSplash ? null : '/splash';

      if (user == null) {
        return loggingIn ? null : '/login';
      }

      // Logged in: keep them out of splash/login/register.
      if (onSplash || loggingIn) return '/home';
      return null;
    },
  );
});
