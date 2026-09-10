import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/glass_container.dart';
import '../../providers/booking_provider.dart';
import '../../providers/tracking_provider.dart';
import '../home/home_screen.dart';
import '../ride_history/ride_history_screen.dart';
import 'widgets/star_rating_widget.dart';
import 'widgets/tip_selector.dart';

class TripCompletedScreen extends StatefulWidget {
  const TripCompletedScreen({super.key});

  @override
  State<TripCompletedScreen> createState() => _TripCompletedScreenState();
}

class _TripCompletedScreenState extends State<TripCompletedScreen> {
  int _selectedRating = 5;
  int _selectedTip = 0;
  final Set<String> _selectedCompliments = {};
  final TextEditingController _feedbackController = TextEditingController();

  final List<String> _compliments = [
    'Clean Car ✨',
    'Polite Driver 🤝',
    'Smooth Driving 🚗',
    'Great Music 🎵',
    'On Time ⏱️',
    'Safe Journey 🛡️',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracking = context.watch<TrackingProvider>();
    final booking = context.watch<BookingProvider>();
    final driver = tracking.driver;
    final trip = tracking.currentTrip;

    final double fare = trip?.fare ?? (booking.selectedRideOption != null ? booking.getCalculatedFare(booking.selectedRideOption!).toDouble() : 250.0);
    final double baseFare = (fare * 0.35).roundToDouble();
    final double distanceFare = (fare * 0.50).roundToDouble();
    final double taxes = (fare * 0.15).roundToDouble();
    final double totalFare = fare + _selectedTip;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.darkMidnight,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Success Badge Header
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: AppColors.primaryEmerald.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryEmerald, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.35),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.primaryEmerald,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 16),
                Text('You have arrived!', style: AppTypography.heading1),
                const SizedBox(height: 4),
                Text(
                  'Hope you enjoyed your ride with Vybe',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),

                // Itemized Receipt Card
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Trip Fare Breakdown', style: AppTypography.heading3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryEmerald.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              booking.selectedPaymentMethod,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primaryEmerald,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ReceiptRow(label: 'Base Fare', amount: '₹$baseFare'),
                      const SizedBox(height: 8),
                      _ReceiptRow(
                        label: 'Distance & Time Fare (${booking.routeDistanceKm?.toStringAsFixed(1) ?? "5.2"} km)',
                        amount: '₹$distanceFare',
                      ),
                      const SizedBox(height: 8),
                      _ReceiptRow(label: 'Taxes & Tolls (GST 18%)', amount: '₹$taxes'),
                      if (_selectedTip > 0) ...[
                        const SizedBox(height: 8),
                        _ReceiptRow(
                          label: 'Driver Tip',
                          amount: '₹$_selectedTip',
                          color: AppColors.primaryEmerald,
                        ),
                      ],
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: AppColors.cardBorder, height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Paid', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            '₹${totalFare.toStringAsFixed(0)}',
                            style: AppTypography.heading2.copyWith(color: AppColors.primaryEmerald),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Rate your Driver Card
                if (driver != null)
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(driver.photoUrl),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Rate ${driver.name}',
                                    style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${driver.carModel} · ${driver.vehiclePlate}',
                                    style: AppTypography.caption,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        StarRatingWidget(
                          initialRating: _selectedRating,
                          onRatingChanged: (rating) {
                            setState(() => _selectedRating = rating);
                          },
                        ),
                        const SizedBox(height: 16),
                        // Compliments wrap
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: _compliments.map((compliment) {
                            final isSelected = _selectedCompliments.contains(compliment);
                            return FilterChip(
                              label: Text(compliment),
                              selected: isSelected,
                              selectedColor: AppColors.primaryEmerald.withValues(alpha: 0.2),
                              checkmarkColor: AppColors.primaryEmerald,
                              backgroundColor: AppColors.cardSurface,
                              side: BorderSide(
                                color: isSelected ? AppColors.primaryEmerald : AppColors.cardBorder,
                              ),
                              labelStyle: AppTypography.caption.copyWith(
                                color: isSelected ? AppColors.primaryEmerald : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedCompliments.add(compliment);
                                  } else {
                                    _selectedCompliments.remove(compliment);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        // Tip Driver Selector
                        TipSelector(
                          selectedTip: _selectedTip,
                          onTipSelected: (tip) {
                            setState(() => _selectedTip = tip);
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // Primary & Secondary Buttons
                CustomButton(
                  text: 'Submit & Return Home',
                  onPressed: () {
                    // Reset booking & tracking
                    tracking.reset();
                    booking.reset();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'View in Ride History',
                  isOutlined: true,
                  onPressed: () {
                    // Reset booking & tracking
                    tracking.reset();
                    booking.reset();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RideHistoryScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
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
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ),
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