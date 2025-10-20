// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../app_colors.dart';
import 'create_password_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;

  const VerifyEmailScreen({super.key, required this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late final StreamSubscription<AuthState> _authSub;
  bool isVerifying = false; // Tracks if verification is in progress

  @override
  void initState() {
    super.initState();

    /// Listen for auth state change (magic link auto-login)
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) async {
      final session = data.session;
      if (session != null && mounted) {
        final user = Supabase.instance.client.auth.currentUser;

        // Optional: Refresh session just in case
        await Supabase.instance.client.auth.refreshSession();

        if (user?.emailConfirmedAt != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePasswordScreen(email: widget.email),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _authSub.cancel(); // Clean up listener
    super.dispose();
  }

  Future<void> _checkIfVerified() async {
    setState(() => isVerifying = true);

    try {
      await Supabase.instance.client.auth.refreshSession();

      final user = Supabase.instance.client.auth.currentUser;
      if (!mounted) return;

      if (user != null && user.emailConfirmedAt != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreatePasswordScreen(email: widget.email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email not verified yet. Please check your inbox."),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    if (mounted) setState(() => isVerifying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Verify your email 2 / 3",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            /// Step Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(height: 5, width: 30, color: Colors.purple),
                const SizedBox(width: 5),
                Container(height: 5, width: 30, color: Colors.purple),
                const SizedBox(width: 5),
                Container(height: 5, width: 30, color: Colors.grey.shade300),
              ],
            ),
            const SizedBox(height: 30),

            Text(
              "We’ve sent a confirmation email to:\n\n${widget.email}\n\nPlease check your inbox and click the link to verify your email.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: isVerifying ? null : _checkIfVerified,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    isVerifying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("I’ve Verified My Email"),
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("Go Back to Start"),
            ),

            const Spacer(),

            Center(
              child: Text.rich(
                TextSpan(
                  text: 'By using Classroom, you agree to the ',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    const TextSpan(
                      text: 'Terms',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: ' and ',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const TextSpan(
                      text: 'Privacy Policy.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
