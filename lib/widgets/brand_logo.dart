import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Layout numbers shared by the header and the intro animation, so the
/// flying logo lands exactly on the header logo.
class Brand {
  static const double maxWidth = 1100;
  static const double headerHeight = 68;
  static const double logoSize = 40;
  static const double padX = 20;

  /// Center of the header logo for a given screen width.
  static Offset headerLogoCenter(double screenWidth) {
    final left = math.max(0.0, (screenWidth - maxWidth) / 2);
    return Offset(left + padX + logoSize / 2, headerHeight / 2);
  }
}

/// Where the plane rests on its orbit (radians). The intro animation
/// ends here so it matches the static logo.
const double kRestPhase = 2.2;

/// Upper outline of the plane (nose pointing right) in a 100 x 100 box.
/// The lower outline is the mirror image.
const _planeTop = [
  Offset(74, 45.5),
  Offset(62, 44.5),
  Offset(40, 12),
  Offset(31, 12),
  Offset(45, 44),
  Offset(27, 43.5),
  Offset(17, 32),
  Offset(11, 32),
  Offset(14, 47),
];

/// Full plane silhouette.
Path planePath(Size size) {
  final sx = size.width / 100;
  final sy = size.height / 100;
  final path = Path()..moveTo(96 * sx, 50 * sy);
  for (final o in _planeTop) {
    path.lineTo(o.dx * sx, o.dy * sy);
  }
  for (final o in _planeTop.reversed) {
    path.lineTo(o.dx * sx, (100 - o.dy) * sy);
  }
  path.close();
  return path;
}

/// One half of the plane, split along the fuselage (for the 3D fold).
Path planeHalf(Size size, bool upper) {
  final sx = size.width / 100;
  final sy = size.height / 100;
  final path = Path()..moveTo(96 * sx, 50 * sy);
  for (final o in _planeTop) {
    path.lineTo(o.dx * sx, (upper ? o.dy : 100 - o.dy) * sy);
  }
  path.lineTo(14 * sx, 50 * sy);
  path.close();
  return path;
}

/// The BDAirways mark: a glass globe with a Dhaka marker, a tapered orbit
/// ring and a plane. The plane's position, the globe's spin and the
/// contrail can be animated; the defaults are the resting logo.
class BrandLogo extends StatelessWidget {
  final double size;
  final double planePhase;
  final double spin;
  final double planeScale;
  final double trail;

  const BrandLogo({
    super.key,
    this.size = 40,
    this.planePhase = kRestPhase,
    this.spin = 0,
    this.planeScale = 1,
    this.trail = 0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MarkPainter(
          phase: planePhase,
          spin: spin,
          planeScale: planeScale,
          trail: trail,
        ),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  final double phase;
  final double spin;
  final double planeScale;
  final double trail;

  const _MarkPainter({
    required this.phase,
    required this.spin,
    required this.planeScale,
    required this.trail,
  });

  static const double _tilt = -0.45; // orbit tilt
  static const double _roll = -0.30; // globe axis roll
  static const double _view = 0.38; // viewing angle from above

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final g = Offset(w * 0.5, w * 0.5);
    final r = w * 0.29;
    final oa = w * 0.47;
    final ob = w * 0.17;
    final pa = w * 0.46;
    final pb = w * 0.158;

    final front = math.sin(phase) > 0;

    _orbit(canvas, g, w, oa, ob, back: true);
    _trail(canvas, g, w, pa, pb, front: false);
    if (!front) _plane(canvas, g, w, pa, pb);
    _globe(canvas, g, r, w);
    _orbit(canvas, g, w, oa, ob, back: false);
    _trail(canvas, g, w, pa, pb, front: true);
    if (front) _plane(canvas, g, w, pa, pb);
  }

  Offset _orbitPoint(Offset g, double a, double b, double phi) {
    final lx = a * math.cos(phi);
    final ly = b * math.sin(phi);
    final c = math.cos(_tilt);
    final s = math.sin(_tilt);
    return g + Offset(lx * c - ly * s, lx * s + ly * c);
  }

  void _orbit(Canvas canvas, Offset g, double w, double oa, double ob,
      {required bool back}) {
    canvas.save();
    canvas.translate(g.dx, g.dy);
    canvas.rotate(_tilt);
    canvas.clipRect(
      back
          ? Rect.fromLTRB(-w, -w, w, 0)
          : Rect.fromLTRB(-w, 0, w, w),
    );
    final outer = Path()
      ..addOval(Rect.fromCenter(
          center: Offset.zero, width: oa * 2, height: ob * 2));
    final inner = Path()
      ..addOval(Rect.fromCenter(
          center: Offset(w * 0.012, -w * 0.02),
          width: w * 0.455 * 2,
          height: w * 0.145 * 2));
    final ring = Path.combine(PathOperation.difference, outer, inner);
    final a = back ? 0.55 : 1.0;
    canvas.drawPath(
      ring,
      Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF0B3D7A).withOpacity(a),
            const Color(0xFF1AA7D8).withOpacity(a),
            const Color(0xFFF2B45A).withOpacity(a),
          ],
        ).createShader(Rect.fromLTRB(-oa, -ob, oa, ob)),
    );
    canvas.restore();
  }

  void _trail(Canvas canvas, Offset g, double w, double pa, double pb,
      {required bool front}) {
    if (trail <= 0 || planeScale <= 0) return;
    const n = 24;
    for (var i = 0; i <= n; i++) {
      final k = i / n;
      final phi = phase + trail * k;
      if ((math.sin(phi) > 0) != front) continue;
      final p = _orbitPoint(g, pa, pb, phi);
      final alpha = 0.7 * math.pow(1 - k, 1.5) * planeScale;
      canvas.drawCircle(
        p,
        w * (0.010 * (1 - k) + 0.004),
        Paint()..color = const Color(0xFFF2B45A).withOpacity(alpha.toDouble()),
      );
    }
  }

  void _plane(Canvas canvas, Offset g, double w, double pa, double pb) {
    if (planeScale <= 0) return;
    final p = _orbitPoint(g, pa, pb, phase);
    final s = w * 0.21 * (1 + 0.22 * math.sin(phase)) * planeScale;
    final heading =
        _tilt + math.atan2(-pb * math.cos(phase), pa * math.sin(phase));
    final ps = Size(s, s);
    final bounds = Rect.fromLTWH(0, 0, s, s);

    void place(Offset at, void Function() draw) {
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.rotate(heading);
      canvas.translate(-s / 2, -s / 2);
      draw();
      canvas.restore();
    }

    // Soft shadow.
    place(p + Offset(s * 0.04, s * 0.07), () {
      canvas.drawPath(
        planePath(ps),
        Paint()
          ..color = const Color(0x66061A38)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.012),
      );
    });

    place(p, () {
      canvas.drawPath(
        planeHalf(ps, true),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFCFE8FF)],
          ).createShader(bounds),
      );
      canvas.drawPath(
        planeHalf(ps, false),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8FBDEE), Color(0xFF3E78BF)],
          ).createShader(bounds),
      );
      canvas.drawLine(
        Offset(s * 0.96, s * 0.5),
        Offset(s * 0.14, s * 0.5),
        Paint()
          ..color = const Color(0x99FFFFFF)
          ..strokeWidth = s * 0.012,
      );
      canvas.drawPath(
        planePath(ps),
        Paint()
          ..color = const Color(0xCCFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.018
          ..strokeJoin = StrokeJoin.round,
      );
    });
  }

  /// Orthographic projection of (lat, lon) on the globe. Returns the screen
  /// point and the depth (positive = facing the viewer).
  (Offset, double) _project(Offset g, double r, double lat, double lon) {
    final lp = lon + spin;
    final x = r * math.cos(lat) * math.sin(lp);
    final y1 = r * math.sin(lat);
    final z1 = r * math.cos(lat) * math.cos(lp);
    final zp = z1 * math.cos(_view) + y1 * math.sin(_view);
    final yp = y1 * math.cos(_view) - z1 * math.sin(_view);
    final dx = x;
    final dy = -yp;
    final c = math.cos(_roll);
    final s = math.sin(_roll);
    return (g + Offset(dx * c - dy * s, dx * s + dy * c), zp);
  }

  void _globe(Canvas canvas, Offset g, double r, double w) {
    final circle = Rect.fromCircle(center: g, radius: r);

    // Glass sphere: bright top-left, deep blue bottom-right.
    canvas.drawCircle(
      g,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.4, -0.5),
          radius: 0.8,
          colors: [Color(0xFF48B8EE), Color(0xFF1565B5), Color(0xFF0A2A55)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(circle),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(circle));

    // Wireframe: only the half facing the viewer is drawn.
    final wire = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.009
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xA6D8F6FF);
    final bold = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xA6D8F6FF);

    void drawLine(List<double> lats, List<double> lons, Paint paint) {
      final path = Path();
      var pen = false;
      for (var i = 0; i < lats.length; i++) {
        final (p, z) = _project(g, r, lats[i], lons[i]);
        if (z > 0) {
          if (!pen) {
            path.moveTo(p.dx, p.dy);
            pen = true;
          } else {
            path.lineTo(p.dx, p.dy);
          }
        } else {
          pen = false;
        }
      }
      canvas.drawPath(path, paint);
    }

    // Meridians (every 30 degrees).
    for (var k = 0; k < 12; k++) {
      final lon = k * math.pi / 6;
      final lats = <double>[];
      final lons = <double>[];
      for (var d = -90; d <= 90; d += 6) {
        lats.add(d * math.pi / 180);
        lons.add(lon);
      }
      drawLine(lats, lons, wire);
    }
    // Parallels.
    for (final la in const [-60, -30, 0, 30, 60]) {
      final lats = <double>[];
      final lons = <double>[];
      for (var d = -180; d <= 180; d += 6) {
        lats.add(la * math.pi / 180);
        lons.add(d * math.pi / 180);
      }
      drawLine(lats, lons, la == 0 ? bold : wire);
    }

    // Dhaka marker, turning with the globe.
    final (mp, mz) = _project(g, r, 0.415, 0.55);
    if (mz > 0.05 * r) {
      canvas.drawCircle(
        mp,
        r * 0.16,
        Paint()
          ..shader = const RadialGradient(
            colors: [Color(0x99E5483B), Color(0x00E5483B)],
          ).createShader(Rect.fromCircle(center: mp, radius: r * 0.16)),
      );
      canvas.drawCircle(mp, r * 0.055, Paint()..color = const Color(0xFFE5483B));
      canvas.drawCircle(
        mp,
        r * 0.055,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white
          ..strokeWidth = w * 0.006,
      );
    }

    // Glass highlight, top-left.
    canvas.save();
    canvas.translate(g.dx - 0.32 * r, g.dy - 0.45 * r);
    canvas.rotate(-0.55);
    final hl = Rect.fromCenter(
        center: Offset.zero, width: 1.5 * r, height: 0.85 * r);
    canvas.drawOval(
      hl,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x73FFFFFF), Color(0x00FFFFFF)],
        ).createShader(hl),
    );
    canvas.restore();

    canvas.restore();

    // Glass rim.
    canvas.drawCircle(
      g,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.012
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xE6FFFFFF), Color(0x1AFFFFFF), Color(0x66FFFFFF)],
        ).createShader(circle),
    );
  }

  @override
  bool shouldRepaint(covariant _MarkPainter old) =>
      old.phase != phase ||
      old.spin != spin ||
      old.planeScale != planeScale ||
      old.trail != trail;
}

/// Plain plane silhouette, used as a faint watermark.
class PlaneMark extends StatelessWidget {
  final double size;
  final Color color;
  const PlaneMark({super.key, required this.size, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PlanePainter(color)),
    );
  }
}

class _PlanePainter extends CustomPainter {
  final Color color;
  const _PlanePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.66);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.drawPath(planePath(size), Paint()..color = color);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PlanePainter oldDelegate) =>
      oldDelegate.color != color;
}
