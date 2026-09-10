import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/models/trip_model.dart';
import '../../providers/history_provider.dart';
import 'widgets/ride_detail_sheet.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.darkMidnight,
      appBar: AppBar(
        backgroundColor: AppColors.darkMidnight,
        elevation: 0,
        title: Text('Your Rides', style: AppTypography.heading2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All (${history.allTrips.length})',
                  isSelected: history.currentFilter == RideFilter.all,
                  onTap: () => history.setFilter(RideFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Completed',
                  isSelected: history.currentFilter == RideFilter.completed,
                  onTap: () => history.setFilter(RideFilter.completed),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Cancelled',
                  isSelected: history.currentFilter == RideFilter.cancelled,
                  onTap: () => history.setFilter(RideFilter.cancelled),
                ),
              ],
            ),
          ),
        ),
      ),
      body: history.filteredTrips.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car_outlined, size: 64, color: AppColors.textMuted.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No rides found', style: AppTypography.bodyLarge.copyWith(color: AppColors.textMuted)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              itemCount: history.filteredTrips.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final trip = history.filteredTrips[index];
                return _RideHistoryCard(
                  trip: trip,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => RideDetailSheet(trip: trip),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryEmerald : AppColors.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryEmerald : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isSelected ? AppColors.darkMidnight : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _RideHistoryCard extends StatelessWidget {
  final TripModel trip;
  final VoidCallback onTap;

  const _RideHistoryCard({
    required this.trip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = trip.status == TripStatus.completed;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Category, Date, Fare & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryEmerald.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
                        color: AppColors.primaryEmerald,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trip.rideCategory, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        Text(trip.formattedDate, style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${trip.fare.toStringAsFixed(0)}',
                      style: AppTypography.heading3.copyWith(
                        color: isCompleted ? AppColors.textPrimary : AppColors.textMuted,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.primaryEmerald.withValues(alpha: 0.12)
                            : AppColors.accentCoral.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isCompleted ? 'Completed' : 'Cancelled',
                        style: AppTypography.caption.copyWith(
                          color: isCompleted ? AppColors.primaryEmerald : AppColors.accentCoral,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: AppColors.cardBorder, height: 1),
            ),
            // Route pickup & drop
            Row(
              children: [
                Column(
                  children: [
                    const Icon(Icons.radio_button_checked, size: 14, color: AppColors.primaryEmerald),
                    Container(width: 1.5, height: 16, color: AppColors.cardBorder),
                    const Icon(Icons.location_on, size: 14, color: AppColors.accentCoral),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.pickup.name,
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        trip.drop.name,
                        style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}