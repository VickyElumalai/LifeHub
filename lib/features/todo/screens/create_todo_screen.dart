import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/data/models/todo_model.dart';
import 'package:life_hub/providers/todo_provider.dart';
import 'package:life_hub/providers/settings_provider.dart';
import 'package:life_hub/data/service/file_service.dart';
import 'package:life_hub/data/service/audio_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class CreateTodoScreen extends StatefulWidget {
  final String? todoId; 

  const CreateTodoScreen({super.key, this.todoId});

  @override
  State<CreateTodoScreen> createState() => _CreateTodoScreenState();
}

class _CreateTodoScreenState extends State<CreateTodoScreen> {
  final TextEditingController _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String _selectedPriority = 'medium';
  DateTime? _endTime;
  String? _imagePath;
  String? _voicePath;
  List<String> _selectedReminders = []; 
  bool _isLoading = false;
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  bool _isEditMode = false;
  TodoModel? _existingTodo;

  @override
  void initState() {
    super.initState();
    if (widget.todoId != null) {
      _loadExistingTodo();
    }
  }

  void _loadExistingTodo() {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    final todo = provider.getTodoById(widget.todoId!);
    
    if (todo != null) {
      setState(() {
        _isEditMode = true;
        _existingTodo = todo;
        _contentController.text = todo.content;
        _selectedPriority = todo.priority;
        _endTime = todo.endTime;
        _imagePath = todo.imagePath;
        _voicePath = todo.voicePath;
        _selectedReminders = List.from(todo.reminderMinutes); 
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _recordingTimer?.cancel();
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
                      _buildSectionLabel(context, 'Content'),
                      const SizedBox(height: 8),
                      _buildContentField(context, isDark),
                      
                      const SizedBox(height: 5),
                      _buildSectionLabel(context, 'Priority'),
                      const SizedBox(height: 12),
                      _buildPrioritySelector(context, isDark),
                      
                      const SizedBox(height: 25),
                      _buildSectionLabel(context, 'Due Date & Time (Optional)'),
                      const SizedBox(height: 12),
                      _buildDateTimePicker(context, isDark),
                      if (_endTime != null) ...[
                        const SizedBox(height: 25),
                        _buildSectionLabel(context, 'Reminders (Optional)'),
                        const SizedBox(height: 12),
                        _buildCustomReminderSelector(context, isDark),
                      ],
                      const SizedBox(height: 25),
                      _buildSectionLabel(context, 'Attachments (Optional)'),
                      const SizedBox(height: 12),
                      _buildAttachments(context, isDark),
                      
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
              'No reminders set (will notify 1 min before due time)',
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
            onTap: () async {
              if (_isRecording) {
                await _stopRecording();
              }
              if (mounted) {
                Navigator.pop(context);
              }
            },
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
            _isEditMode ? 'Edit Task' : 'Create To-Do',
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

  Widget _buildContentField(BuildContext context, bool isDark) {
    return TextFormField(
      controller: _contentController,
      maxLines: 5,
      maxLength: 500,
      validator: (value) {
        // Content is only required if no voice or image is present
        if ((value == null || value.trim().isEmpty) && 
            _voicePath == null && 
            _imagePath == null) {
          return 'Please enter content or add voice/image';
        }
        return null;
      },
      style: TextStyle(
        color: AppColors.getTextColor(context),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: 'What do you need to do? (Optional if you add voice/image)',
        hintStyle: TextStyle(
          color: AppColors.getSubtitleColor(context).withOpacity(0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white,
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
            color: AppColors.greenGradientStart,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.highPriority,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.highPriority,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
        counterStyle: TextStyle(
          color: AppColors.getSubtitleColor(context),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPrioritySelector(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildPriorityChip('High', 'high', AppColors.highPriority, isDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPriorityChip('Medium', 'medium', AppColors.mediumPriority, isDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPriorityChip('Low', 'low', AppColors.lowPriority, isDark),
        ),
      ],
    );
  }

  Widget _buildPriorityChip(String label, String value, Color color, bool isDark) {
    final isSelected = _selectedPriority == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.2)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1)),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? color : AppColors.getTextColor(context),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _selectDateTime(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppColors.purpleGradientStart,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _endTime == null
                    ? 'Select due date & time'
                    : DateFormat('MMM dd, yyyy hh:mm a').format(_endTime!),
                style: TextStyle(
                  color: _endTime == null
                      ? AppColors.getSubtitleColor(context)
                      : AppColors.getTextColor(context),
                  fontSize: 14,
                ),
              ),
            ),
            if (_endTime != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _endTime = null;
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
      ),
    );
  }

  Widget _buildAttachments(BuildContext context, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAttachmentButton(
                icon: Icons.image,
                label: 'Add Image',
                onTap: _pickImage,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAttachmentButton(
                icon: _isRecording ? Icons.stop : Icons.mic,
                label: _isRecording ? 'Stop' : 'Record',
                onTap: _isRecording ? _stopRecording : _startRecording,
                isDark: isDark,
                isRecording: _isRecording,
              ),
            ),
          ],
        ),
        if (_imagePath != null) ...[
          const SizedBox(height: 15),
          _buildImagePreview(isDark),
        ],
        if (_voicePath != null) ...[
          const SizedBox(height: 15),
          _buildVoicePreview(isDark),
        ],
      ],
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool isRecording = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isRecording
              ? AppColors.highPriority.withOpacity(0.2)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          border: Border.all(
            color: isRecording
                ? AppColors.highPriority
                : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1)),
            width: isRecording ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isRecording
                  ? AppColors.highPriority
                  : AppColors.purpleGradientStart,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              isRecording ? 'Recording: ${_recordingSeconds}s' : label,
              style: TextStyle(
                color: isRecording
                    ? AppColors.highPriority
                    : AppColors.getTextColor(context),
                fontSize: 13,
                fontWeight: isRecording ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(bool isDark) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(_imagePath!),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _imagePath = null;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.highPriority,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoicePreview(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.purpleGradientStart.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.purpleGradientStart.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.purpleGradientStart,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mic,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Recording',
                  style: TextStyle(
                    color: AppColors.getTextColor(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to play in preview',
                  style: TextStyle(
                    color: AppColors.getSubtitleColor(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _voicePath = null;
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
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTodo,
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
                      AppColors.greenGradientStart.withOpacity(0.5),
                      AppColors.greenGradientEnd.withOpacity(0.5),
                    ]
                  : [
                      AppColors.greenGradientStart,
                      AppColors.greenGradientEnd,
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
                        _isEditMode ? 'Save Changes' : 'Create Task',
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
      initialDate: _endTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.purpleGradientStart,
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
        initialTime: TimeOfDay.fromDateTime(_endTime ?? DateTime.now()),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: AppColors.purpleGradientStart,
                surface: AppColors.darkCard,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _endTime = DateTime(
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
              color: AppColors.purpleGradientStart,
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

  Future<void> _startRecording() async {
    try {
      await AudioService.startRecording();
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _recordingSeconds++;
          });
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start recording: $e'),
            backgroundColor: AppColors.highPriority,
          ),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await AudioService.stopRecording();
      _recordingTimer?.cancel();

      setState(() {
        _isRecording = false;
        _recordingSeconds = 0;
        if (path != null) {
          _voicePath = path;
        }
      });

      if (path != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recording saved'),
            backgroundColor: AppColors.completed,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save recording: $e'),
            backgroundColor: AppColors.highPriority,
          ),
        );
      }
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<TodoProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

      // Use content if available, otherwise use placeholder
      final content = _contentController.text.trim().isEmpty 
          ? (_voicePath != null ? 'Voice Note' : 'Image Note')
          : _contentController.text.trim();

      final todo = TodoModel(
        id: _isEditMode ? _existingTodo!.id : 'todo_${DateTime.now().millisecondsSinceEpoch}',
        content: content,
        priority: _selectedPriority,
        endTime: _endTime,
        createdAt: _isEditMode ? _existingTodo!.createdAt : DateTime.now(),
        reminderMinutes: _selectedReminders,
        voicePath: _voicePath,
        imagePath: _imagePath,
        status: _isEditMode ? _existingTodo!.status : 'pending',
      );

      if (_isEditMode) {
        await provider.updateTodo(todo, enableNotifications: settingsProvider.notificationsEnabled);
      } else {
        await provider.addTodo(todo, enableNotifications: settingsProvider.notificationsEnabled);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(_isEditMode ? 'Task updated!' : 'Task created!'),
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Failed to save task'),
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