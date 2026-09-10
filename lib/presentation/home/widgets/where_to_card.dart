import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../providers/booking_provider.dart';

class WhereToCard extends StatelessWidget {
  final Function(bool isPickup) onTap;

  const WhereToCard({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();

    return GlassContainer(
      blur: 24,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Plan your ride',
            style: AppTypography.heading2,
          ),
          const SizedBox(height: 14),

          InkWell(
            onTap: () => onTap(true),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardSurfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.radio_button_checked_rounded, color: AppColors.primaryEmerald, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pickup', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                        Text(
                          booking.pickupLocation.name,
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.only(left: 25.0, top: 4, bottom: 4),
            child: Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textMuted),
          ),

          InkWell(
            onTap: () => onTap(false),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardSurfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: AppColors.accentCoral, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dropoff', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                        Text(
                          booking.dropLocation?.name ?? 'Where to?',
                          style: AppTypography.bodyMedium.copyWith(
                            color: booking.dropLocation != null ? AppColors.textPrimary : AppColors.textMuted, 
                            fontWeight: FontWeight.bold
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
