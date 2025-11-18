import 'package:flutter/material.dart';
import 'package:life_hub/data/models/event_model.dart';
import 'package:life_hub/data/local/hive_service.dart';
import 'package:life_hub/data/local/notification_service.dart';

class EventProvider extends ChangeNotifier {
  List<EventModel> _eventList = [];
  DateTime _selectedDate = DateTime.now();
  
  List<EventModel> get eventList => _eventList;
  DateTime get selectedDate => _selectedDate;
  
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
  
  List<EventModel> get selectedDateEvents {
    return _eventList.where((event) {
      return event.dateTime.year == _selectedDate.year &&
             event.dateTime.month == _selectedDate.month &&
             event.dateTime.day == _selectedDate.day;
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
  
  // Get all dates that have events (for calendar marking)
  Set<DateTime> get eventDates {
    return _eventList.map((event) {
      return DateTime(
        event.dateTime.year,
        event.dateTime.month,
        event.dateTime.day,
      );
    }).toSet();
  }
  
  EventProvider() {
    loadEventData();
  }
  
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
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
      debugPrint('Error loading event data: $e');
    }
  }
  
  Future<void> addEvent(EventModel event, {bool enableNotifications = true}) async {
    try {
      await HiveService.saveData('eventBox', event.id, event.toJson());
      _eventList.add(event);
      _eventList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      // Schedule notifications for reminders
      if (enableNotifications && event.reminderMinutes.isNotEmpty) {
        await _scheduleEventReminders(event);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding event: $e');
      rethrow;
    }
  }
  
  Future<void> updateEvent(EventModel event, {bool enableNotifications = true}) async {
    try {
      await HiveService.saveData('eventBox', event.id, event.toJson());
      final index = _eventList.indexWhere((item) => item.id == event.id);
      if (index != -1) {
        _eventList[index] = event;
        _eventList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        
        // Cancel old notifications and schedule new ones
        await _cancelEventReminders(event.id);
        if (enableNotifications && event.reminderMinutes.isNotEmpty) {
          await _scheduleEventReminders(event);
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating event: $e');
      rethrow;
    }
  }
  
  Future<void> deleteEvent(String id) async {
    try {
      await HiveService.deleteData('eventBox', id);
      await _cancelEventReminders(id);
      _eventList.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting event: $e');
    }
  }
  
  EventModel? getEventById(String id) {
    try {
      return _eventList.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  List<DateTime> _getRecurringDates(EventModel event, {int maxDays = 365}) {
    final List<DateTime> dates = [];
    final now = DateTime.now();
    final endDate = now.add(Duration(days: maxDays));

    DateTime current = event.dateTime;

    while (current.isBefore(endDate)) {
      if (current.isAfter(now)) {
        dates.add(current);
      }

      switch (event.recurrence) {
        case Recurrence.once:
          return dates; // only one
        case Recurrence.daily:
          current = current.add(const Duration(days: 1));
          break;
        case Recurrence.weekly:
          current = current.add(const Duration(days: 7));
          break;
      }
    }

    return dates;
  }
  
  // Schedule all reminder notifications for an event
  Future<void> _scheduleEventReminders(EventModel event) async {
    final futureDates = _getRecurringDates(event);

    for (int dateIdx = 0; dateIdx < futureDates.length; dateIdx++) {
      final occurrenceDate = futureDates[dateIdx];

      for (int remIdx = 0; remIdx < event.reminderMinutes.length; remIdx++) {
        final minutes = int.tryParse(event.reminderMinutes[remIdx]) ?? 0;
        if (minutes <= 0) continue;

        final fireAt = occurrenceDate.subtract(Duration(minutes: minutes));
        if (!fireAt.isAfter(DateTime.now())) continue;

        // Unique ID: eventId_occurrenceIndex_reminderIndex
        final reminderId = '${event.id}_occ_$remIdx';
        final reminderText = _humanReminderText(minutes);

        await NotificationService.scheduleReminder(
          reminderId: reminderId,
          title: 'Event Reminder',
          body: '${event.title} – $reminderText',
          fireAt: fireAt,
        );
      }
    }
  }

  String _humanReminderText(int minutes) {
    if (minutes < 60) return '$minutes minute${minutes > 1 ? 's' : ''} before';
    if (minutes < 1440) {
      final h = minutes ~/ 60;
      return '$h hour${h > 1 ? 's' : ''} before';
    }
    final d = minutes ~/ 1440;
    return '$d day${d > 1 ? 's' : ''} before';
  }
  
  // Cancel all reminders for an event
  Future<void> _cancelEventReminders(String eventId) async {
    final event = getEventById(eventId);
    if (event != null) {
      for (int i = 0; i < event.reminderMinutes.length; i++) {
        final reminderId = '${event.id}_reminder_$i';
        await NotificationService.cancelNotification(reminderId);
      }
    }
  }
  
  String _getReminderText(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes before';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      return '$hours hour${hours > 1 ? 's' : ''} before';
    } else {
      final days = minutes ~/ 1440;
      return '$days day${days > 1 ? 's' : ''} before';
    }
  }
}