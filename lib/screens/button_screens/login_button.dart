import 'package:flutter/material.dart';
class LoginButton extends StatelessWidget {
  final Widget icon;
  final String text;
  final VoidCallback onPressed;

  const LoginButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
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
