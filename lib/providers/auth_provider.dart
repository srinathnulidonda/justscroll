import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_app/services/firebase_service.dart';

/// State for the authentication
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Clear error state
  AuthState clearError() {
    return AuthState(user: user, isLoading: isLoading, error: null);
  }
}

/// Auth notifier handling authentication operations
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseService _firebaseService;

  AuthNotifier(this._firebaseService) : super(AuthState()) {
    // Initialize by checking current authentication state
    _initialize();
  }

  // Initialize auth state from firebase
  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true);
      final currentUser = _firebaseService.getCurrentUser();
      state = state.copyWith(user: currentUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize authentication: ${e.toString()}',
      );
    }
  }

  // Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final user = await _firebaseService.signInWithEmailAndPassword(
        email,
        password,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to sign in: ${e.toString()}',
      );
      return false;
    }
  }

  // Sign up with email and password
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final user = await _firebaseService.signUpWithEmailAndPassword(
        email,
        password,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to sign up: ${e.toString()}',
      );
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _firebaseService.signOut();
      state = state.copyWith(user: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to sign out: ${e.toString()}',
      );
      throw Exception(e);
    }
  }

  // Clear any error messages
  void clearError() {
    state = state.clearError();
  }
}

// Provider for firebase service
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// Provider for authentication state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return AuthNotifier(firebaseService);
});
