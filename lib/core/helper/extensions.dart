import 'package:flutter/material.dart';

// Router Extension
extension RouterExtension on BuildContext {
  // Push named route
  Future<T?> toNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  // Replace current route
  Future<T?> offNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushReplacementNamed<T, dynamic>(
      routeName,
      arguments: arguments,
    );
  }

  // Clear stack and navigate
  Future<T?> offAllNamed<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  // Pop current route
  void pop<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }

  // Check if can pop
  bool canPop() {
    return Navigator.of(this).canPop();
  }
}

// String Extension
extension StringExtension on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String limitTo(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

// List Extension
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
}
