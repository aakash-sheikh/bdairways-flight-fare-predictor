import 'dart:math' as math;
import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'brand_logo.dart';

/// Landing animation:
/// 1. the globe fades in at the center and spins up,
/// 2. the plane flies around it on its orbit (behind and in front of the
///    globe) leaving a golden contrail,
/// 3. the whole logo flies to the header corner and lands on the header logo.
/// Tap anywhere to skip.
class IntroSplash extends StatefulWidget {
  final VoidCallback onDone;
  const IntroSplash({super.key, required this.onDone});

  @override
  State<IntroSplash> createState() => _IntroSplashState();
}

class _IntroSplashState extends State<IntroSplash>
    with SingleTickerProviderStateMixin {
  static const double _startSize = 170;
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onDone();
      })
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Progress of [t] between [a] and [b], eased and clamped to 0..1.
  double _seg(double t, double a, double b, [Curve curve = Curves.linear]) {
    return curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final size = box.biggest;
        final start = Offset(size.width / 2, size.height / 2 - 40);
        final end = Brand.headerLogoCenter(size.width);
        final control = Offset(
          end.dx + (start.dx - end.dx) * 0.7,
          end.dy + 20,
        );

        Offset bez(double t) {
          final u = 1 - t;
          return Offset(
            u * u * start.dx + 2 * u * t * control.dx + t * t * end.dx,
            u * u * start.dy + 2 * u * t * control.dy + t * t * end.dy,
          );
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _c.animateTo(
            1.0,
            duration: const Duration(milliseconds: 250),
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value;

              final fadeIn = _seg(t, 0.0, 0.16);
              final pop = _seg(t, 0.0, 0.24, Curves.easeOutCubic);
              final spin = 2.4 * (1 - _seg(t, 0.0, 0.52, Curves.easeOutCubic));

              // Plane: grows in, loops 1.15 times around the globe, rests.
              final loop = _seg(t, 0.08, 0.52, Curves.easeInOutCubic);
              final phase = kRestPhase + 2 * math.pi * 1.15 * (1 - loop);
              final planeScale = _seg(t, 0.06, 0.16, Curves.easeOut);
              final trail = 1.3 * math.sin(math.pi * loop);

              // Whole logo flies to the header corner.
              final flight = _seg(t, 0.58, 0.95, Curves.easeInOutCubic);
              final bgOpacity = 1 - _seg(t, 0.58, 0.92);
              final textOpacity =
                  _seg(t, 0.06, 0.22) * (1 - _seg(t, 0.50, 0.62));

              final pos = bez(flight);
              final logoSize =
                  lerpDouble(_startSize, Brand.logoSize, flight)! *
                      (0.7 + 0.3 * pop);
              final tilt = -math.sin(math.pi * flight) * 0.30;

              return Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: AppColors.bg.withOpacity(bgOpacity)),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: start.dy + _startSize / 2 + 26,
                    child: Opacity(
                      opacity: textOpacity,
                      child: Column(
                        children: [
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 34,
                                letterSpacing: 1.2,
                                decoration: TextDecoration.none,
                              ),
                              children: [
                                TextSpan(
                                  text: 'BD',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.navy,
                                  ),
                                ),
                                TextSpan(
                                  text: 'Airways',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: Color(0xFF1565B5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'FLIGHT FARE STUDY \u00b7 BANGLADESH',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 2.4,
                              color: AppColors.grey,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: pos.dx - logoSize / 2,
                    top: pos.dy - logoSize / 2,
                    child: Transform.rotate(
                      angle: tilt,
                      child: Opacity(
                        opacity: fadeIn,
                        child: BrandLogo(
                          size: logoSize,
                          planePhase: phase,
                          spin: spin,
                          planeScale: planeScale,
                          trail: trail,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
