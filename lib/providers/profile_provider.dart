import 'package:flutter/material.dart';
import 'package:life_hub/data/models/user_profile_model.dart';
import 'package:life_hub/data/local/hive_service.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfileModel? _userProfile;
  
  UserProfileModel? get userProfile => _userProfile;
  
  ProfileProvider() {
    loadProfile();
  }
  
  Future<void> loadProfile() async {
    try {
      final data = await HiveService.getData('settingsBox', 'userProfile');
      if (data != null) {
        _userProfile = UserProfileModel.fromJson(Map<String, dynamic>.from(data));
      } else {
        // Create default profile
        _userProfile = UserProfileModel(
          id: 'user_001',
          name: 'John Doe',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await saveProfile(_userProfile!);
      }
      notifyListeners();
    } catch (e) {
      print('Error loading profile: $e');
    }
  }
  
  Future<void> saveProfile(UserProfileModel profile) async {
    try {
      await HiveService.saveData('settingsBox', 'userProfile', profile.toJson());
      _userProfile = profile;
      notifyListeners();
    } catch (e) {
      print('Error saving profile: $e');
    }
  }
  
  Future<void> updateProfile({
    String? name,
    String? profilePhotoPath,
  }) async {
    if (_userProfile == null) return;
    
    final updatedProfile = _userProfile!.copyWith(
      name: name,
      profilePhotoPath: profilePhotoPath,
      updatedAt: DateTime.now(),
    );
    
    await saveProfile(updatedProfile);
  }
  
  Future<void> updateProfilePhoto(String? photoPath) async {
    if (_userProfile == null) return;
    
    final updatedProfile = _userProfile!.copyWith(
      profilePhotoPath: photoPath,
      updatedAt: DateTime.now(),
    );
    
    await saveProfile(updatedProfile);
  }
  
  Future<void> removeProfilePhoto() async {
    await updateProfilePhoto(null);
  }

}