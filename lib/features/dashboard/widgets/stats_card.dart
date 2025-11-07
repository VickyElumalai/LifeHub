import 'package:flutter/material.dart';
import 'package:life_hub/core/constants/app_colors.dart';

class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final double progress;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
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
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStatRow(),
          const SizedBox(height: 8),
          _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: progress.clamp(0.0, 1.0),
        backgroundColor: Colors.white.withOpacity(0.1),
        valueColor: const AlwaysStoppedAnimation<Color>(
          AppColors.purpleGradientStart,
        ),
        minHeight: 6,
      ),
    );
  }
}

class StatsCardGroup extends StatelessWidget {
  final List<StatsCardData> stats;

  const StatsCardGroup({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
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
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          for (int i = 0; i < stats.length; i++) ...[
            _buildStatItem(stats[i]),
            if (i < stats.length - 1) const SizedBox(height: 15),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(StatsCardData data) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              data.label,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
              ),
            ),
            Text(
              data.value,
              style: const TextStyle(
                color: Colors.white,
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
            backgroundColor: Colors.white.withOpacity(0.1),
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