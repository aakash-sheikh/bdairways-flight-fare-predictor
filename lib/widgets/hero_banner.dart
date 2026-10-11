import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'brand_logo.dart';

/// Top banner of the predictor page.
class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 720;
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B5382), AppColors.deepNavy],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -20,
            child: Opacity(
              opacity: 0.08,
              child: PlaneMark(size: narrow ? 170 : 280),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(narrow ? 20 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BANGLADESH DOMESTIC AVIATION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: AppColors.amber,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Estimate your flight fare in seconds',
                  style: TextStyle(
                    fontSize: narrow ? 24 : 34,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 560),
                  child: Text(
                    'Machine-learning fare estimates for US-Bangla, Biman, '
                    'Air Astra and NovoAir, built from 3,618 real bookings.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFFBFD9E3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _Pill(value: 'R\u00b2 0.890', label: 'Random Forest (paper)'),
                    _Pill(value: '3,618', label: 'bookings'),
                    _Pill(value: '4 \u00b7 8', label: 'airlines \u00b7 airports'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String value;
  final String label;
  const _Pill({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFFBFD9E3)),
          ),
        ],
      ),
    );
  }
}