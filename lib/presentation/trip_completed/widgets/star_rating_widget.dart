import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StarRatingWidget extends StatelessWidget {
  final int initialRating;
  final ValueChanged<int> onRatingChanged;

  const StarRatingWidget({
    super.key,
    required this.initialRating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= initialRating;

        return IconButton(
          icon: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isFilled ? AppColors.warning : AppColors.textMuted,
            size: 38,
          ),
          onPressed: () => onRatingChanged(starIndex),
        );
      }),
    );
  }
}
