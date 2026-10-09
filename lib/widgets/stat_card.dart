import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool dark;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = AppColors.navy,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? AppColors.navy : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: dark ? const Color(0xFF8FA6B3) : AppColors.grey,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: dark ? Colors.white : valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
