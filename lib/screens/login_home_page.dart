import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:retail_demand/app_colors.dart';
import 'package:retail_demand/screens/button_screens/login_button.dart';
import 'package:retail_demand/screens/email_input_screen.dart'; 


class LoginHomePage extends StatelessWidget {
  const LoginHomePage({super.key});

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
        title: Text(
          "Log into account",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Welcome back! To Retail Demand System',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 450,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EmailInputScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Continue with email'),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'or',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Using the extracted SocialButton widget
                  LoginButton(
                    icon: SvgPicture.asset(
                      'assets/svg/Apple.svg',
                      height: 20,
                      width: 20,
                    ),
                    text: 'Continue with Apple',
                    onPressed: () {}, // Implement Apple Auth
                  ),
                  LoginButton(
                    icon: SvgPicture.asset(
                      'assets/svg/Facebook.svg',
                      height: 20,
                      width: 20,
                    ),
                    text: 'Continue with Facebook',
                    onPressed: () {}, // Implement Facebook Auth
                  ),
                  LoginButton(
                    icon: SvgPicture.asset(
                      'assets/svg/Google.svg',
                      height: 20,
                      width: 20,
                    ),
                    text: 'Continue with Google',
                    onPressed: () {}, // Implement Google Auth
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text("Already have an account? Log in"),
                    ),
                  ),
                  Spacer(),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'By using Classroom, you agree to the ',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        children: [
                          TextSpan(
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
                          TextSpan(
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
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
