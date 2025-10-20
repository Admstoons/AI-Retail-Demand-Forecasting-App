import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_colors.dart';

final isHoveredProvider = StateProvider<bool>((ref) => false);

class ResetPasswordConfirmationScreen extends ConsumerWidget {
  final String email;

  const ResetPasswordConfirmationScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovered = ref.watch(isHoveredProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Reset password",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Image.asset("assets/images/email.jpg", height: 150),
            const SizedBox(height: 20),
            const Text(
              "We have sent an email to",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            Text(
              email.isNotEmpty ? email : "your email address",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const Text(
              "with instructions to reset your password.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: MouseRegion(
                onEnter:
                    (_) => ref.read(isHoveredProvider.notifier).state = true,
                onExit:
                    (_) => ref.read(isHoveredProvider.notifier).state = false,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isHovered ? Colors.purple.shade300 : AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Back to login",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          // ...existing code...
            const Spacer(),
            Center(
              child: Text.rich(
                TextSpan(
                  text: 'By using Retail Demand, you agree to the ',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Implement Terms navigation
                        },
                        child: const Text(
                          'Terms',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    TextSpan(
                      text: ' and ',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Implement Privacy Policy navigation
                        },
                        child: const Text(
                          'Privacy Policy.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            // ...existing code...
          ],
        ),
      ),
    );
  }
}
