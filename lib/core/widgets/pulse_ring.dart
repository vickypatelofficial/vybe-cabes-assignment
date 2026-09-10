import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class PulseRing extends StatefulWidget {
  final double size;
  final Color color;

  const PulseRing({
    super.key,
    this.size = 200.0,
    this.color = AppColors.primaryEmerald,
  });

  @override
  State<PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<PulseRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Wave 1
            Transform.scale(
              scale: 0.5 + (_controller.value * 0.5),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withValues(alpha: (1.0 - _controller.value).clamp(0.0, 1.0) * 0.6),
                    width: 2,
                  ),
                ),
              ),
            ),
            // Wave 2
            Transform.scale(
              scale: 0.2 + (_controller.value * 0.8),
              child: Container(
                width: widget.size * 0.8,
                height: widget.size * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withValues(alpha: (1.0 - _controller.value).clamp(0.0, 1.0) * 0.3),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
