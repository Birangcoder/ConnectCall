import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/profile/blocked_users_screen.dart';
import '../screens/profile/user_profile_screen.dart';
import '../screens/splash/splash_screen.dart';

/// Shared navigator key.
///
/// ZEGOCLOUD Call Invitation Service must use the same navigator key
/// as GoRouter so that incoming call UI can be displayed correctly.
final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',

    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

      GoRoute(
        path: '/blocked-users',
        builder: (context, state) {
          return const BlockedUsersScreen();
        },
      ),

      GoRoute(
        path: '/user-profile',
        builder: (context, state) {
          final user = state.extra as UserModel;

          return UserProfileScreen(user: user);
        },
      ),
    ],

    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final user = authState.asData?.value;

      final location = state.matchedLocation;

      final isAuthPage = location == '/login' || location == '/register';

      final isSplash = location == '/splash';

      if (isLoading) {
        return isSplash ? null : '/splash';
      }

      if (user == null) {
        return isAuthPage ? null : '/login';
      }

      if (isSplash || isAuthPage) {
        return '/home';
      }

      return null;
    },
  );
});
