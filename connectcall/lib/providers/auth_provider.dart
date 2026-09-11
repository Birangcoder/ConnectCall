import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

/// Singleton AuthService instance available to the whole app.
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Streams the current Firebase auth state (null = logged out).
/// The splash/router uses this to decide Login vs Home.
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

/// Simple loading/error state for the login & register forms.
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

final authFormControllerProvider =
    StateNotifierProvider<AuthFormController, AuthFormState>((ref) {
  return AuthFormController(ref.watch(authServiceProvider));
});
