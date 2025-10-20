import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final obscureTextProvider = StateProvider<bool>((ref) => true);
final isHoveredProvider = StateProvider<bool>((ref) => false);
final strengthProvider = StateProvider<double>((ref) => 0.0);
final strengthColorProvider = StateProvider<Color>((ref) => Colors.grey);

void updateStrength(WidgetRef ref, String password) {
  bool hasNumber = password.contains(RegExp(r'[0-9]'));
  bool hasSymbol = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

  if (hasSymbol) {
    ref.read(strengthProvider.notifier).state = 1.0;
    ref.read(strengthColorProvider.notifier).state = Colors.green;
  } else if (hasNumber) {
    ref.read(strengthProvider.notifier).state = 0.5;
    ref.read(strengthColorProvider.notifier).state = Colors.orange;
  } else {
    ref.read(strengthProvider.notifier).state = 0.0;
    ref.read(strengthColorProvider.notifier).state = Colors.grey;
  }
}
