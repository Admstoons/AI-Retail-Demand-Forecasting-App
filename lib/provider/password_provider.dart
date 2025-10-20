import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// Providers for password visibility and button hover state
final obscureTextProvider = StateProvider<bool>((ref) => true);
final isHoveredProvider = StateProvider<bool>((ref) => false);

// Password strength tracking
final strengthProvider = StateProvider<double>((ref) => 0.0);
final strengthColorProvider = StateProvider<Color>((ref) => Colors.grey);

// Password validation conditions
final hasMinLengthProvider = StateProvider<bool>((ref) => false);
final hasNumberProvider = StateProvider<bool>((ref) => false);
final hasSymbolProvider = StateProvider<bool>((ref) => false);

// Function to check password strength
void updatePasswordStrength(WidgetRef ref, String password) {
  bool hasMinLength = password.length >= 8;
  bool hasNumber = password.contains(RegExp(r'[0-9]'));
  bool hasSymbol = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

  // Update individual condition states
  ref.read(hasMinLengthProvider.notifier).state = hasMinLength;
  ref.read(hasNumberProvider.notifier).state = hasNumber;
  ref.read(hasSymbolProvider.notifier).state = hasSymbol;

  // Calculate strength based on conditions met
  double strength = (hasMinLength ? 0.33 : 0) +
      (hasNumber ? 0.33 : 0) +
      (hasSymbol ? 0.34 : 0);

  // Update strength indicator color
  ref.read(strengthProvider.notifier).state = strength;
  if (strength == 1.0) {
    ref.read(strengthColorProvider.notifier).state = Colors.green;
  } else if (strength >= 0.66) {
    ref.read(strengthColorProvider.notifier).state = Colors.orange;
  } else {
    ref.read(strengthColorProvider.notifier).state = Colors.red;
  }
}
