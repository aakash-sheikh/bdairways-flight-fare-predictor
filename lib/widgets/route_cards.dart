import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/predict_service.dart';
import '../theme/app_theme.dart';

class _Route {
  final String from;
  final String to;
  const _Route(this.from, this.to);
}

// Routes found in the dataset. Sylhet (ZYL) only appears as a departure
// airport in the data, so that card runs Sylhet to Dhaka.
const _routes = [
  _Route('DAC', 'CXB'),
  _Route('DAC', 'JSR'),
  _Route('DAC', 'CGP'),
  _Route('ZYL', 'DAC'),
  _Route('DAC', 'BZL'),
  _Route('DAC', 'SPD'),
  _Route('DAC', 'RJH'),
];

// code: [city, airport name]
const _airports = {
  'DAC': ['Dhaka', 'Hazrat Shahjalal International Airport'],
  'CXB': ["Cox's Bazar", "Cox's Bazar Airport"],
  'JSR': ['Jashore', 'Jashore Airport'],
  'CGP': ['Chattogram', 'Shah Amanat International Airport'],
  'ZYL': ['Sylhet', 'Osmani International Airport'],
  'BZL': ['Barisal', 'Barisal Airport'],
  'SPD': ['Saidpur', 'Saidpur Airport'],
  'RJH': ['Rajshahi', 'Shah Makhdum Airport'],
};

/// "Popular domestic routes": tap a card to fill in the predictor.
class RouteCards extends StatelessWidget {
  final void Function(String from, String to) onSelect;
  const RouteCards({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            const Text(
              'Popular domestic routes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.navy,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'DOMESTIC',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Tap a route to fill in the predictor and see the estimated fare.',
          style: TextStyle(fontSize: 14, color: AppColors.grey),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, box) {
            final cols = box.maxWidth >= 900 ? 3 : (box.maxWidth >= 560 ? 2 : 1);
            const gap = 14.0;
            final cardW = (box.maxWidth - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final r in _routes)
                  SizedBox(
                    width: cardW,
                    child: _RouteCard(
                      route: r,
                      onTap: () => onSelect(r.from, r.to),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        const Text(
          'Fares shown are estimates from the linear model for an Economy seat '
          'on US-Bangla Airlines, booked 30 days ahead in the regular season.',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
}

class _RouteCard extends StatelessWidget {
  final _Route route;
  final VoidCallback onTap;
  const _RouteCard({required this.route, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final from = _airports[route.from]!;
    final to = _airports[route.to]!;
    final fare = PredictService.estimate(
      source: route.from,
      destination: route.to,
      cabinClass: 'Economy',
      airline: 'US-Bangla Airlines',
      seasonality: 'Regular',
      days: 30,
      duration: 1.1,
    );
    final price = NumberFormat('#,###').format(fare.round());

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _end(from[0], from[1], route.from, false)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE6F0FB),
                        shape: BoxShape.circle,
                      ),
                      child: Transform.rotate(
                        angle: math.pi / 2,
                        child: const Icon(Icons.flight,
                            size: 16, color: Color(0xFF1565B5)),
                      ),
                    ),
                  ),
                  Expanded(child: _end(to[0], to[1], route.to, true)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.line),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Est. from ',
                      style: TextStyle(fontSize: 12, color: AppColors.grey)),
                  Text(
                    'BDT $price',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Predict',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1565B5),
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      size: 18, color: Color(0xFF1565B5)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _end(String city, String airport, String code, bool right) {
    final align = right ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final ta = right ? TextAlign.right : TextAlign.left;
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          city,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: ta,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          airport,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: ta,
          style: const TextStyle(fontSize: 12.5, color: AppColors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          code,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: Color(0xFF8A97A3),
          ),
        ),
      ],
    );
  }
}
