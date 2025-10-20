// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupButton extends StatelessWidget {
  const SignupButton({super.key});

  Future<void> _signInWithProvider(
    BuildContext context,
    OAuthProvider provider,
  ) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.auth.signInWithOAuth(
        provider,
        redirectTo: 'io.supabase.flutter://login-callback', // change if needed
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              _buildSocialButton(
                icon: SvgPicture.asset(
                  'assets/svg/Apple.svg',
                  height: 20,
                  width: 20,
                ),
                text: 'Continue with Apple',
                onPressed:
                    () => _signInWithProvider(context, OAuthProvider.apple),
              ),
              _buildSocialButton(
                icon: SvgPicture.asset(
                  'assets/svg/Facebook.svg',
                  height: 20,
                  width: 20,
                ),
                text: 'Continue with Facebook',
                onPressed:
                    () => _signInWithProvider(context, OAuthProvider.facebook),
              ),
              _buildSocialButton(
                icon: SvgPicture.asset(
                  'assets/svg/Google.svg',
                  height: 20,
                  width: 20,
                ),
                text: 'Continue with Google',
                onPressed:
                    () => _signInWithProvider(context, OAuthProvider.google),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required Widget icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: icon,
          label: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.black12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
