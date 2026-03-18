import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/smartify_logo.dart';
import '../../../shared/widgets/gradient_spinner.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final bool loggedIn = await AuthService.isLoggedIn();
    if (loggedIn) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            const SmartifyLogo(
              size: 120,
              backgroundColor: Colors.white,
              iconColor: AppColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Smartify',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(flex: 2),
            const SizedBox(
              width: 56,
              height: 56,
              child: GradientSpinner(size: 56),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
