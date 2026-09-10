import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../data/models/driver_model.dart';

class DriverArrivedDialog extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback onStartTrip;

  const DriverArrivedDialog({
    super.key,
    required this.driver,
    required this.onStartTrip,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassContainer(
        blur: 24,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Arrived badge
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryEmerald.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryEmerald, width: 2),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryEmerald,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            Text('Driver Has Arrived!', style: AppTypography.heading2),
            const SizedBox(height: 6),
            Text(
              '${driver.name} is waiting at your pickup spot in ${driver.carModel}',
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // OTP Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  Text('SHARE PIN WITH DRIVER', style: AppTypography.caption.copyWith(letterSpacing: 1.5)),
                  const SizedBox(height: 6),
                  Text(
                    driver.otp,
                    style: AppTypography.heading1.copyWith(
                      letterSpacing: 8,
                      color: AppColors.primaryEmerald,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: 'Start Journey to Destination',
              onPressed: onStartTrip,
              icon: Icons.navigation_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
