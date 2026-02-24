import 'package:flutter/material.dart';

class AuthAuthenticationOption extends StatelessWidget {
  const AuthAuthenticationOption({
    super.key,
    required this.text,
    required this.action,
    required this.onPressed,
  });

  final String text;
  final String action;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(color: Colors.grey),
          children: [
            const TextSpan(
              text: '  ',
            ),
            TextSpan(
              text: action,
              style: const TextStyle(
                color: Color(0xff189ad3),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
