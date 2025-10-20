// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_colors.dart';

final isHoveredProvider = StateProvider<bool>((ref) => false);
final isLoadingProvider = StateProvider<bool>((ref) => false);
final resetEmailProvider = StateProvider<String>((ref) => "");

class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHovered = ref.watch(isHoveredProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final email = ref.watch(resetEmailProvider);

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "We will email you\na link to reset your password.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Email",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 5),
            TextField(
              onChanged:
                  (value) =>
                      ref.read(resetEmailProvider.notifier).state =
                          value.trim(),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: "example@example.com",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            MouseRegion(
              onEnter: (_) => ref.read(isHoveredProvider.notifier).state = true,
              onExit: (_) => ref.read(isHoveredProvider.notifier).state = false,
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed:
                      isLoading
                          ? null
                          : () async {
                            if (!RegExp(
                              r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
                            ).hasMatch(email)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please enter a valid email."),
                                ),
                              );
                              return;
                            }

                            ref.read(isLoadingProvider.notifier).state = true;

                            try {
                              await Supabase.instance.client.auth
                                  .resetPasswordForEmail(email);
                              showDialog(
                                context: context,
                                builder:
                                    (_) => AlertDialog(
                                      title: const Text("Success"),
                                      content: Text(
                                        "A reset link has been sent to $email",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error: ${e.toString()}"),
                                ),
                              );
                            } finally {
                              ref.read(isLoadingProvider.notifier).state =
                                  false;
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isLoading
                            ? Colors.purple.shade300
                            : (isHovered
                                ? Colors.purple.shade300
                                : AppColors.primary),
                    disabledBackgroundColor: Colors.purple.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child:
                      isLoading
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Sending...",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          )
                          : const Text(
                            "Send",
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: ' and ',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    const TextSpan(
                      text: 'Privacy Policy.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
