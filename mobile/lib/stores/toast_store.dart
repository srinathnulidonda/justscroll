// lib/stores/toast_store.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ToastType { success, error, warning, info }

class ToastData {
  final int id;
  final String title;
  final String? description;
  final ToastType type;
  final int duration;

  const ToastData({
    required this.id,
    required this.title,
    this.description,
    this.type = ToastType.info,
    this.duration = 3500,
  });
}

class ToastNotifier extends StateNotifier<List<ToastData>> {
  int _nextId = 0;

  ToastNotifier() : super([]);

  void show({
    required String title,
    String? description,
    ToastType type = ToastType.info,
    int duration = 3500,
  }) {
    final id = ++_nextId;
    final toast = ToastData(
      id: id,
      title: title,
      description: description,
      type: type,
      duration: duration,
    );
    // Keep max 3 visible
    state = [
      ...state.length > 2 ? state.sublist(state.length - 2) : state,
      toast,
    ];
    if (duration > 0) {
      Timer(Duration(milliseconds: duration), () => remove(id));
    }
  }

  void remove(int id) {
    state = state.where((t) => t.id != id).toList();
  }

  void success(String title, {String? description}) =>
      show(title: title, description: description, type: ToastType.success, duration: 2500);

  void error(String title, {String? description}) =>
      show(title: title, description: description, type: ToastType.error, duration: 4000);

  void warning(String title, {String? description}) =>
      show(title: title, description: description, type: ToastType.warning, duration: 3500);

  void info(String title, {String? description}) =>
      show(title: title, description: description, type: ToastType.info, duration: 3000);
}

final toastProvider = StateNotifierProvider<ToastNotifier, List<ToastData>>(
  (ref) => ToastNotifier(),
);