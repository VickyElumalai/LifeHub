import 'dart:io';
import 'package:flutter/material.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/data/models/user_profile_model.dart';

class ProfileAvatar extends StatelessWidget {
  final UserProfileModel profile;
  final double size;
  final bool showBorder;

  const ProfileAvatar({
    super.key,
    required this.profile,
    this.size = 50,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 3,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.purpleGradientStart.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: profile.profilePhotoPath != null &&
                profile.profilePhotoPath!.isNotEmpty
            ? _buildProfileImage()
            : _buildInitialsAvatar(),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Image.file(
      File(profile.profilePhotoPath!),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildInitialsAvatar();
      },
    );
  }

  Widget _buildInitialsAvatar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.purpleGradientStart,
            AppColors.purpleGradientEnd,
          ],
        ),
      ),
      child: Center(
        child: Text(
          profile.initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}