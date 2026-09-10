import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../data/models/driver_model.dart';
import '../../../providers/tracking_provider.dart';

class DriverBottomCard extends StatelessWidget {
  final DriverModel driver;
  final VoidCallback onCancel;

  const DriverBottomCard({
    super.key,
    required this.driver,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final tracking = context.watch<TrackingProvider>();

    return GlassContainer(
      blur: 24,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tracking.isTripInProgress
                        ? 'Heading to Destination'
                        : tracking.hasDriverArrived
                            ? 'Driver is Waiting at Pickup'
                            : 'Driver Arriving in ~${tracking.driverEtaMinutes} mins',
                    style: AppTypography.heading3.copyWith(
                      color: tracking.hasDriverArrived ? AppColors.primaryEmerald : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    tracking.isTripInProgress
                        ? 'Estimated arrival in ${tracking.driverEtaMinutes} mins'
                        : 'Hyundai Verna · White',
                    style: AppTypography.caption,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryEmerald.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Text('PIN', style: AppTypography.caption.copyWith(fontSize: 9, fontWeight: FontWeight.bold)),
                    Text(
                      driver.otp,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primaryEmerald,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryEmerald.withValues(alpha: 0.2),
                  child: Text(
                    driver.name.isNotEmpty ? driver.name[0].toUpperCase() : 'D',
                    style: AppTypography.heading2.copyWith(color: AppColors.primaryEmerald),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(driver.name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryEmerald.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 12, color: AppColors.primaryEmerald),
                                const SizedBox(width: 2),
                                Text(
                                  '${driver.rating}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.primaryEmerald,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${driver.vehiclePlate} · ${driver.totalTrips} rides',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  icon: const Icon(Icons.phone_rounded, color: AppColors.primaryEmerald, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryEmerald.withValues(alpha: 0.12),
                  ),
                  onPressed: () {
                    Fluttertoast.showToast(
                      msg: 'Calling ${driver.name} (${driver.phone})...',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.shield_outlined, size: 18, color: AppColors.accentCyan),
                  label: Text('Safety Shield', style: AppTypography.bodySmall.copyWith(color: AppColors.accentCyan)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.accentCyan.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Fluttertoast.showToast(
                      msg: 'Safety Toolkit active: GPS tracking & emergency assistance',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.accentCoral),
                  label: Text('Cancel Ride', style: AppTypography.bodySmall.copyWith(color: AppColors.accentCoral)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.accentCoral.withValues(alpha: 0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onCancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
