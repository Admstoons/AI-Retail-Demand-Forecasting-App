// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../provider/password_provider.dart';
import '../app_colors.dart';
import 'account_created_scereen.dart';

class CreatePasswordScreen extends ConsumerStatefulWidget {
  final String email;

  const CreatePasswordScreen({super.key, required this.email});

  @override
  ConsumerState<CreatePasswordScreen> createState() =>
      _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends ConsumerState<CreatePasswordScreen> {
  late final TextEditingController passwordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final obscureText = ref.watch(obscureTextProvider);
    final isHovered = ref.watch(isHoveredProvider);
    final strength = ref.watch(strengthProvider);
    final strengthColor = ref.watch(strengthColorProvider);

    final hasMinLength = ref.watch(hasMinLengthProvider);
    final hasNumber = ref.watch(hasNumberProvider);
    final hasSymbol = ref.watch(hasSymbolProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create your password 2 / 2",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepIndicator(),
            const SizedBox(height: 30),

            const Text("Password", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 5),

            TextField(
              controller: passwordController,
              obscureText: obscureText,
              onChanged: (value) => updatePasswordStrength(ref, value),
              decoration: InputDecoration(
                hintText: "Enter password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    ref.read(obscureTextProvider.notifier).state = !obscureText;
                  },
                ),
              ),
            ),

            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: strength,
              backgroundColor: Colors.grey.shade300,
              color: strengthColor,
              minHeight: 5,
            ),
            const SizedBox(height: 20),

            Column(
              children: [
                _buildRequirementRow("8 characters minimum", hasMinLength),
                const SizedBox(height: 4),
                _buildRequirementRow("a number", hasNumber),
                const SizedBox(height: 4),
                _buildRequirementRow("one symbol minimum", hasSymbol),
              ],
            ),

            const SizedBox(height: 30),
            _buildSignUpButton(
              context,
              passwordController,
              ref,
              strength,
              isHovered,
            ),

            const Spacer(),
            _termsAndPrivacy(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _stepIndicator() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 4, width: 20, color: Colors.purple),
          const SizedBox(width: 5),
          Container(height: 4, width: 20, color: Colors.purple),
        ],
      ),
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isMet ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.black)),
      ],
    );
  }

  Widget _buildSignUpButton(
    BuildContext context,
    TextEditingController controller,
    WidgetRef ref,
    double strength,
    bool isHovered,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: MouseRegion(
        onEnter: (_) => ref.read(isHoveredProvider.notifier).state = true,
        onExit: (_) => ref.read(isHoveredProvider.notifier).state = false,
        child: ElevatedButton(
          onPressed:
              (strength == 1.0 && !_isLoading)
                  ? () async {
                    setState(() => _isLoading = true);
                    final password = controller.text.trim();
                    final supabase = Supabase.instance.client;

                    try {
                      final response = await supabase.auth.signUp(
                        email: widget.email,
                        password: password,
                      );

                      if (response.user != null) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const AccountCreatedScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Signup failed.")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Error: $e")));
                    } finally {
                      if (mounted) setState(() => _isLoading = false);
                    }
                  }
                  : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: isHovered ? Colors.deepPurple : Colors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child:
              _isLoading
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text(
                    "Create Account",
                    style: TextStyle(color: Colors.white),
                  ),
        ),
      ),
    );
  }

  Widget _termsAndPrivacy() {
    return Center(
      child: Text.rich(
        TextSpan(
          text: 'By using this app, you agree to the ',
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
    );
  }
}
