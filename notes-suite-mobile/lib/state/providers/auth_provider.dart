import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user.dart';
import '../../data/services/auth_service.dart';

/// Auth State
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _checkAuthStatus();
  }

  // Check if user is logged in
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final user = await _authService.getCurrentUser();
      state = AuthState(
        user: user,
        isAuthenticated: user != null,
        isLoading: false,
      );

      // Si l'utilisateur est connecté, déclencher un sync initial
      if (user != null) {
        // Note: Le sync sera fait dans NotesNotifier.init()
      }
    } catch (e) {
      state = AuthState(isLoading: false, error: e.toString());
    }
  }

  // Register
  Future<bool> register(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.register(email, password);

      if (response.success) {
        final user = User(
          email: email,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        );

        state = AuthState(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Registration failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.login(email, password);


      if (response.success) {
        final user = User(
          email: email,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
        );

        state = AuthState(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Login failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthService.instance);
});