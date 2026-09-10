import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../data/models/trip_model.dart';

class RideDetailSheet extends StatelessWidget {
  final TripModel trip;

  const RideDetailSheet({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = trip.status == TripStatus.completed;

    return GlassContainer(
      blur: 24,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
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

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trip Details', style: AppTypography.heading2),
              Text(
                '₹${trip.fare.toStringAsFixed(0)}',
                style: AppTypography.heading2.copyWith(color: AppColors.primaryEmerald),
              ),
            ],
          ),
          Text(trip.formattedDate, style: AppTypography.caption),
          const SizedBox(height: 16),

          // Route card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.radio_button_checked, size: 14, color: AppColors.primaryEmerald),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pickup', style: AppTypography.caption),
                          Text(trip.pickup.name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                        ],
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Drop Destination', style: AppTypography.caption),
                          Text(trip.drop.name, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Fare breakdown
          Text('Fare Breakdown', style: AppTypography.heading3),
          const SizedBox(height: 10),
          _ReceiptRow(label: 'Base Fare', amount: '₹${trip.fareBreakdown.baseFare.toStringAsFixed(0)}'),
          const SizedBox(height: 6),
          _ReceiptRow(label: 'Distance Fare (${trip.distanceKm} km)', amount: '₹${trip.fareBreakdown.distanceFare.toStringAsFixed(0)}'),
          const SizedBox(height: 6),
          _ReceiptRow(label: 'Taxes & Tolls', amount: '₹${trip.fareBreakdown.taxes.toStringAsFixed(0)}'),
          const SizedBox(height: 6),
          _ReceiptRow(label: 'Payment Method', amount: trip.paymentMethod, color: AppColors.primaryEmerald),
          const SizedBox(height: 20),

          // Download invoice / Close
          CustomButton(
            text: isCompleted ? 'Download Tax Invoice (PDF)' : 'Close',
            isOutlined: !isCompleted,
            icon: isCompleted ? Icons.receipt_long_rounded : null,
            onPressed: () {
              Navigator.pop(context);
              if (isCompleted) {
                Fluttertoast.showToast(
                  msg: 'Tax invoice downloaded successfully!',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String amount;
  final Color? color;

  const _ReceiptRow({
    required this.label,
    required this.amount,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodySmall),
        Text(
          amount,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
