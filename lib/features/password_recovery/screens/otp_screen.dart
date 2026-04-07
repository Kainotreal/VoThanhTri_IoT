import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/primary_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp = '';

  Widget _buildOtpDigit(String digit, bool isFocused) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? AppColors.primary : const Color(0xFFEEEEEE),
          width: isFocused ? 2.0 : 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1F1F1F),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', '<'],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: keys.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                return InkWell(
                  onTap: () {
                    if (key == '<') {
                      if (_otp.isNotEmpty) {
                        setState(() => _otp = _otp.substring(0, _otp.length - 1));
                      }
                    } else if (key != '*') {
                      if (_otp.length < 4) {
                        setState(() => _otp += key);
                        if (_otp.length == 4) {
                          // Auto navigate when filled
                          Future.delayed(const Duration(milliseconds: 300), () {
                            if (mounted) context.push(AppRoutes.secureAccount);
                          });
                        }
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 70,
                    height: 70,
                    alignment: Alignment.center,
                    child: key == '<'
                        ? const Icon(Icons.backspace_outlined, size: 28, color: Color(0xFF1F1F1F))
                        : Text(
                            key,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F1F1F),
                            ),
                          ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text(
                    "Enter OTP Code 🔐",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Please check your email inbox for a message from Smartify. Enter the one-time verification code below.",
                    style: TextStyle(
                      color: Color(0xFF757575),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(4, (index) {
                      final isFocused = _otp.length == index;
                      return _buildOtpDigit(
                        index < _otp.length ? _otp[index] : '',
                        isFocused,
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Color(0xFF757575), fontSize: 16),
                            children: [
                              const TextSpan(text: "You can resend the code in "),
                              TextSpan(
                                text: "56",
                                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                              const TextSpan(text: " seconds"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Resend code",
                            style: TextStyle(
                              color: Color(0xFF757575),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _buildKeyboard(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
