import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/data/models/expense_model.dart';
import 'package:life_hub/providers/expense_provider.dart';
import 'package:life_hub/data/service/file_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? expenseId;
  final String? initialType;

  const AddExpenseScreen({super.key, this.expenseId, this.initialType});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _personNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedType = 'expense';
  DateTime _selectedDate = DateTime.now();
  String? _attachmentPath;
  bool _isLoading = false;
  bool _isEditMode = false;
  ExpenseModel? _existingExpense;

  @override
  void initState() {
    super.initState();
    
    if (widget.initialType != null) {
      _selectedType = widget.initialType!;
    }
    
    if (widget.expenseId != null) {
      _loadExistingExpense();
    }
  }

  void _loadExistingExpense() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final expense = provider.getExpenseById(widget.expenseId!);

    if (expense != null) {
      setState(() {
        _isEditMode = true;
        _existingExpense = expense;
        _amountController.text = expense.amount.toStringAsFixed(0);
        _descriptionController.text = expense.description;
        _selectedType = expense.type;
        _selectedDate = expense.date;
        _attachmentPath = expense.attachmentPath;
        if (expense.personName != null) {
          _personNameController.text = expense.personName!;
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _personNameController.dispose();
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
                      _buildSectionLabel(context, 'Amount *'),
                      const SizedBox(height: 8),
                      _buildAmountField(context, isDark),
                      const SizedBox(height: 20),
                      if (_selectedType != 'expense') ...[
                        _buildSectionLabel(context, 'Person Name *'),
                        const SizedBox(height: 8),
                        _buildPersonNameField(context, isDark),
                        const SizedBox(height: 20),
                      ],
                      _buildSectionLabel(context, 'Description'),
                      const SizedBox(height: 8),
                      _buildDescriptionField(context, isDark),
                      const SizedBox(height: 20),
                      _buildSectionLabel(context, 'Date'),
                      const SizedBox(height: 8),
                      _buildDatePicker(context, isDark),
                      const SizedBox(height: 20),
                      _buildSectionLabel(context, 'Attachment (Optional)'),
                      const SizedBox(height: 8),
                      _buildAttachmentSection(context, isDark),
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
            child: Text(
              _isEditMode ? 'Edit Transaction' : _getTypeTitle(),
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
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

  String _getTypeTitle() {
    switch (_selectedType) {
      case 'borrowed':
        return 'Add Borrowed Money';
      case 'lent':
        return 'Add Lent Money';
      default:
        return 'Add Expense';
    }
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
          child: _buildTypeChip('Expense', 'expense', Icons.shopping_bag, isDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeChip('Borrowed', 'borrowed', Icons.account_balance_wallet, isDark),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTypeChip('Lent', 'lent', Icons.handshake, isDark),
        ),
      ],
    );
  }

  Widget _buildTypeChip(String label, String value, IconData icon, bool isDark) {
    final isSelected = _selectedType == value;
    Color color;
    switch (value) {
      case 'borrowed':
        color = AppColors.mediumPriority;
        break;
      case 'lent':
        color = AppColors.completed;
        break;
      default:
        color = AppColors.highPriority;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
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
          child: 
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.getTextColor(context),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          
        ),
      ),
    );
  }

  Widget _buildAmountField(BuildContext context, bool isDark) {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter amount';
        }
        if (double.tryParse(value) == null || double.parse(value) <= 0) {
          return 'Please enter valid amount';
        }
        return null;
      },
      style: TextStyle(
        color: AppColors.getTextColor(context),
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        prefixText: '₹ ',
        prefixStyle: TextStyle(
          color: AppColors.getTextColor(context),
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        hintText: '0',
        hintStyle: TextStyle(
          color: AppColors.getSubtitleColor(context).withOpacity(0.5),
          fontSize: 24,
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.yellowGradientStart,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonNameField(BuildContext context, bool isDark) {
    return TextFormField(
      controller: _personNameController,
      validator: (value) {
        if (_selectedType != 'expense' &&
            (value == null || value.trim().isEmpty)) {
          return 'Please enter person name';
        }
        return null;
      },
      style: TextStyle(
        color: AppColors.getTextColor(context),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: 'e.g., John Doe',
        hintStyle: TextStyle(
          color: AppColors.getSubtitleColor(context).withOpacity(0.5),
          fontSize: 14,
        ),
        prefixIcon: Icon(
          Icons.person,
          color: AppColors.getSubtitleColor(context),
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.yellowGradientStart,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(BuildContext context, bool isDark) {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 3,
      maxLength: 200,
      style: TextStyle(
        color: AppColors.getTextColor(context),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: _selectedType == 'expense'
            ? 'e.g., Grocery shopping'
            : _selectedType == 'borrowed'
                ? 'e.g., Emergency medical expense'
                : 'e.g., Friend needed for rent',
        hintStyle: TextStyle(
          color: AppColors.getSubtitleColor(context).withOpacity(0.5),
          fontSize: 14,
        ),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.yellowGradientStart,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppColors.yellowGradientStart,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
                style: TextStyle(
                  color: AppColors.getTextColor(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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

  Widget _buildAttachmentSection(BuildContext context, bool isDark) {
    if (_attachmentPath == null) {
      return GestureDetector(
        onTap: _pickImage,
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.attach_file,
                color: AppColors.yellowGradientStart,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Add Receipt/Bill',
                style: TextStyle(
                  color: AppColors.getTextColor(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(_attachmentPath!),
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
                _attachmentPath = null;
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

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveExpense,
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
                      AppColors.yellowGradientStart.withOpacity(0.5),
                      AppColors.yellowGradientEnd.withOpacity(0.5),
                    ]
                  : [
                      AppColors.yellowGradientStart,
                      AppColors.yellowGradientEnd,
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
                        _isEditMode ? 'Save Changes' : 'Add Transaction',
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

  Future<void> _selectDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.yellowGradientStart,
              surface: AppColors.darkCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
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
              _buildImageOption(
                context,
                icon: Icons.camera_alt,
                label: 'Take Photo',
                onTap: () async {
                  Navigator.pop(context);
                  final path = await FileService.pickImageFromCamera();
                  if (path != null) {
                    setState(() {
                      _attachmentPath = path;
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
                      _attachmentPath = path;
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
              color: AppColors.yellowGradientStart,
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

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);

      String status;
      if (_selectedType == 'expense') {
        status = 'paid';
      } else {
        status = _isEditMode && _existingExpense != null
            ? _existingExpense!.status
            : 'pending';
      }

      final expense = ExpenseModel(
        id: _isEditMode
            ? _existingExpense!.id
            : 'expense_${DateTime.now().millisecondsSinceEpoch}',
        amount: double.parse(_amountController.text),
        type: _selectedType,
        date: _selectedDate,
        createdAt:
            _isEditMode ? _existingExpense!.createdAt : DateTime.now(),
        description: _descriptionController.text.trim().isEmpty
            ? (_selectedType == 'expense'
                ? 'Expense'
                : _selectedType == 'borrowed'
                    ? 'Borrowed money'
                    : 'Lent money')
            : _descriptionController.text.trim(),
        status: status,
        personName: _selectedType == 'expense'
            ? null
            : _personNameController.text.trim(),
        attachmentPath: _attachmentPath,
      );

      if (_isEditMode) {
        await provider.updateExpense(expense);
      } else {
        await provider.addExpense(expense);
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
                    ? 'Transaction updated!'
                    : 'Transaction added!'),
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
              children: const [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Failed to save transaction'),
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
          'Delete Transaction',
          style: TextStyle(
            color: AppColors.getTextColor(context),
          ),
        ),
        content: Text(
          'Are you sure you want to delete this transaction?',
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
              Navigator.pop(context);
              final provider =
                  Provider.of<ExpenseProvider>(context, listen: false);
              await provider.deleteExpense(widget.expenseId!);

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Transaction deleted'),
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
              style: TextStyle(color: AppColors.highPriority),
            ),
          ),
        ],
      ),
    );
  }
}