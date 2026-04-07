import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/primary_button.dart';

class WellDoneScreen extends StatelessWidget {
  const WellDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary, size: 28),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Checkmark Illustration with dots
              Center(
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Floating dots
                      Positioned(top: 20, left: 40, child: _Dot(size: 12, color: AppColors.primary)),
                      Positioned(top: 100, left: 10, child: _Dot(size: 6, color: AppColors.primary)),
                      Positioned(top: 150, left: 50, child: _Dot(size: 8, color: AppColors.primary)),
                      Positioned(bottom: 20, left: 100, child: _Dot(size: 5, color: AppColors.primary)),
                      Positioned(top: 40, right: 30, child: _Dot(size: 4, color: AppColors.primary)),
                      Positioned(top: 120, right: 10, child: _Dot(size: 4, color: AppColors.primary)),
                      Positioned(bottom: 60, right: 20, child: _Dot(size: 4, color: AppColors.primary)),
                      Positioned(top: 50, right: 80, child: _Dot(size: 8, color: AppColors.primary)),

                      // Main Circle
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 50),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                "Well Done!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F1F1F),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Congratulations! Your home is now a Smartify haven. Start exploring and managing your smart space with ease.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Get Started',
                onPressed: () => context.go(AppRoutes.home),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final double size;
  final Color color;
  const _Dot({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
    );
  }
}
