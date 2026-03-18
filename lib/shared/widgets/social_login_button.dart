import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SocialLoginButton extends StatelessWidget {
  final Widget icon; // Đổi sang Widget để dùng FaIcon, Image.asset linh hoạt
  final String text;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64, // Increased height for premium feel
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFEEEEEE)), // Light border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100), // Pill shape
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 24), // Sát lề trái
                child: icon,
              ),
            ),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16, // Increased font size
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F1F1F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
