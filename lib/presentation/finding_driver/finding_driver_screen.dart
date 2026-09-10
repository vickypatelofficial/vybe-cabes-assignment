import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/glass_container.dart';
import '../../data/models/trip_model.dart';
import '../../providers/booking_provider.dart';
import '../../providers/tracking_provider.dart';
import '../live_tracking/live_tracking_screen.dart';
import 'widgets/radar_ripple_widget.dart';

class FindingDriverScreen extends StatefulWidget {
  const FindingDriverScreen({super.key});

  @override
  State<FindingDriverScreen> createState() => _FindingDriverScreenState();
}

class _FindingDriverScreenState extends State<FindingDriverScreen> {
  bool _navigatedToTracking = false;

  @override
  Widget build(BuildContext context) {
    final tracking = context.watch<TrackingProvider>();
    final booking = context.watch<BookingProvider>();

    // Auto navigate when driver is assigned & arrives
    if ((tracking.tripStatus == TripStatus.driverArriving ||
            tracking.tripStatus == TripStatus.driverAssigned) &&
        !_navigatedToTracking &&
        tracking.driver != null) {
      _navigatedToTracking = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LiveTrackingScreen()),
        );
      });
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.darkMidnight,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                // Top header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Connecting Ride', style: AppTypography.heading2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        booking.selectedRideOption?.name ?? 'Vybe Cab',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primaryEmerald,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // Animated Radar Sonar
                const RadarRippleWidget(size: 280),
                const SizedBox(height: 36),

                // Live status text
                Text(
                  'Finding your Vybe Driver',
                  style: AppTypography.heading1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  tracking.searchStatusText,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.primaryEmerald),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Pickup & Drop Summary Card
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.radio_button_checked, size: 14, color: AppColors.primaryEmerald),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              booking.pickupLocation.name,
                              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: AppColors.cardBorder, height: 1),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: AppColors.accentCoral),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              booking.dropLocation?.name ?? 'Destination',
                              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Cancel Ride Button
                CustomButton(
                  text: 'Cancel Request',
                  isOutlined: true,
                  backgroundColor: AppColors.accentCoral,
                  textColor: AppColors.accentCoral,
                  onPressed: () {
                    tracking.cancelBooking();
                    booking.clearDestination();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
