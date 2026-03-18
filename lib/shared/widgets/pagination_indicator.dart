import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PaginationIndicator extends StatelessWidget {
  final int totalCount;
  final int currentIndex;

  const PaginationIndicator({
    super.key,
    required this.totalCount,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFFEEEEEE),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
