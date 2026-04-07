import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/social_login_button.dart';

import '../../../shared/widgets/smartify_logo.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              const SmartifyLogo(
                size: 80,
                backgroundColor: AppColors.primary,
                iconColor: Colors.white,
              ),
              const SizedBox(height: 32),
              Text(
                "Let's Get Started!",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                "Let's dive in into your account",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
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
              const SizedBox(height: 16),
              SocialLoginButton(
                icon: const FaIcon(FontAwesomeIcons.facebook, size: 24, color: Color(0xFF1877F2)),
                text: 'Continue with Facebook',
                onPressed: () {},
              ),
              const SizedBox(height: 16),
              SocialLoginButton(
                icon: const FaIcon(FontAwesomeIcons.twitter, size: 24, color: Color(0xFF1DA1F2)),
                text: 'Continue with Twitter',
                onPressed: () {},
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Sign up', // Lower case u
                onPressed: () => context.push(AppRoutes.signUp),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  onPressed: () => context.push(AppRoutes.signIn),
                  child: const Text('Sign in', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
              const Text.rich(
                TextSpan(
                  text: "Privacy Policy",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  children: [
                    TextSpan(text: "  -  "),
                    TextSpan(text: "Terms of Service"),
                  ]
                )
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
