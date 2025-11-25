import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/providers/profile_provider.dart';
import 'package:life_hub/data/service/file_service.dart';
import 'package:life_hub/features/settings/widgets/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isEditingName = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: Consumer<ProfileProvider>(
                builder: (context, profileProvider, _) {
                  final profile = profileProvider.userProfile;
                  
                  if (profile == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          _buildProfilePhoto(context, profile, profileProvider),
                          const SizedBox(height: 40),
                          _buildNameField(context, profile, profileProvider, isDark),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.getTextColor(context),
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Text(
            'Profile',
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhoto(
    BuildContext context,
    profile,
    ProfileProvider profileProvider,
  ) {
    return Stack(
      children: [
        ProfileAvatar(
          profile: profile,
          size: 140,
          showBorder: true,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _showPhotoOptions(context, profileProvider),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    AppColors.purpleGradientStart,
                    AppColors.purpleGradientEnd,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.purpleGradientStart.withOpacity(0.5),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(
    BuildContext context,
    profile,
    ProfileProvider profileProvider,
    bool isDark,
  ) {
    if (!_isEditingName) {
      _nameController.text = profile.name;
    }

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.purpleGradientStart,
                  AppColors.purpleGradientEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _isEditingName
                ? TextField(
                    controller: _nameController,
                    autofocus: true,
                    style: TextStyle(
                      color: AppColors.getTextColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(
                        color: AppColors.getSubtitleColor(context).withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (value) => _saveName(profileProvider),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name',
                        style: TextStyle(
                          color: AppColors.getSubtitleColor(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.name,
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (_isEditingName) {
                _saveName(profileProvider);
              } else {
                setState(() {
                  _isEditingName = true;
                  _nameController.text = profile.name;
                });
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isEditingName
                    ? AppColors.completed.withOpacity(0.1)
                    : AppColors.purpleGradientStart.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isEditingName ? Icons.check : Icons.edit,
                color: _isEditingName
                    ? AppColors.completed
                    : AppColors.purpleGradientStart,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveName(ProfileProvider profileProvider) {
    final newName = _nameController.text.trim();
    
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Name cannot be empty'),
            ],
          ),
          backgroundColor: AppColors.highPriority,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    profileProvider.updateProfile(name: newName);
    
    setState(() {
      _isEditingName = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Name updated successfully'),
          ],
        ),
        backgroundColor: AppColors.completed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context, ProfileProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Profile Photo',
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildPhotoOption(
              context,
              icon: Icons.camera_alt,
              label: 'Take Photo',
              onTap: () async {
                Navigator.pop(context);
                final path = await FileService.pickImageFromCamera();
                if (path != null) {
                  await provider.updateProfilePhoto(path);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildPhotoOption(
              context,
              icon: Icons.photo_library,
              label: 'Choose from Gallery',
              onTap: () async {
                Navigator.pop(context);
                final path = await FileService.pickImageFromGallery();
                if (path != null) {
                  await provider.updateProfilePhoto(path);
                }
              },
            ),
            if (provider.userProfile?.profilePhotoPath != null) ...[
              const SizedBox(height: 12),
              _buildPhotoOption(
                context,
                icon: Icons.delete_outline,
                label: 'Remove Photo',
                isDestructive: true,
                onTap: () async {
                  Navigator.pop(context);
                  await provider.removeProfilePhoto();
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive
                  ? AppColors.highPriority
                  : AppColors.purpleGradientStart,
              size: 24,
            ),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                color: isDestructive
                    ? AppColors.highPriority
                    : AppColors.getTextColor(context),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}