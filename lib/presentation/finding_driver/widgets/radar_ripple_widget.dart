import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RadarRippleWidget extends StatefulWidget {
  final double size;

  const RadarRippleWidget({super.key, this.size = 280.0});

  @override
  State<RadarRippleWidget> createState() => _RadarRippleWidgetState();
}

class _RadarRippleWidgetState extends State<RadarRippleWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _RadarPainter(_controller.value),
            child: Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryEmerald.withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: AppColors.darkMidnight,
                  size: 38,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;

  _RadarPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Draw 3 expanding wave rings
    for (int i = 0; i < 3; i++) {
      final double waveProgress = (progress + (i / 3)) % 1.0;
      final double radius = maxRadius * waveProgress;
      final double opacity = (1.0 - waveProgress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = AppColors.primaryEmerald.withValues(alpha: opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => oldDelegate.progress != progress;
}
