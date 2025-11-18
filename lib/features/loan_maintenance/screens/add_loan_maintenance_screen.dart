import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/data/models/loan_maintenance_model.dart';
import 'package:life_hub/providers/loan_maintenance_provider.dart';
import 'package:life_hub/providers/settings_provider.dart';
import 'package:life_hub/data/local/file_service.dart';
import 'package:intl/intl.dart';

class AddLoanMaintenanceScreen extends StatefulWidget {
  final String? itemId;
  final String? initialType; // 'loan' or 'maintenance'

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
  final TextEditingController _loanProviderController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final TextEditingController _totalMonthsController = TextEditingController();
  final TextEditingController _paymentDayController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _reminderDaysController = TextEditingController();
  final TextEditingController _customDaysController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedType = 'loan';
  String _selectedCategory = 'bike';
  String? _selectedMaintenanceType;
  String _selectedRecurrence = 'monthly';
  DateTime? _loanStartDate;
  DateTime? _nextDueDate;
  DateTime? _lastDoneDate;
  List<String> _attachmentPaths = [];
  bool _isLoading = false;
  bool _isEditMode = false;
  LoanMaintenanceModel? _existingItem;

  @override
  void initState() {
    super.initState();
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
      _updateCategoryForType();
    }
    if (widget.itemId != null) {
      _loadExistingItem();
    }
  }

  void _updateCategoryForType() {
    if (_selectedType == 'loan') {
      _selectedCategory = 'bike';
    } else {
      _selectedCategory = 'vehicle';
    }
  }

  void _loadExistingItem() {
    final provider =
        Provider.of<LoanMaintenanceProvider>(context, listen: false);
    final item = provider.getItemById(widget.itemId!);

    if (item != null) {
      setState(() {
        _isEditMode = true;
        _existingItem = item;
        _selectedType = item.type;
        _titleController.text = item.title;
        _selectedCategory = item.category;
        _notesController.text = item.notes ?? '';
        _attachmentPaths = List.from(item.attachmentPaths);
        _nextDueDate = item.nextDueDate;

        if (item.isLoan) {
          _loanProviderController.text = item.loanProvider ?? '';
          _accountNumberController.text = item.accountNumber ?? '';
          if (item.totalAmount != null) {
            _totalAmountController.text = item.totalAmount.toString();
          }
          if (item.totalMonths != null) {
            _totalMonthsController.text = item.totalMonths.toString();
          }
          if (item.paymentDay != null) {
            _paymentDayController.text = item.paymentDay.toString();
          }
          if (item.interestRate != null) {
            _interestRateController.text = item.interestRate.toString();
          }
          _loanStartDate = item.loanStartDate;
        } else {
          _selectedMaintenanceType = item.maintenanceType;
          _selectedRecurrence = item.recurrence ?? 'monthly';
          _lastDoneDate = item.lastDoneDate;
          if (item.reminderDays != null) {
            _reminderDaysController.text = item.reminderDays.toString();
          }
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
    _loanProviderController.dispose();
    _accountNumberController.dispose();
    _totalAmountController.dispose();
    _totalMonthsController.dispose();
    _paymentDayController.dispose();
    _interestRateController.dispose();
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
                      _buildSectionLabel(context, 'Category *'),
                      const SizedBox(height: 8),
                      _buildCategorySelector(isDark),
                      const SizedBox(height: 20),
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
                      ? 'Track your EMIs and payments'
                      : 'Schedule regular maintenance',
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
          child: _buildTypeChip('💰 Loan', 'loan', isDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeChip('🔧 Maintenance', 'maintenance', isDark),
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
          _updateCategoryForType();
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

  Widget _buildCategorySelector(bool isDark) {
    final categories = _selectedType == 'loan'
        ? LoanMaintenanceConfig.loanCategories
        : LoanMaintenanceConfig.maintenanceCategories;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.entries.map((entry) {
        final isSelected = _selectedCategory == entry.key;
        final config = entry.value;

        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = entry.key),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Color(config['color'] as int).withOpacity(0.2)
                  : (isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white),
              border: Border.all(
                color: isSelected
                    ? Color(config['color'] as int)
                    : (isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1)),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  config['icon'] as String,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 8),
                Text(
                  config['label'] as String,
                  style: TextStyle(
                    color: isSelected
                        ? Color(config['color'] as int)
                        : AppColors.getTextColor(context),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  List<Widget> _buildLoanFields(bool isDark) {
    return [
      _buildSectionLabel(context, 'Loan Provider/Bank *'),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _loanProviderController,
        hint: 'e.g., HDFC Bank, Bajaj Finance',
        isDark: isDark,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter loan provider';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
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
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel(context, 'Total Months *'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _totalMonthsController,
                  hint: 'e.g., 24',
                  isDark: isDark,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Required';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Invalid';
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
                _buildSectionLabel(context, 'Payment Day'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _paymentDayController,
                  hint: 'Day 1-31',
                  isDark: isDark,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final day = int.tryParse(value);
                      if (day == null || day < 1 || day > 31) {
                        return 'Invalid day';
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
      const SizedBox(height: 20),
      _buildSectionLabel(context, 'Loan Start Date'),
      const SizedBox(height: 8),
      _buildDatePicker(
        context,
        isDark,
        _loanStartDate,
        'Select loan start date',
        (date) => setState(() => _loanStartDate = date),
        canClear: true,
      ),
      const SizedBox(height: 20),
      _buildSectionLabel(context, 'Next Payment Due Date *'),
      const SizedBox(height: 8),
      _buildDatePicker(
        context,
        isDark,
        _nextDueDate,
        'Select next payment date',
        (date) => setState(() => _nextDueDate = date),
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel(context, 'Interest Rate %'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _interestRateController,
                  hint: 'e.g., 10.5',
                  isDark: isDark,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionLabel(context, 'Account Number'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _accountNumberController,
                  hint: 'Optional',
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildMaintenanceFields(bool isDark) {
    final maintenanceTypes =
        LoanMaintenanceConfig.maintenanceCategories[_selectedCategory]
            ?['types'] as List<String>?;

    return [
      if (maintenanceTypes != null) ...[
        _buildSectionLabel(context, 'Maintenance Type'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: maintenanceTypes.map((type) {
            final isSelected = _selectedMaintenanceType == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedMaintenanceType = selected ? type : null;
                });
              },
              selectedColor: AppColors.blueGradientStart.withOpacity(0.3),
              labelStyle: TextStyle(
                color: isSelected
                    ? AppColors.blueGradientStart
                    : AppColors.getTextColor(context),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
      _buildSectionLabel(context, 'Next Due Date *'),
      const SizedBox(height: 8),
      _buildDatePicker(
        context,
        isDark,
        _nextDueDate,
        'Select next due date',
        (date) => setState(() => _nextDueDate = date),
      ),
      const SizedBox(height: 20),
      _buildSectionLabel(context, 'Last Done Date (Optional)'),
      const SizedBox(height: 8),
      _buildDatePicker(
        context,
        isDark,
        _lastDoneDate,
        'Select last done date',
        (date) => setState(() => _lastDoneDate = date),
        canClear: true,
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
      const SizedBox(height: 20),
      _buildSectionLabel(context, 'Reminder (Days Before)'),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _reminderDaysController,
        hint: 'e.g., 1, 3, 7 (default: 1)',
        isDark: isDark,
        keyboardType: TextInputType.number,
      ),
    ];
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

  Widget _buildDatePicker(
    BuildContext context,
    bool isDark,
    DateTime? date,
    String hint,
    Function(DateTime?) onDateSelected, {
    bool canClear = false,
  }) {
    return GestureDetector(
      onTap: () => _selectDate(context, date, onDateSelected),
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
              color: AppColors.pinkGradientStart,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date == null ? hint : DateFormat('MMM dd, yyyy').format(date),
                style: TextStyle(
                  color: date == null
                      ? AppColors.getSubtitleColor(context)
                      : AppColors.getTextColor(context),
                  fontSize: 14,
                ),
              ),
            ),
            if (date != null && canClear)
              GestureDetector(
                onTap: () => onDateSelected(null),
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

  Future<void> _selectDate(
    BuildContext context,
    DateTime? currentDate,
    Function(DateTime?) onDateSelected,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.pinkGradientStart,
              surface: AppColors.darkCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      onDateSelected(date);
    }
  }

  Future<void> _pickFile() async {
    final path = await FileService.pickFile();
    if (path != null) {
      setState(() {
        _attachmentPaths.add(path);
      });
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_nextDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Please select next due date'),
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
      final provider =
          Provider.of<LoanMaintenanceProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      final item = LoanMaintenanceModel(
        id: _isEditMode
            ? _existingItem!.id
            : '${_selectedType}_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        type: _selectedType,
        category: _selectedCategory,
        status: _isEditMode ? _existingItem!.status : 'active',
        createdAt: _isEditMode ? _existingItem!.createdAt : DateTime.now(),
        nextDueDate: _nextDueDate!,
        attachmentPaths: _attachmentPaths,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        // Loan-specific fields
        loanProvider: _selectedType == 'loan'
            ? _loanProviderController.text.trim()
            : null,
        accountNumber: _selectedType == 'loan' &&
                _accountNumberController.text.isNotEmpty
            ? _accountNumberController.text.trim()
            : null,
        totalAmount: _selectedType == 'loan' &&
                _totalAmountController.text.isNotEmpty
            ? double.tryParse(_totalAmountController.text)
            : null,
        totalMonths: _selectedType == 'loan' &&
                _totalMonthsController.text.isNotEmpty
            ? int.tryParse(_totalMonthsController.text)
            : null,
        paymentDay: _selectedType == 'loan' &&
                _paymentDayController.text.isNotEmpty
            ? int.tryParse(_paymentDayController.text)
            : null,
        interestRate: _selectedType == 'loan' &&
                _interestRateController.text.isNotEmpty
            ? double.tryParse(_interestRateController.text)
            : null,
        loanStartDate: _selectedType == 'loan' ? _loanStartDate : null,
        loanEndDate: _selectedType == 'loan' && _loanStartDate != null
            ? _calculateLoanEndDate()
            : null,
        // Maintenance-specific fields
        maintenanceType:
            _selectedType == 'maintenance' ? _selectedMaintenanceType : null,
        reminderDays: _selectedType == 'maintenance' &&
                _reminderDaysController.text.isNotEmpty
            ? int.tryParse(_reminderDaysController.text)
            : 1,
        lastDoneDate: _selectedType == 'maintenance' ? _lastDoneDate : null,
        recurrence:
            _selectedType == 'maintenance' ? _selectedRecurrence : null,
        customRecurrenceDays: _selectedType == 'maintenance' &&
                _selectedRecurrence == 'custom'
            ? int.tryParse(_customDaysController.text)
            : null,
        payments: _isEditMode ? _existingItem!.payments : [],
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

  DateTime? _calculateLoanEndDate() {
    if (_loanStartDate == null || _totalMonthsController.text.isEmpty) {
      return null;
    }

    final totalMonths = int.tryParse(_totalMonthsController.text);
    if (totalMonths == null) return null;

    return DateTime(
      _loanStartDate!.year,
      _loanStartDate!.month + totalMonths,
      _loanStartDate!.day,
    );
  }
}