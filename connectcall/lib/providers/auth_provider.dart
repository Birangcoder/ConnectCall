import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/calling_service.dart';
import '../services/presence_service.dart';
import '../services/user_service.dart';
import 'user_provider.dart';

// -----------------------------------------------------------------------------
// AUTH SERVICE
// -----------------------------------------------------------------------------

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// -----------------------------------------------------------------------------
// AUTH STATE
// -----------------------------------------------------------------------------

final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);

  return authService.authStateChanges;
});

// -----------------------------------------------------------------------------
// AUTH SESSION INITIALIZER
// -----------------------------------------------------------------------------

final authSessionProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) async {
    final user = next.asData?.value;

    if (user == null) {
      return;
    }

    try {
      final userService = ref.read(userServiceProvider);

      final profile = await userService.getUser(user.uid);

      if (profile == null) {
        return;
      }

      // Start Realtime Database presence.
      await PresenceService.instance.startPresence();

      // Initialize ZEGOCLOUD Call Invitation.
      await CallingService.instance.connect(profile);
    } catch (_) {
      // Authentication itself is already successful.
      // Calling/presence initialization can be retried by the app lifecycle.
    }
  });
});

// -----------------------------------------------------------------------------
// AUTH FORM STATE
// -----------------------------------------------------------------------------

class AuthFormState {
  final bool isLoading;
  final String? errorMessage;

  const AuthFormState({this.isLoading = false, this.errorMessage});

  AuthFormState copyWith({bool? isLoading, String? errorMessage}) {
    return AuthFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// -----------------------------------------------------------------------------
// AUTH FORM CONTROLLER
// -----------------------------------------------------------------------------

class AuthFormController extends StateNotifier<AuthFormState> {
  final AuthService _authService;

  AuthFormController(this._authService) : super(const AuthFormState());

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authService.login(email: email, password: password);

      state = state.copyWith(isLoading: false);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthService.messageForError(e),
      );

      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _authService.register(name: name, email: email, password: password);

      state = state.copyWith(isLoading: false);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AuthService.messageForError(e),
      );

      return false;
    }
  }
}

// -----------------------------------------------------------------------------
// AUTH FORM PROVIDER
// -----------------------------------------------------------------------------

final authFormControllerProvider =
    StateNotifierProvider<AuthFormController, AuthFormState>((ref) {
      return AuthFormController(ref.watch(authServiceProvider));
    });
