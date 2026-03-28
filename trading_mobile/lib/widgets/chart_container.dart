import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/design_system.dart';

/// Full-width chart placeholder with candlestick-style decoration (no heavy chart lib).
class ChartContainer extends StatelessWidget {
  const ChartContainer({
    super.key,
    required this.title,
    this.subtitle,
    this.height = 220,
  });

  final String title;
  final String? subtitle;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _ChartGridPainter()),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(
                        'LIVE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
                const Spacer(),
                CustomPaint(
                  size: Size(double.infinity, height * 0.38),
                  painter: _SparklinePainter(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _LegendDot(color: AppColors.buy, label: 'Buy zone'),
                    const SizedBox(width: 12),
                    _LegendDot(color: AppColors.sell, label: 'Sell zone'),
                    const Spacer(),
                    Icon(Icons.touch_app_rounded, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Pinch & pan — connect data feed',
                      style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                    ),
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

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ChartGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = AppColors.chartGrid
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(42);
    final points = <Offset>[];
    const segments = 48;
    var y = size.height * 0.55;
    for (var i = 0; i <= segments; i++) {
      final x = size.width * (i / segments);
      y += (rnd.nextDouble() - 0.48) * 7;
      y = y.clamp(size.height * 0.2, size.height * 0.85);
      points.add(Offset(x, y));
    }

    final line = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, line);

    final fill = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      fill.lineTo(points[i].dx, points[i].dy);
    }
    fill.lineTo(points.last.dx, size.height);
    fill.close();

    final gradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.22),
          AppColors.primary.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(fill, gradient);

    final cPaint = Paint();
    for (var i = 0; i < points.length; i += 6) {
      final up = rnd.nextBool();
      cPaint.color = up ? AppColors.buy : AppColors.sell;
      final h = 6 + rnd.nextDouble() * 10;
      final o = points[i];
      canvas.drawRect(Rect.fromCenter(center: o, width: 3.2, height: h), cPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
