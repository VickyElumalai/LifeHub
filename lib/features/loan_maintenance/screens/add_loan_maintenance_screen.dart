import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/data/models/loan_maintenance_model.dart';
import 'package:life_hub/providers/loan_maintenance_provider.dart';
import 'package:life_hub/providers/settings_provider.dart';
import 'package:life_hub/data/service/file_service.dart';
import 'package:intl/intl.dart';

class AddLoanMaintenanceScreen extends StatefulWidget {
  final String? itemId;
  final String? initialType;

  const AddLoanMaintenanceScreen({
    super.key,
    this.itemId,
    this.initialType,
  });

  @override
  State<AddLoanMaintenanceScreen> createState() =>
      _AddLoanMaintenanceScreenState();
}

class _AddLoanMaintenanceScreenState extends State<AddLoanMaintenanceScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _totalMonthsController = TextEditingController();
  final TextEditingController _completedMonthsController = TextEditingController();
  final TextEditingController _alreadyPaidController = TextEditingController();
  final TextEditingController _reminderDaysController = TextEditingController();
  final TextEditingController _customDaysController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedType = 'loan';
  String _selectedRecurrence = 'monthly';
  int? _selectedDueDay;
  DateTime? _selectedMaintenanceDueDate;
  List<String> _attachmentPaths = [];
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isExistingLoan = false;
  LoanMaintenanceModel? _existingItem;

  @override
  void initState() {
    super.initState();
    
    _reminderDaysController.text = '3';
    _completedMonthsController.text = '0';
    _alreadyPaidController.text = '0';
    
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
    
    if (widget.itemId != null) {
      _loadExistingItem();
    }
  }

  void _loadExistingItem() {
    final provider = Provider.of<LoanMaintenanceProvider>(context, listen: false);
    final item = provider.getItemById(widget.itemId!);

    if (item != null) {
      setState(() {
        _isEditMode = true;
        _existingItem = item;
        _selectedType = item.type;
        _titleController.text = item.title;
        _notesController.text = item.notes ?? '';
        _attachmentPaths = List.from(item.attachmentPaths);
        _reminderDaysController.text = item.reminderDays.toString();

        if (item.isLoan) {
          if (item.totalAmount != null) {
            _totalAmountController.text = item.totalAmount.toString();
          }
          if (item.totalMonths != null) {
            _totalMonthsController.text = item.totalMonths.toString();
          }
          _completedMonthsController.text = item.completedMonths.toString();
          _alreadyPaidController.text = item.totalPaid.toStringAsFixed(0);
          _selectedDueDay = item.paymentDay;
          
          if (item.completedMonths > 0) {
            _isExistingLoan = true;
          }
        } else {
          // CHANGED: For maintenance, use full due date
          _selectedRecurrence = item.recurrence ?? 'monthly';
          _selectedMaintenanceDueDate = item.nextDueDate; // Store full date
          if (item.customRecurrenceDays != null) {
            _customDaysController.text = item.customRecurrenceDays.toString();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _totalAmountController.dispose();
    _totalMonthsController.dispose();
    _completedMonthsController.dispose();
    _alreadyPaidController.dispose();
    _reminderDaysController.dispose();
    _customDaysController.dispose();
    _notesController.dispose();
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
                      if (!_isEditMode) ...[
                        _buildSectionLabel(context, 'Type *'),
                        const SizedBox(height: 8),
                        _buildTypeSelector(isDark),
                        const SizedBox(height: 20),
                      ],
                      _buildSectionLabel(context, 'Title *'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _titleController,
                        hint: _selectedType == 'loan'
                            ? 'e.g., Bike EMI, Home Gold Loan'
                            : 'e.g., Bike Insurance, AC Service',
                        isDark: isDark,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_selectedType == 'loan') ...[
                        ..._buildLoanFields(isDark),
                      ] else ...[
                        ..._buildMaintenanceFields(isDark),
                      ],
                      const SizedBox(height: 20),
                      _buildSectionLabel(
                          context, 'Reminder (Days Before Due Date) *'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _reminderDaysController,
                        hint: 'e.g., 3, 7, 15',
                        isDark: isDark,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter reminder days';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Please enter valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildSectionLabel(context, 'Notes (Optional)'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _notesController,
                        hint: 'Add any additional notes',
                        isDark: isDark,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionLabel(context, 'Attachments (Optional)'),
                      const SizedBox(height: 8),
                      _buildAttachmentsSection(isDark),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode
                      ? 'Edit ${_selectedType == 'loan' ? 'Loan' : 'Maintenance'}'
                      : 'Add ${_selectedType == 'loan' ? 'Loan' : 'Maintenance'}',
                  style: TextStyle(
                    color: AppColors.getTextColor(context),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _selectedType == 'loan'
                      ? 'New or existing loan'
                      : 'Schedule maintenance',
                  style: TextStyle(
                    color: AppColors.getSubtitleColor(context),
                    fontSize: 12,
                  ),
                ),
              ],
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

  Widget _buildTypeSelector(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildTypeChip('Loan', 'loan', isDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeChip('Maintenance', 'maintenance', isDark),
        ),
      ],
    );
  }

  Widget _buildTypeChip(String label, String value, bool isDark) {
    final isSelected = _selectedType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [
                    AppColors.pinkGradientStart,
                    AppColors.pinkGradientEnd,
                  ],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1)),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color:
                  isSelected ? Colors.white : AppColors.getTextColor(context),
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLoanFields(bool isDark) {
    return [
      _buildSectionLabel(context, 'Total Loan Amount *'),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _totalAmountController,
        hint: 'Enter total loan amount',
        isDark: isDark,
        keyboardType: TextInputType.number,
        prefixText: '₹ ',
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter loan amount';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter valid amount';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      _buildSectionLabel(context, 'Total Months *'),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _totalMonthsController,
        hint: 'e.g., 24, 36, 48',
        isDark: isDark,
        keyboardType: TextInputType.number,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter total months';
          }
          if (int.tryParse(value) == null) {
            return 'Please enter valid number';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      
      // SIMPLIFIED: Single Due Day Selector
      _buildSectionLabel(context, 'Monthly Due Date *'),
      const SizedBox(height: 8),
      _buildDueDaySelector(isDark),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.blueGradientStart.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: AppColors.blueGradientStart,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Payment will be due on this day every month (e.g., 25th of each month)',
                style: TextStyle(
                  color: AppColors.getTextColor(context),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      
      _buildExistingLoanSection(isDark),
    ];
  }

  Widget _buildDueDaySelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: Border.all(
          color: _selectedDueDay == null
              ? AppColors.highPriority.withOpacity(0.5)
              : (isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1)),
          width: _selectedDueDay == null ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedDueDay,
          hint: Text(
            'Select day of month',
            style: TextStyle(
              color: AppColors.highPriority,
              fontSize: 14,
            ),
          ),
          isExpanded: true,
          dropdownColor: isDark ? AppColors.darkCard : Colors.white,
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontSize: 14,
          ),
          icon: Icon(
            Icons.calendar_today,
            color: _selectedDueDay == null 
                ? AppColors.highPriority 
                : AppColors.pinkGradientStart,
          ),
          items: List.generate(31, (index) => index + 1).map((day) {
            return DropdownMenuItem<int>(
              value: day,
              child: Text('Day $day of every month'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedDueDay = value);
          },
        ),
      ),
    );
  }

  Widget _buildExistingLoanSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isExistingLoan = !_isExistingLoan;
              if (!_isExistingLoan) {
                _completedMonthsController.text = '0';
                _alreadyPaidController.text = '0';
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.purpleGradientStart.withOpacity(_isExistingLoan ? 0.2 : 0.1),
                  AppColors.purpleGradientEnd.withOpacity(_isExistingLoan ? 0.2 : 0.1),
                ],
              ),
              border: Border.all(
                color: AppColors.purpleGradientStart.withOpacity(_isExistingLoan ? 0.5 : 0.3),
                width: _isExistingLoan ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _isExistingLoan ? Icons.check_circle : Icons.info_outline,
                  color: AppColors.purpleGradientStart,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Already have an ongoing loan?',
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isExistingLoan 
                            ? 'Enter your current progress below'
                            : 'Tap to enter completed months & paid amount',
                        style: TextStyle(
                          color: AppColors.getSubtitleColor(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isExistingLoan ? Icons.expand_less : Icons.expand_more,
                  color: AppColors.purpleGradientStart,
                ),
              ],
            ),
          ),
        ),
        
        if (_isExistingLoan) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withOpacity(0.03) 
                  : Colors.black.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.blueGradientStart,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Current Loan Progress',
                      style: TextStyle(
                        color: AppColors.blueGradientStart,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Months Completed',
                            style: TextStyle(
                              color: AppColors.getSubtitleColor(context),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _completedMonthsController,
                            hint: '0',
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final completed = int.tryParse(value);
                                final total = int.tryParse(_totalMonthsController.text);
                                if (completed == null) {
                                  return 'Invalid';
                                }
                                if (total != null && completed > total) {
                                  return 'Cannot exceed total';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount Paid So Far',
                            style: TextStyle(
                              color: AppColors.getSubtitleColor(context),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _alreadyPaidController,
                            hint: '0',
                            isDark: isDark,
                            keyboardType: TextInputType.number,
                            prefixText: '₹ ',
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final paid = double.tryParse(value);
                                final total = double.tryParse(_totalAmountController.text);
                                if (paid == null) {
                                  return 'Invalid';
                                }
                                if (total != null && paid > total) {
                                  return 'Cannot exceed total';
                                }
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.greenGradientStart.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.tips_and_updates,
                        color: AppColors.greenGradientStart,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Tip: Leave as 0 for brand new loans',
                          style: TextStyle(
                            color: AppColors.getTextColor(context),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildMaintenanceFields(bool isDark) {
    return [
      _buildSectionLabel(context, 'Due Date *'),
      const SizedBox(height: 8),
      _buildMaintenanceDatePicker(isDark),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.blueGradientStart.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: AppColors.blueGradientStart,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Select when this maintenance is due. You\'ll be notified based on recurrence.',
                style: TextStyle(
                  color: AppColors.getTextColor(context),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      _buildSectionLabel(context, 'Recurrence'),
      const SizedBox(height: 8),
      _buildRecurrenceSelector(isDark),
      if (_selectedRecurrence == 'custom') ...[
        const SizedBox(height: 12),
        _buildTextField(
          controller: _customDaysController,
          hint: 'Enter number of days',
          isDark: isDark,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (_selectedRecurrence == 'custom' &&
                (value == null || value.trim().isEmpty)) {
              return 'Please enter number of days';
            }
            return null;
          },
        ),
      ],
    ];
  }

  Widget _buildMaintenanceDatePicker(bool isDark) {
    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedMaintenanceDueDate ?? now,
          firstDate: now,
          lastDate: DateTime(now.year + 5),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.pinkGradientStart,
                  onPrimary: Colors.white,
                  surface: isDark ? AppColors.darkCard : Colors.white,
                  onSurface: AppColors.getTextColor(context),
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          setState(() => _selectedMaintenanceDueDate = pickedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: _selectedMaintenanceDueDate == null
                ? AppColors.highPriority.withOpacity(0.5)
                : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1)),
            width: _selectedMaintenanceDueDate == null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: _selectedMaintenanceDueDate == null
                  ? AppColors.highPriority
                  : AppColors.pinkGradientStart,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedMaintenanceDueDate == null
                    ? 'Select maintenance due date'
                    : DateFormat('EEEE, MMM dd, yyyy').format(_selectedMaintenanceDueDate!),
                style: TextStyle(
                  color: _selectedMaintenanceDueDate == null
                      ? AppColors.highPriority
                      : AppColors.getTextColor(context),
                  fontSize: 14,
                  fontWeight: _selectedMaintenanceDueDate == null
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: AppColors.getSubtitleColor(context),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? prefixText,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: AppColors.getTextColor(context),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        prefixText: prefixText,
        prefixStyle: TextStyle(
          color: AppColors.getTextColor(context),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.getSubtitleColor(context).withOpacity(0.5),
          fontSize: 14,
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
            color: AppColors.pinkGradientStart,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.highPriority),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildRecurrenceSelector(bool isDark) {
    final recurrenceOptions = [
      {'value': 'none', 'label': 'None (One-time)'},
      {'value': 'monthly', 'label': 'Monthly'},
      {'value': 'quarterly', 'label': 'Quarterly (3 months)'},
      {'value': 'halfyearly', 'label': 'Half-Yearly (6 months)'},
      {'value': 'yearly', 'label': 'Yearly'},
      {'value': 'custom', 'label': 'Custom Days'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRecurrence,
          isExpanded: true,
          dropdownColor: isDark ? AppColors.darkCard : Colors.white,
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontSize: 14,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.getSubtitleColor(context),
          ),
          items: recurrenceOptions.map((option) {
            return DropdownMenuItem<String>(
              value: option['value'],
              child: Text(option['label']!),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedRecurrence = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection(bool isDark) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickFile,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.attach_file,
                  color: AppColors.pinkGradientStart,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Add Attachment',
                  style: TextStyle(
                    color: AppColors.getTextColor(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_attachmentPaths.isNotEmpty) ...[
          const SizedBox(height: 12),
          ..._attachmentPaths
              .map((path) => _buildAttachmentItem(path, isDark)),
        ],
      ],
    );
  }

  Widget _buildAttachmentItem(String path, bool isDark) {
    final fileName = path.split('/').last;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pinkGradientStart.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.pinkGradientStart.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.pinkGradientStart,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.description,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _attachmentPaths.remove(path);
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
        onPressed: _isLoading ? null : _saveItem,
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
                      AppColors.pinkGradientStart.withOpacity(0.5),
                      AppColors.pinkGradientEnd.withOpacity(0.5),
                    ]
                  : [
                      AppColors.pinkGradientStart,
                      AppColors.pinkGradientEnd,
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
                        _isEditMode
                            ? 'Save Changes'
                            : 'Create ${_selectedType == 'loan' ? 'Loan' : 'Maintenance'}',
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

  Future<void> _pickFile() async {
    final path = await FileService.pickFile();
    if (path != null) {
      setState(() {
        _attachmentPaths.add(path);
      });
    }
  }

  // Calculate next due date based on payment day
  DateTime _calculateNextDueDate(int dueDay, int completedMonths) {
    final now = DateTime.now();
    
    // Start from current month
    int targetMonth = now.month + completedMonths;
    int targetYear = now.year;
    
    // Handle year overflow
    while (targetMonth > 12) {
      targetMonth -= 12;
      targetYear++;
    }
    
    // Handle day overflow (e.g., Feb 30 -> Feb 28/29)
    int actualDay = dueDay;
    final lastDayOfMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    if (dueDay > lastDayOfMonth) {
      actualDay = lastDayOfMonth;
    }
    
    var nextDue = DateTime(targetYear, targetMonth, actualDay);
    
    // If the date is in the past, move to next month
    if (nextDue.isBefore(now) || nextDue.isAtSameMomentAs(now)) {
      targetMonth++;
      if (targetMonth > 12) {
        targetMonth = 1;
        targetYear++;
      }
      
      final lastDayOfNextMonth = DateTime(targetYear, targetMonth + 1, 0).day;
      if (dueDay > lastDayOfNextMonth) {
        actualDay = lastDayOfNextMonth;
      } else {
        actualDay = dueDay;
      }
      
      nextDue = DateTime(targetYear, targetMonth, actualDay);
    }
    
    return nextDue;
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validation for loans
    if (_selectedType == 'loan' && _selectedDueDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Please select due day for loan'),
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

    // Validation for maintenance
    if (_selectedType == 'maintenance' && _selectedMaintenanceDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Please select due date for maintenance'),
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

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<LoanMaintenanceProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

      final completedMonths = _selectedType == 'loan' && _completedMonthsController.text.isNotEmpty
          ? int.parse(_completedMonthsController.text)
          : 0;
      
      final alreadyPaid = _selectedType == 'loan' && _alreadyPaidController.text.isNotEmpty
          ? double.parse(_alreadyPaidController.text)
          : 0.0;

      // Calculate next due date
      DateTime nextDueDate;
      if (_selectedType == 'loan') {
        nextDueDate = _calculateNextDueDate(_selectedDueDay!, completedMonths);
      } else {
        // For maintenance, use the selected date directly
        nextDueDate = _selectedMaintenanceDueDate!;
      }

      List<PaymentRecord> paymentHistory = [];
      if (_isEditMode) {
        paymentHistory = _existingItem!.paymentHistory;
      } else if (_selectedType == 'loan' && completedMonths > 0 && alreadyPaid > 0) {
        paymentHistory.add(
          PaymentRecord(
            id: 'initial_payment_${DateTime.now().millisecondsSinceEpoch}',
            amount: alreadyPaid,
            paidDate: DateTime.now(),
            monthNumber: completedMonths,
            isPaid: true,
            notes: 'Initial payment history (Months 1-$completedMonths)',
          ),
        );
      }

      final item = LoanMaintenanceModel(
        id: _isEditMode
            ? _existingItem!.id
            : '${_selectedType}_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        type: _selectedType,
        status: _isEditMode ? _existingItem!.status : 'active',
        createdAt: _isEditMode ? _existingItem!.createdAt : DateTime.now(),
        nextDueDate: nextDueDate,
        reminderDays: int.parse(_reminderDaysController.text),
        attachmentPaths: _attachmentPaths,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        paymentDay: _selectedType == 'loan' ? _selectedDueDay : null,
        totalAmount: _selectedType == 'loan' && _totalAmountController.text.isNotEmpty
            ? double.tryParse(_totalAmountController.text)
            : null,
        totalMonths: _selectedType == 'loan' && _totalMonthsController.text.isNotEmpty
            ? int.tryParse(_totalMonthsController.text)
            : null,
        completedMonths: completedMonths,
        recurrence: _selectedType == 'maintenance' ? _selectedRecurrence : null,
        customRecurrenceDays: _selectedType == 'maintenance' && _selectedRecurrence == 'custom'
            ? int.tryParse(_customDaysController.text)
            : null,
        paymentHistory: paymentHistory,
      );

      if (_isEditMode) {
        await provider.updateItem(
          item,
          enableNotifications: settingsProvider.notificationsEnabled,
        );
      } else {
        await provider.addItem(
          item,
          enableNotifications: settingsProvider.notificationsEnabled,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(_isEditMode
                    ? '${_selectedType == 'loan' ? 'Loan' : 'Maintenance'} updated!'
                    : '${_selectedType == 'loan' ? 'Loan' : 'Maintenance'} created!'),
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
                Text('Failed to save item'),
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
        setState(() => _isLoading = false);
      }
    }
  }
}