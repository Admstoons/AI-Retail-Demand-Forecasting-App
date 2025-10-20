// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

/// Providers to manage email & password input fields
final emailProvider = StateProvider<String>((ref) => "");
final passwordProvider = StateProvider<String>((ref) => "");

/// StateNotifier to manage login loading state
final loginStateProvider = StateNotifierProvider<LoginStateNotifier, bool>(
  (ref) => LoginStateNotifier(ref),
);

class LoginStateNotifier extends StateNotifier<bool> {
  final Ref ref;

  LoginStateNotifier(this.ref) : super(false);

  Future<void> login(BuildContext context) async {
    final email = ref.read(emailProvider);
    final password = ref.read(passwordProvider);

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar(context, "Please fill in both fields.");
      return;
    }

    state = true; // Start loading

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.auth
          .signInWithPassword(email: email, password: password)
          .timeout(const Duration(seconds: 15));

      if (response.user != null) {
        _showSnackbar(context, "Login successful.");
        // TODO: Navigate to home screen
        Navigator.pushReplacementNamed(context, '/dashboard'); // or your route
      } else {
        _showSnackbar(context, "Invalid credentials.");
      }
    } on TimeoutException {
      _showSnackbar(context, "Login timed out. Please check your connection.");
    } on AuthException catch (e) {
      _showSnackbar(context, e.message);
    } catch (e) {
      _showSnackbar(context, "Unexpected error occurred.");
    } finally {
      state = false; // End loading
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
