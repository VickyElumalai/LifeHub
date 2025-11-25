import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/data/models/event_model.dart';
import 'package:life_hub/providers/event_provider.dart';
import 'package:life_hub/providers/settings_provider.dart';
import 'package:life_hub/data/service/file_service.dart';

class CreateEventScreen extends StatefulWidget {
  final String? eventId;
  final DateTime? preSelectedDate;

  const CreateEventScreen({super.key, this.eventId, this.preSelectedDate});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  DateTime? _eventDateTime;
  String? _imagePath;
  List<String> _selectedReminders = [];
  bool _isLoading = false;
  bool _isEditMode = false;
  EventModel? _existingEvent;
  Recurrence _selectedRecurrence = Recurrence.once;

  @override
  void initState() {
    super.initState();   
    
    
    if (widget.eventId != null) {
      _loadExistingEvent();
    }
  }

  void _loadExistingEvent() {
    final provider = Provider.of<EventProvider>(context, listen: false);
    final event = provider.getEventById(widget.eventId!);
    
    if (event != null) {
      setState(() {
        _isEditMode = true;
        _existingEvent = event;
        _titleController.text = event.title;
        _locationController.text = event.location ?? '';
        _selectedRecurrence = event.recurrence;
        _eventDateTime = event.dateTime;
        _imagePath = event.attachmentPath;
        _selectedReminders = List.from(event.reminderMinutes);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel(context, 'Title *'),
                      const SizedBox(height: 8),
                      _buildTitleField(context, isDark),
                      
                      const SizedBox(height: 20),
                      _buildSectionLabel(context, 'Date & Time *'),
                      const SizedBox(height: 12),
                      _buildDateTimePicker(context, isDark),
                      
                      const SizedBox(height: 20),
                      _buildSectionLabel(context, 'Recurrence'),
                      const SizedBox(height: 12),
                      _buildRecurrenceSelector(context, isDark),
                      
                      const SizedBox(height: 20),
                      _buildSectionLabel(context, 'Image (Optional)'),
                      const SizedBox(height: 12),
                      _buildImageUpload(context, isDark),
                      
                      const SizedBox(height: 20),
                      _buildSectionLabel(context, 'Reminders'),
                      const SizedBox(height: 12),
                      _buildCustomReminderSelector(context, isDark),
                      
                      const SizedBox(height: 20),
                      _buildSectionLabel(context, 'Location (Optional)'),
                      const SizedBox(height: 8),
                      _buildLocationField(context, isDark),
                      
                      const SizedBox(height: 30),
                      _buildSaveButton(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
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
                  Icons.close,
                  color: AppColors.getTextColor(context),
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Text(
            _isEditMode ? 'Edit Event' : 'Create Event',
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // Delete button (only in edit mode)
          if (_isEditMode)
            GestureDetector(
              onTap: _handleDelete,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.highPriority.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete_outline,
                    color: AppColors.highPriority,
                    size: 22,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Delete Event',
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this event?',
          style: TextStyle(
            color: AppColors.getSubtitleColor(context),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.getSubtitleColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              final provider = Provider.of<EventProvider>(context, listen: false);
              await provider.deleteEvent(widget.eventId!);
              
              if (mounted) {
                Navigator.pop(context); // Close edit screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Event deleted'),
                      ],
                    ),
                    backgroundColor: AppColors.highPriority,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: AppColors.highPriority,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.getTextColor(context),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTitleField(BuildContext context, bool isDark) {
    return TextFormField(
      controller: _titleController,
      maxLength: 100,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter event title';
        }
        return null;
      },
      style: TextStyle(
        color: AppColors.getTextColor(context),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: 'e.g., Team Meeting',
        hintStyle: TextStyle(
          color: AppColors.getSubtitleColor(context).withOpacity(0.5),
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.blueGradientStart,
            width: 2,
          ),
        ),
        counterStyle: TextStyle(
          color: AppColors.getSubtitleColor(context),
        ),
      ),
    );
  }

  Widget _buildLocationField(BuildContext context, bool isDark) {
    return TextFormField(
      controller: _locationController,
      maxLength: 100,
      style: TextStyle(
        color: AppColors.getTextColor(context),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: 'e.g., Conference Room A',
        hintStyle: TextStyle(
          color: AppColors.getSubtitleColor(context).withOpacity(0.5),
        ),
        prefixIcon: Icon(
          Icons.location_on,
          color: AppColors.getSubtitleColor(context),
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.blueGradientStart,
            width: 2,
          ),
        ),
        counterStyle: TextStyle(
          color: AppColors.getSubtitleColor(context),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context, bool isDark) {
    final hasPreSelectedDate = widget.preSelectedDate != null && _eventDateTime == null;
    
    return GestureDetector(
      onTap: () {
        if (hasPreSelectedDate) {
          // If we have a pre-selected date but no time yet, just ask for time
          _selectTimeOnly(context, widget.preSelectedDate!);
        } else {
          // Otherwise, show full date & time picker
          _selectDateTime(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: _eventDateTime == null
                ? AppColors.highPriority.withOpacity(0.5)
                : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1)),
            width: _eventDateTime == null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: _eventDateTime == null
                      ? AppColors.highPriority
                      : AppColors.blueGradientStart,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_eventDateTime == null && hasPreSelectedDate) ...[
                        // Show pre-selected date
                        Text(
                          DateFormat('MMM dd, yyyy').format(widget.preSelectedDate!),
                          style: TextStyle(
                            color: AppColors.getTextColor(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: AppColors.highPriority,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Tap to select time *',
                              style: TextStyle(
                                color: AppColors.highPriority,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ] else if (_eventDateTime != null) ...[
                        // Show full date & time
                        Text(
                          DateFormat('MMM dd, yyyy - hh:mm a').format(_eventDateTime!),
                          style: TextStyle(
                            color: AppColors.getTextColor(context),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ] else ...[
                        // No date selected
                        Text(
                          'Select date & time *',
                          style: TextStyle(
                            color: AppColors.highPriority,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_eventDateTime != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _eventDateTime = null;
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      color: AppColors.highPriority,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceSelector(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildRecurrenceChip('Once', Recurrence.once, Icons.event, isDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildRecurrenceChip('Daily', Recurrence.daily, Icons.repeat, isDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildRecurrenceChip('Yearly', Recurrence.yearly, Icons.calendar_month, isDark),
        ),
      ],
    );
  }

  Widget _buildRecurrenceChip(String label, Recurrence value, IconData icon, bool isDark) {
    final isSelected = _selectedRecurrence == value;
    
    // Different gradient colors for each recurrence type
    List<Color> gradientColors;
    switch (value) {
      case Recurrence.once:
        gradientColors = [AppColors.purpleGradientStart, AppColors.purpleGradientEnd];
        break;
      case Recurrence.daily:
        gradientColors = [AppColors.greenGradientStart, AppColors.greenGradientEnd];
        break;
      case Recurrence.yearly:
        gradientColors = [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)]; // Orange/Red
        break;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRecurrence = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: gradientColors)
              : null,
          color: isSelected ? null : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.getTextColor(context),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.getTextColor(context),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomReminderSelector(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show selected reminders
        if (_selectedReminders.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedReminders.map((minutes) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.purpleGradientStart,
                      AppColors.purpleGradientEnd,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.notifications_active,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatReminderText(int.parse(minutes)),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedReminders.remove(minutes);
                        });
                      },
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 15),
        ],
        
        // Add reminder button
        GestureDetector(
          onTap: () => _showCustomReminderDialog(context, isDark),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              border: Border.all(
                color: AppColors.purpleGradientStart.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_alert,
                  color: AppColors.purpleGradientStart,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'Add Custom Reminder',
                  style: TextStyle(
                    color: AppColors.getTextColor(context),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (_selectedReminders.isEmpty) ...[
          const SizedBox(height: 10),
          Center(
            child: Text(
              'No reminders set',
              style: TextStyle(
                color: AppColors.getSubtitleColor(context),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showCustomReminderDialog(BuildContext context, bool isDark) {
    int selectedValue = 15;
    String selectedUnit = 'minutes';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? AppColors.darkCard : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Add Reminder',
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Remind me before',
                  style: TextStyle(
                    color: AppColors.getSubtitleColor(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedValue,
                        dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: List.generate(60, (index) => index + 1)
                            .map((num) => DropdownMenuItem(
                                  value: num,
                                  child: Text(
                                    num.toString(),
                                    style: TextStyle(
                                      color: AppColors.getTextColor(context),
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedValue = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedUnit,
                        dropdownColor: isDark ? AppColors.darkCard : Colors.white,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: ['minutes', 'hours', 'days']
                            .map((unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(
                                    unit,
                                    style: TextStyle(
                                      color: AppColors.getTextColor(context),
                                    ),
                                  ),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedUnit = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.getSubtitleColor(context),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  int minutes = selectedValue;
                  if (selectedUnit == 'hours') {
                    minutes = selectedValue * 60;
                  } else if (selectedUnit == 'days') {
                    minutes = selectedValue * 1440;
                  }
                  
                  setState(() {
                    if (!_selectedReminders.contains(minutes.toString())) {
                      _selectedReminders.add(minutes.toString());
                      // Sort reminders by time (smallest first)
                      _selectedReminders.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
                    }
                  });
                  
                  Navigator.pop(context);
                },
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: AppColors.purpleGradientStart,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatReminderText(int minutes) {
    if (minutes < 60) {
      return '$minutes min before';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      return '$hours hr${hours > 1 ? 's' : ''} before';
    } else {
      final days = minutes ~/ 1440;
      return '$days day${days > 1 ? 's' : ''} before';
    }
  }

  Widget _buildImageUpload(BuildContext context, bool isDark) {
    return Column(
      children: [
        if (_imagePath == null)
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate,
                      size: 50,
                      color: AppColors.blueGradientStart,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Add Image',
                      style: TextStyle(
                        color: AppColors.getSubtitleColor(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_imagePath!),
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _imagePath = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.highPriority,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isLoading
                  ? [
                      AppColors.blueGradientStart.withOpacity(0.5),
                      AppColors.blueGradientEnd.withOpacity(0.5),
                    ]
                  : [
                      AppColors.blueGradientStart,
                      AppColors.blueGradientEnd,
                    ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isEditMode ? Icons.check : Icons.add_circle_outline,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isEditMode ? 'Save Changes' : 'Create Event',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _eventDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.blueGradientStart,
              surface: AppColors.darkCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_eventDateTime ?? DateTime.now()),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppColors.blueGradientStart,
                surface: AppColors.darkCard,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _eventDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  // New method to select only time when date is pre-selected
  Future<void> _selectTimeOnly(BuildContext context, DateTime preSelectedDate) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.blueGradientStart,
              surface: AppColors.darkCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null && mounted) {
      setState(() {
        _eventDateTime = DateTime(
          preSelectedDate.year,
          preSelectedDate.month,
          preSelectedDate.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
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
                'Add Image',
                style: TextStyle(
                  color: AppColors.getTextColor(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildImageOption(
                context,
                icon: Icons.camera_alt,
                label: 'Take Photo',
                onTap: () async {
                  Navigator.pop(context);
                  final path = await FileService.pickImageFromCamera();
                  if (path != null) {
                    setState(() {
                      _imagePath = path;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildImageOption(
                context,
                icon: Icons.photo_library,
                label: 'Choose from Gallery',
                onTap: () async {
                  Navigator.pop(context);
                  final path = await FileService.pickImageFromGallery();
                  if (path != null) {
                    setState(() {
                      _imagePath = path;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
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
              color: AppColors.blueGradientStart,
              size: 24,
            ),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_eventDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Please select date and time'),
            ],
          ),
          backgroundColor: AppColors.highPriority,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<EventProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

      final event = EventModel(
        id: _isEditMode ? _existingEvent!.id : 'event_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        dateTime: _eventDateTime!,
        createdAt: _isEditMode ? _existingEvent!.createdAt : DateTime.now(),
        recurrence: _selectedRecurrence,
        reminderMinutes: _selectedReminders,
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        attachmentPath: _imagePath,
      );

      if (_isEditMode) {
        await provider.updateEvent(event, enableNotifications: settingsProvider.notificationsEnabled);
      } else {
        await provider.addEvent(event, enableNotifications: settingsProvider.notificationsEnabled);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(_isEditMode ? 'Event updated!' : 'Event created!'),
              ],
            ),
            backgroundColor: AppColors.completed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed to save event: $e')),
              ],
            ),
            backgroundColor: AppColors.highPriority,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}