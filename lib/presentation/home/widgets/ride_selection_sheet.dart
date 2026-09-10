import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../data/models/ride_option_model.dart';
import '../../../providers/booking_provider.dart';

class RideSelectionSheet extends StatelessWidget {
  final VoidCallback onBookRide;

  const RideSelectionSheet({
    super.key,
    required this.onBookRide,
  });

  @override
  Widget build(BuildContext context) {
    final booking = context.watch<BookingProvider>();
    final selectedOption = booking.selectedRideOption;

    return GlassContainer(
      blur: 24,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.4)),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Rides',
                style: AppTypography.heading3,
              ),
              if (booking.routeDistanceKm != null && booking.estimatedMinutes != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryEmerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryEmerald.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${booking.routeDistanceKm!.toStringAsFixed(1)} km · ~${booking.estimatedMinutes} min',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primaryEmerald,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: booking.availableRideOptions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final option = booking.availableRideOptions[index];
                final isSelected = selectedOption?.id == option.id;
                final fare = booking.getCalculatedFare(option);

                return _RideOptionCard(
                  option: option,
                  fare: fare,
                  isSelected: isSelected,
                  onTap: () => booking.selectRideOption(option),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              InkWell(
                onTap: () => _showPaymentMethodSelector(context, booking),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        booking.selectedPaymentMethod == 'Cash'
                            ? Icons.money_rounded
                            : booking.selectedPaymentMethod == 'UPI'
                                ? Icons.qr_code_rounded
                                : Icons.credit_card_rounded,
                        color: AppColors.primaryEmerald,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        booking.selectedPaymentMethod,
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: CustomButton(
                  text: selectedOption != null
                      ? 'Book ${selectedOption.name} · ₹${booking.getCalculatedFare(selectedOption)}'
                      : 'Select a Ride',
                  onPressed: selectedOption != null ? onBookRide : null,
                  icon: Icons.electric_bolt_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodSelector(BuildContext context, BookingProvider booking) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final methods = [
          {'name': 'UPI / GPay / PhonePe', 'id': 'UPI', 'icon': Icons.qr_code_rounded},
          {'name': 'Credit / Debit Card', 'id': 'Card', 'icon': Icons.credit_card_rounded},
          {'name': 'Vybe Wallet (₹850.00)', 'id': 'Wallet', 'icon': Icons.account_balance_wallet_rounded},
          {'name': 'Cash on Arrival', 'id': 'Cash', 'icon': Icons.money_rounded},
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Payment Method', style: AppTypography.heading3),
                const SizedBox(height: 16),
                ...methods.map((method) {
                  final isSelected = booking.selectedPaymentMethod == method['id'];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        method['icon'] as IconData,
                        color: AppColors.primaryEmerald,
                      ),
                    ),
                    title: Text(
                      method['name'] as String,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryEmerald)
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    selected: isSelected,
                    selectedTileColor: AppColors.primaryEmerald.withValues(alpha: 0.08),
                    onTap: () {
                      booking.setPaymentMethod(method['id'] as String);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RideOptionCard extends StatelessWidget {
  final RideOptionModel option;
  final int fare;
  final bool isSelected;
  final VoidCallback onTap;

  const _RideOptionCard({
    required this.option,
    required this.fare,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 130,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryEmerald.withValues(alpha: 0.12) : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primaryEmerald : AppColors.cardBorder,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryEmerald.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  option.iconEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, size: 10, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Text(
                        '${option.capacity}',
                        style: AppTypography.caption.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.name,
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primaryEmerald : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  option.etaMin,
                  style: AppTypography.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
            Text(
              '₹$fare',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primaryEmerald : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}