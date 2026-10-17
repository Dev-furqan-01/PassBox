import 'package:flutter/material.dart';
import '../../models/security_metrics.dart';

/// Password Strength Overview Card with colorful pie chart
class WebStrengthOverviewCard extends StatelessWidget {
  final SecurityMetrics metrics;

  const WebStrengthOverviewCard({
    super.key,
    required this.metrics,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate percentages for pie chart
    final total = metrics.analyzedNodes > 0 ? metrics.analyzedNodes : 1;
    final weakPercent = (metrics.weakPasswords / total * 100).round();
    final reusedPercent = (metrics.reusedPasswords / total * 100).round();
    final strongPercent = 100 - weakPercent - reusedPercent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D7377).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: Color(0xFF0D7377),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'PASSWORD STRENGTH',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Pie Chart and Legend
          Expanded(
            child: Row(
              children: [
                // Pie Chart
                Expanded(
                  child: CustomPaint(
                    size: const Size(120, 120),
                    painter: _PieChartPainter(
                      strongPercent: strongPercent,
                      weakPercent: weakPercent,
                  reusedPercent: reusedPercent,
                ),
              ),
                ),
                const SizedBox(width: 24),
                // Legend
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendItem(
                        color: const Color(0xFF0D7377),
                        label: 'Strong',
                        percent: strongPercent,
                      ),
                      const SizedBox(height: 12),
                      _LegendItem(
                        color: const Color(0xFFF59E0B),
                        label: 'Weak',
                        percent: weakPercent,
                      ),
                      const SizedBox(height: 12),
                      _LegendItem(
                        color: const Color(0xFF64748B),
                        label: 'Reused',
                        percent: reusedPercent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int percent;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
            ),
          ),
        ),
        Text(
          '$percent%',
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final int strongPercent;
  final int weakPercent;
  final int reusedPercent;

  _PieChartPainter({
    required this.strongPercent,
    required this.weakPercent,
    required this.reusedPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final strongAngle = (strongPercent / 100) * 2 * 3.14159;
    final weakAngle = (weakPercent / 100) * 2 * 3.14159;
    final reusedAngle = (reusedPercent / 100) * 2 * 3.14159;

    double startAngle = -1.5708; // Start from top

    // Draw Strong segment (teal)
    if (strongPercent > 0) {
      final paint = Paint()
        ..color = const Color(0xFF0D7377)
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        strongAngle,
        true,
        paint,
      );
      startAngle += strongAngle;
    }

    // Draw Weak segment (orange)
    if (weakPercent > 0) {
      final paint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        weakAngle,
        true,
        paint,
      );
      startAngle += weakAngle;
    }

    // Draw Reused segment (slate)
    if (reusedPercent > 0) {
      final paint = Paint()
        ..color = const Color(0xFF64748B)
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        reusedAngle,
        true,
        paint,
      );
    }

    // Draw center circle (donut chart effect)
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.6, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
