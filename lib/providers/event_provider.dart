import 'package:flutter/material.dart';
import 'package:life_hub/data/models/event_model.dart';
import 'package:life_hub/data/service/hive_service.dart';
import 'package:life_hub/data/service/notification_service.dart';

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
    return _getEventsForDate(now);
  }
  
  List<EventModel> get selectedDateEvents {
    return _getEventsForDate(_selectedDate);
  }
  
  List<EventModel> get tomorrowEvents {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _getEventsForDate(tomorrow);
  }
  
  // Get all dates that have events (for calendar marking)
  // This includes recurring event dates (but excludes daily recurrence)
  Set<DateTime> get eventDates {
    final dates = <DateTime>{};
    final now = DateTime.now();
    final maxDate = now.add(const Duration(days: 365));
    
    for (final event in _eventList) {
      // Skip daily recurrence events to avoid highlighting every day
      if (event.recurrence == Recurrence.daily) {
        continue;
      }
      
      final recurringDates = _getRecurringDates(event, maxDays: 365);
      for (final date in recurringDates) {
        if (date.isBefore(maxDate)) {
          dates.add(DateTime(date.year, date.month, date.day));
        }
      }
    }
    
    return dates;
  }
  
  EventProvider() {
    loadEventData();
  }
  
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }
  
  // Get events for a specific date (including recurring events)
  List<EventModel> _getEventsForDate(DateTime date) {
    final events = <EventModel>[];
    
    for (final event in _eventList) {
      if (_eventOccursOnDate(event, date)) {
        events.add(event);
      }
    }
    
    events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return events;
  }
  
  // Check if an event occurs on a specific date
  bool _eventOccursOnDate(EventModel event, DateTime date) {
    final eventDate = event.dateTime;
    final checkDate = DateTime(date.year, date.month, date.day);
    final eventStartDate = DateTime(eventDate.year, eventDate.month, eventDate.day);
    
    // If the date is before the event starts, return false
    if (checkDate.isBefore(eventStartDate)) {
      return false;
    }
    
    switch (event.recurrence) {
      case Recurrence.once:
        return checkDate.isAtSameMomentAs(eventStartDate);
        
      case Recurrence.daily:
        // Occurs every day from the start date onwards
        return checkDate.isAtSameMomentAs(eventStartDate) || checkDate.isAfter(eventStartDate);
        
      case Recurrence.yearly:
        // Occurs every year on the same month and day
        return checkDate.month == eventDate.month && 
               checkDate.day == eventDate.day &&
               checkDate.year >= eventDate.year;
    }
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

      EventModel eventToSave = event;
      if (event.reminderMinutes.isEmpty) {
        eventToSave = event.copyWith(
          reminderMinutes: ['60'],
        );
      }
      await HiveService.saveData('eventBox', eventToSave.id, event.toJson());
      _eventList.add(eventToSave);
      _eventList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      
      // Schedule notifications for reminders
      if (enableNotifications && eventToSave.reminderMinutes.isNotEmpty) {
        await _scheduleEventReminders(eventToSave);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding event: $e');
      rethrow;
    }
  }
  
  Future<void> updateEvent(EventModel event, {bool enableNotifications = true}) async {
    try {
      debugPrint(' Updating event: ${event.title}');
      
      await HiveService.saveData('eventBox', event.id, event.toJson());      
      final index = _eventList.indexWhere((item) => item.id == event.id);
      if (index != -1) {
        _eventList[index] = event;
        _eventList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        
        await _cancelEventReminders(event.id);
        if (enableNotifications && event.reminderMinutes.isNotEmpty) {
          await _scheduleEventReminders(event);
        }
        
        notifyListeners();
        debugPrint('Event updated successfully');
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

  // Generate list of future dates when this event will occur
  List<DateTime> _getRecurringDates(EventModel event, {int maxDays = 365}) {
    final List<DateTime> dates = [];
    final now = DateTime.now();
    final endDate = now.add(Duration(days: maxDays));

    DateTime current = event.dateTime;

    while (current.isBefore(endDate)) {
      if (current.isAfter(now) || _isSameDay(current, now)) {
        dates.add(current);
      }

      switch (event.recurrence) {
        case Recurrence.once:
          return dates; // only one occurrence
          
        case Recurrence.daily:
          current = current.add(const Duration(days: 1));
          break;
          
        case Recurrence.yearly:
          // Add one year, handling leap years properly
          current = DateTime(
            current.year + 1,
            current.month,
            current.day,
            current.hour,
            current.minute,
          );
          break;
      }
    }

    return dates;
  }
  
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
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
        final reminderId = '${event.id}_occ${dateIdx}_rem$remIdx';
        final reminderText = _humanReminderText(minutes);

        await NotificationService.scheduleReminder(
          reminderId: reminderId,
          title: event.title,
          body: reminderText,
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
      // Cancel multiple occurrences
      final futureDates = _getRecurringDates(event);
      for (int dateIdx = 0; dateIdx < futureDates.length; dateIdx++) {
        for (int remIdx = 0; remIdx < event.reminderMinutes.length; remIdx++) {
          final reminderId = '${event.id}_occ${dateIdx}_rem$remIdx';
          await NotificationService.cancelNotification(reminderId);
        }
      }
    }
  }
}