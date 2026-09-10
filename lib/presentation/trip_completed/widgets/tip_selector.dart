import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

class TipSelector extends StatelessWidget {
  final int selectedTip;
  final ValueChanged<int> onTipSelected;

  const TipSelector({
    super.key,
    required this.selectedTip,
    required this.onTipSelected,
  });

  @override
  Widget build(BuildContext context) {
    final tips = [0, 20, 50, 100];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add a Tip for Driver', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: tips.map((tip) {
            final isSelected = selectedTip == tip;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => onTipSelected(tip),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryEmerald : AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryEmerald : AppColors.cardBorder,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      tip == 0 ? 'No Tip' : '₹$tip',
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected ? AppColors.darkMidnight : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
