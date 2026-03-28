// lib/stores/auth_store.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:justscroll/lib/api.dart';
import 'package:justscroll/models/user.dart';

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final bool isAuthenticated;
  final bool isInitialized;

  const AuthState({
    this.user,
    this.isLoading = true,
    this.isAuthenticated = false,
    this.isInitialized = false,
  });

  AuthState copyWith({AppUser? user, bool? isLoading, bool? isAuthenticated, bool? isInitialized}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    initialize();
  }

  Future<void> initialize() async {
    if (state.isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final userJson = prefs.getString('user_data');

    if (token != null && userJson != null) {
      try {
        final user = AppUser.fromJson(jsonDecode(userJson));
        state = AuthState(user: user, isAuthenticated: true, isLoading: false, isInitialized: true);
      } catch (_) {
        await _clearStorage();
        state = const AuthState(isLoading: false, isInitialized: true);
      }
    } else {
      state = const AuthState(isLoading: false, isInitialized: true);
    }
  }

  Future<void> login(String username, String password) async {
    final data = await ApiClient.instance.login(username: username, password: password);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', data['access_token']);
    await prefs.setString('refresh_token', data['refresh_token']);
    final user = AppUser(username: username);
    await prefs.setString('user_data', jsonEncode(user.toJson()));
    state = AuthState(user: user, isAuthenticated: true, isLoading: false, isInitialized: true);
  }

  Future<void> register(String username, String email, String password) async {
    final data = await ApiClient.instance.register(username: username, email: email, password: password);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', data['access_token']);
    await prefs.setString('refresh_token', data['refresh_token']);
    final user = AppUser(username: username, email: email);
    await prefs.setString('user_data', jsonEncode(user.toJson()));
    state = AuthState(user: user, isAuthenticated: true, isLoading: false, isInitialized: true);
  }

  Future<void> logout() async {
    await _clearStorage();
    state = const AuthState(isLoading: false, isInitialized: true);
  }

  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_data');
  }
}

final authStoreProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());