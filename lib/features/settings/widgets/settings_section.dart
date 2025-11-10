import 'package:flutter/material.dart';
import 'package:life_hub/core/constants/app_colors.dart';

class SettingsSection extends StatelessWidget {
  final String title;

  const SettingsSection({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textGrey,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }
}