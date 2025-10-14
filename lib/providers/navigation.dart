import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State for navigation
class NavigationState {
  final int currentIndex;

  NavigationState({this.currentIndex = 0});

  NavigationState copyWith({int? currentIndex}) {
    return NavigationState(currentIndex: currentIndex ?? this.currentIndex);
  }
}

/// Navigation notifier to handle navigation state changes
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(NavigationState());

  /// Sets the current tab index
  void setCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  /// Gets the current tab index
  int get currentIndex => state.currentIndex;
}

/// Provider for navigation state
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier();
    });
