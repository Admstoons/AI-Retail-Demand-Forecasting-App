import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retail_demand/provider/login_provider.dart';
import 'package:retail_demand/provider/password_provider.dart';
import 'package:retail_demand/screens/reset_password_screen.dart';
import '../app_colors.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(loginStateProvider);
    final loginNotifier = ref.read(loginStateProvider.notifier);
    final obscureText = ref.watch(obscureTextProvider);

    final email = ref.watch(emailProvider);
    final password = ref.watch(passwordProvider);
    final isButtonEnabled = email.isNotEmpty && password.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          "Log into account",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight,
          ),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Email", style: TextStyle(color: Colors.black)),
                  const SizedBox(height: 5),
                  TextField(
                    onChanged:
                        (value) =>
                            ref.read(emailProvider.notifier).state = value,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "example@gmail.com",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(10),
                      //   borderSide: const BorderSide(
                      //     color: Colors.grey,
                      //     width: 2,
                      //   ),
                      // ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text("Password", style: TextStyle(color: Colors.black)),
                  const SizedBox(height: 5),
                  TextField(
                    obscureText: obscureText,
                    onChanged:
                        (value) =>
                            ref.read(passwordProvider.notifier).state = value,
                    decoration: InputDecoration(
                      hintText: "Enter password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      // focusedBorder: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(10),
                      //   borderSide: const BorderSide(
                      //     color: Colors.grey,
                      //     width: 2,
                      //   ),
                      // ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          ref.read(obscureTextProvider.notifier).state =
                              !obscureText;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed:
                          isButtonEnabled && !isLoading
                              ? () => loginNotifier.login(context)
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isLoading
                                ? Colors.purple.shade300
                                : isButtonEnabled
                                ? Colors.deepPurple
                                : Colors.purple.shade200,
                        disabledBackgroundColor: Colors.purple.shade200,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          isLoading
                              ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Logging in...",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              )
                              : const Text(
                                "Log in",
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ResetPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'By using Retail Demand, you agree to the ',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
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
          ),
        ),
      ),
    );
  }
}
