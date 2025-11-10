import 'package:flutter/material.dart';
import 'package:life_hub/data/local/hive_service.dart';

class SettingsProvider extends ChangeNotifier {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  SettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      _notificationsEnabled = await HiveService.getData('settingsBox', 'notifications') ?? true;
      _soundEnabled = await HiveService.getData('settingsBox', 'sound') ?? true;
      _vibrationEnabled = await HiveService.getData('settingsBox', 'vibration') ?? true;
      notifyListeners();
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  Future<void> toggleNotifications() async {
    try {
      _notificationsEnabled = !_notificationsEnabled;
      await HiveService.saveData('settingsBox', 'notifications', _notificationsEnabled);
      notifyListeners();
    } catch (e) {
      print('Error toggling notifications: $e');
    }
  }

  Future<void> toggleSound() async {
    try {
      _soundEnabled = !_soundEnabled;
      await HiveService.saveData('settingsBox', 'sound', _soundEnabled);
      notifyListeners();
    } catch (e) {
      print('Error toggling sound: $e');
    }
  }

  Future<void> toggleVibration() async {
    try {
      _vibrationEnabled = !_vibrationEnabled;
      await HiveService.saveData('settingsBox', 'vibration', _vibrationEnabled);
      notifyListeners();
    } catch (e) {
      print('Error toggling vibration: $e');
    }
  }
}
