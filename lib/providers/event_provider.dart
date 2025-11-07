import 'package:flutter/material.dart';
import 'package:life_hub/data/models/event_model.dart';
import 'package:life_hub/data/local/hive_service.dart';

class EventProvider extends ChangeNotifier {
  List<EventModel> _eventList = [];
  
  List<EventModel> get eventList => _eventList;
  
  int get upcomingCount => _eventList
      .where((event) => event.dateTime.isAfter(DateTime.now()))
      .length;
  
  List<EventModel> get todayEvents {
    final now = DateTime.now();
    return _eventList.where((event) {
      return event.dateTime.year == now.year &&
             event.dateTime.month == now.month &&
             event.dateTime.day == now.day;
    }).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }
  
  List<EventModel> get tomorrowEvents {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _eventList.where((event) {
      return event.dateTime.year == tomorrow.year &&
             event.dateTime.month == tomorrow.month &&
             event.dateTime.day == tomorrow.day;
    }).toList()..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }
  
  EventProvider() {
    loadEventData();
  }
  
  Future<void> loadEventData() async {
    try {
      final data = await HiveService.getAllData('eventBox');
      _eventList = data
          .map((item) => EventModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      _eventList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      notifyListeners();
    } catch (e) {
      print('Error loading event data: $e');
    }
  }
  
  Future<void> addEvent(EventModel event) async {
    try {
      await HiveService.saveData('eventBox', event.id, event.toJson());
      _eventList.add(event);
      _eventList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      notifyListeners();
    } catch (e) {
      print('Error adding event: $e');
    }
  }
  
  Future<void> updateEvent(EventModel event) async {
    try {
      await HiveService.saveData('eventBox', event.id, event.toJson());
      final index = _eventList.indexWhere((item) => item.id == event.id);
      if (index != -1) {
        _eventList[index] = event;
        _eventList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        notifyListeners();
      }
    } catch (e) {
      print('Error updating event: $e');
    }
  }
  
  Future<void> deleteEvent(String id) async {
    try {
      await HiveService.deleteData('eventBox', id);
      _eventList.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting event: $e');
    }
  }
}