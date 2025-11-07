import 'package:flutter/material.dart';
import 'package:life_hub/data/models/maintenance_model.dart';
import 'package:life_hub/data/local/hive_service.dart';

class MaintenanceProvider extends ChangeNotifier {
  List<MaintenanceModel> _maintenanceList = [];
  
  List<MaintenanceModel> get maintenanceList => _maintenanceList;
  
  int get pendingCount => _maintenanceList
      .where((item) => item.status == 'pending')
      .length;

  MaintenanceProvider() {
    loadMaintenanceData();
  }

  Future<void> loadMaintenanceData() async {
    try {
      final data = await HiveService.getAllData('maintenanceBox');
      _maintenanceList = data
          .map((item) => MaintenanceModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      _maintenanceList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    } catch (e) {
      print('Error loading maintenance data: $e');
    }
  }

  Future<void> addMaintenance(MaintenanceModel maintenance) async {
    try {
      await HiveService.saveData('maintenanceBox', maintenance.id, maintenance.toJson());
      _maintenanceList.add(maintenance);
      _maintenanceList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifyListeners();
    } catch (e) {
      print('Error adding maintenance: $e');
    }
  }

  Future<void> updateMaintenance(MaintenanceModel maintenance) async {
    try {
      await HiveService.saveData('maintenanceBox', maintenance.id, maintenance.toJson());
      final index = _maintenanceList.indexWhere((item) => item.id == maintenance.id);
      if (index != -1) {
        _maintenanceList[index] = maintenance;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating maintenance: $e');
    }
  }

  Future<void> deleteMaintenance(String id) async {
    try {
      await HiveService.deleteData('maintenanceBox', id);
      _maintenanceList.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting maintenance: $e');
    }
  }
}