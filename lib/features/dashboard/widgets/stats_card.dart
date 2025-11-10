import 'package:flutter/material.dart';
import 'package:life_hub/core/constants/app_colors.dart';

class StatsCardGroup extends StatelessWidget {
  final List<StatsCardData> stats;

  const StatsCardGroup({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.purpleGradientStart.withOpacity(0.15),
            AppColors.purpleGradientEnd.withOpacity(0.15),
          ],
        ),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            _buildStatItem(context, stats[i]),
            if (i < stats.length - 1) const SizedBox(height: 15),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, StatsCardData data) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data.label,
              style: TextStyle(
                color: AppColors.getSubtitleColor(context),
                fontSize: 14,
              ),
            ),
            Text(
              data.value,
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: data.progress.clamp(0.0, 1.0),
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.purpleGradientStart,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

class StatsCardData {
  final String label;
  final String value;
  final double progress;

  const StatsCardData({
    required this.label,
    required this.value,
    required this.progress,
  });
}