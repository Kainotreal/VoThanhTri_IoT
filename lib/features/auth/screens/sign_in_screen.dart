import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/social_login_button.dart';
import '../../../shared/widgets/custom_text_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Sign in...",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Simulate network request
    Future.delayed(const Duration(seconds: 2), () async {
      if (mounted) {
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        // Kiểm tra đăng nhập (bao gồm cả tài khoản admin mặc định)
        final isValid = await AuthService.validateLogin(email, password);

        if (isValid) {
          if (email == AuthService.adminEmail) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Logged in as Admin 🛡️")),
            );
          }
          
          Navigator.pop(context); // Close dialog
          context.go(AppRoutes.home);
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid credentials")),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Welcome Back",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F1F1F),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("👋", style: TextStyle(fontSize: 32)),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Your Smart Home, Your Rules.",
                style: TextStyle(color: Color(0xFF757575), fontSize: 14),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _emailController,
                label: "Email",
                hintText: "Email",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _passwordController,
                label: "Password",
                hintText: "Password",
                prefixIcon: Icons.lock_outline,
                isPassword: true,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.forgotPassword),
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Color(0xFF757575), fontSize: 14)),
                  GestureDetector(
                    onTap: () => context.pushReplacement(AppRoutes.signUp),
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Row(
                children: [
                  Expanded(child: Divider(color: Color(0xFFEEEEEE))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("or", style: TextStyle(color: Color(0xFF757575))),
                  ),
                  Expanded(child: Divider(color: Color(0xFFEEEEEE))),
                ],
              ),
              const SizedBox(height: 32),
              SocialLoginButton(
                icon: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.blue, Colors.red, Colors.yellow, Colors.green],
                    stops: [0.25, 0.5, 0.75, 1.0],
                  ).createShader(bounds),
                  child: const FaIcon(FontAwesomeIcons.google, size: 24, color: Colors.white),
                ),
                text: 'Continue with Google',
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              SocialLoginButton(
                icon: const FaIcon(FontAwesomeIcons.apple, size: 24, color: Colors.black),
                text: 'Continue with Apple',
                onPressed: () {},
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                text: 'Sign in',
                onPressed: _showLoadingDialog,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
