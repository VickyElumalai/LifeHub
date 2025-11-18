import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/providers/loan_maintenance_provider.dart';
import 'package:life_hub/features/loan_maintenance/screens/add_loan_maintenance_screen.dart';
import 'package:life_hub/features/loan_maintenance/widgets/loan_item_card.dart';
import 'package:life_hub/features/loan_maintenance/widgets/maintenance_item_card.dart';
import 'package:intl/intl.dart';

class LoanMaintenanceListScreen extends StatefulWidget {
  const LoanMaintenanceListScreen({super.key});

  @override
  State<LoanMaintenanceListScreen> createState() => _LoanMaintenanceListScreenState();
}

class _LoanMaintenanceListScreenState extends State<LoanMaintenanceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedCategory = 'all'; // Reset category when switching tabs
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            _buildTabBar(context, isDark),
            _buildCategoryFilter(context, isDark),
            _buildStats(context, isDark),
            Expanded(
              child: Consumer<LoanMaintenanceProvider>(
                builder: (context, provider, _) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLoansList(provider),
                      _buildMaintenanceList(provider),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddLoanMaintenanceScreen(
                initialType: _tabController.index == 0 ? 'loan' : 'maintenance',
              ),
            ),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.pinkGradientStart,
                AppColors.pinkGradientEnd,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.pinkGradientStart.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.add, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Text(
                _tabController.index == 0 ? 'Add Loan' : 'Add Maintenance',
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
                  Icons.arrow_back_ios_new,
                  color: AppColors.getTextColor(context),
                  size: 18,
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
                  'Loans & Maintenance',
                  style: TextStyle(
                    color: AppColors.getTextColor(context),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Track payments & schedules',
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

  Widget _buildTabBar(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(25, 15, 25, 0),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.pinkGradientStart,
              AppColors.pinkGradientEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.getSubtitleColor(context),
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('💰', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text('Loans'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🔧', style: TextStyle(fontSize: 18)),
                SizedBox(width: 8),
                Text('Maintenance'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, bool isDark) {
    final isLoanTab = _tabController.index == 0;
    final categories = isLoanTab
        ? [
            {'value': 'all', 'label': 'All', 'icon': '📋'},
            {'value': 'bike', 'label': 'Bike', 'icon': '🏍️'},
            {'value': 'home', 'label': 'Home', 'icon': '🏠'},
            {'value': 'chittu', 'label': 'Chittu', 'icon': '💰'},
            {'value': 'personal', 'label': 'Personal', 'icon': '💳'},
          ]
        : [
            {'value': 'all', 'label': 'All', 'icon': '📋'},
            {'value': 'vehicle', 'label': 'Vehicle', 'icon': '🚗'},
            {'value': 'home', 'label': 'Home', 'icon': '🏠'},
            {'value': 'appliance', 'label': 'Appliance', 'icon': '🔌'},
          ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['value'];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category['value'] as String;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    : (isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white),
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
              child: Row(
                children: [
                  Text(
                    category['icon'] as String,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category['label'] as String,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.getTextColor(context),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats(BuildContext context, bool isDark) {
    return Consumer<LoanMaintenanceProvider>(
      builder: (context, provider, _) {
        final isLoanTab = _tabController.index == 0;

        if (isLoanTab) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.greenGradientStart.withOpacity(0.15),
                  AppColors.greenGradientEnd.withOpacity(0.15),
                ],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildStatColumn(
                        context,
                        '${provider.totalActiveLoans}',
                        'Active Loans',
                        AppColors.pinkGradientStart,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                    ),
                    Expanded(
                      child: _buildStatColumn(
                        context,
                        '${provider.totalOverdue}',
                        'Overdue',
                        AppColors.highPriority,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              color: AppColors.getSubtitleColor(context),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${provider.totalLoanAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: AppColors.getTextColor(context),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Paid',
                            style: TextStyle(
                              color: AppColors.getSubtitleColor(context),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${provider.totalLoanPaid.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.completed,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Remaining',
                            style: TextStyle(
                              color: AppColors.getSubtitleColor(context),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${provider.totalLoanRemaining.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.mediumPriority,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.blueGradientStart.withOpacity(0.15),
                  AppColors.blueGradientEnd.withOpacity(0.15),
                ],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  '${provider.totalActiveMaintenance}',
                  'Active',
                  AppColors.pinkGradientStart,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
                _buildStatColumn(
                  context,
                  '${provider.totalOverdue}',
                  'Overdue',
                  AppColors.highPriority,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
                _buildStatColumn(
                  context,
                  '${provider.dueSoonItems.length}',
                  'Due Soon',
                  AppColors.mediumPriority,
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildStatColumn(
      BuildContext context, String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.getSubtitleColor(context),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoansList(LoanMaintenanceProvider provider) {
    final loans = provider.getActiveLoansByCategory(_selectedCategory);

    if (loans.isEmpty) {
      return _buildEmptyState(
        icon: Icons.account_balance_wallet,
        title: 'No active loans',
        subtitle: 'Track your EMIs and loan payments here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(25),
      itemCount: loans.length,
      itemBuilder: (context, index) {
        return LoanItemCard(
          loan: loans[index],
          onPay: () => _handlePayment(loans[index].id),
          onViewHistory: () => _showPaymentHistory(loans[index]),
          onEdit: () => _handleEdit(loans[index].id),
          onDelete: () => _handleDelete(loans[index].id, 'loan'),
        );
      },
    );
  }

  Widget _buildMaintenanceList(LoanMaintenanceProvider provider) {
    final maintenance = provider.getActiveMaintenanceByCategory(_selectedCategory);

    if (maintenance.isEmpty) {
      return _buildEmptyState(
        icon: Icons.build_circle,
        title: 'No active maintenance',
        subtitle: 'Track your vehicle and home maintenance here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(25),
      itemCount: maintenance.length,
      itemBuilder: (context, index) {
        return MaintenanceItemCard(
          maintenance: maintenance[index],
          onComplete: () => _handleComplete(maintenance[index].id),
          onEdit: () => _handleEdit(maintenance[index].id),
          onDelete: () => _handleDelete(maintenance[index].id, 'maintenance'),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.getSubtitleColor(context).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: AppColors.getSubtitleColor(context),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handlePayment(String loanId) {
    showDialog(
      context: context,
      builder: (context) => _PaymentDialog(loanId: loanId),
    );
  }

  void _showPaymentHistory(loan) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PaymentHistorySheet(loan: loan),
    );
  }

  void _handleComplete(String id) async {
    final provider = Provider.of<LoanMaintenanceProvider>(context, listen: false);
    await provider.markMaintenanceAsCompleted(id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Maintenance completed!'),
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
  }

  void _handleEdit(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddLoanMaintenanceScreen(itemId: id),
      ),
    );
  }

  void _handleDelete(String id, String type) {
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
          'Delete ${type == 'loan' ? 'Loan' : 'Maintenance'}',
          style: TextStyle(
            color: AppColors.getTextColor(context),
          ),
        ),
        content: Text(
          'Are you sure you want to delete this ${type}? This action cannot be undone.',
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
                  Provider.of<LoanMaintenanceProvider>(context, listen: false);
              await provider.deleteItem(id);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.white),
                        const SizedBox(width: 12),
                        Text('${type == 'loan' ? 'Loan' : 'Maintenance'} deleted'),
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

// Payment Dialog
class _PaymentDialog extends StatefulWidget {
  final String loanId;

  const _PaymentDialog({required this.loanId});

  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _transactionIdController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedPaymentMethod = 'upi';

  @override
  void dispose() {
    _amountController.dispose();
    _transactionIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<LoanMaintenanceProvider>(context, listen: false);
    final loan = provider.getItemById(widget.loanId);

    if (loan == null) {
      Navigator.pop(context);
      return const SizedBox.shrink();
    }

    // Pre-fill with average payment amount
    if (_amountController.text.isEmpty && loan.averagePayment > 0) {
      _amountController.text = loan.averagePayment.toStringAsFixed(0);
    }

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Record Payment',
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            loan.title,
            style: TextStyle(
              color: AppColors.getSubtitleColor(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.getTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Amount *',
                prefixText: '₹ ',
                labelStyle: TextStyle(color: AppColors.getSubtitleColor(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment Method',
              style: TextStyle(
                color: AppColors.getSubtitleColor(context),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['upi', 'online', 'cash', 'card', 'cheque'].map((method) {
                final isSelected = _selectedPaymentMethod == method;
                return ChoiceChip(
                  label: Text(method.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPaymentMethod = method;
                    });
                  },
                  selectedColor: AppColors.greenGradientStart.withOpacity(0.3),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.greenGradientStart
                        : AppColors.getTextColor(context),
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _transactionIdController,
              style: TextStyle(color: AppColors.getTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Transaction ID (Optional)',
                labelStyle: TextStyle(color: AppColors.getSubtitleColor(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 2,
              style: TextStyle(color: AppColors.getTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                labelStyle: TextStyle(color: AppColors.getSubtitleColor(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: AppColors.getSubtitleColor(context)),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_amountController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter amount')),
              );
              return;
            }

            await provider.recordLoanPayment(
              loanId: widget.loanId,
              amount: double.parse(_amountController.text),
              paymentMethod: _selectedPaymentMethod,
              transactionId: _transactionIdController.text.isEmpty
                  ? null
                  : _transactionIdController.text,
              notes: _notesController.text.isEmpty
                  ? null
                  : _notesController.text,
            );

            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Payment recorded!'),
                  ],
                ),
                backgroundColor: AppColors.completed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.completed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Record Payment'),
        ),
      ],
    );
  }
}

// Payment History Sheet
class _PaymentHistorySheet extends StatelessWidget {
  final loan;

  const _PaymentHistorySheet({required this.loan});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.getSubtitleColor(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Payment History',
                  style: TextStyle(
                    color: AppColors.getTextColor(context),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  loan.title,
                  style: TextStyle(
                    color: AppColors.getSubtitleColor(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.greenGradientStart.withOpacity(0.15),
                        AppColors.greenGradientEnd.withOpacity(0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${loan.completedMonths}/${loan.totalMonths}',
                            style: TextStyle(
                              color: AppColors.getTextColor(context),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Months',
                            style: TextStyle(
                              color: AppColors.getSubtitleColor(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.1),
                      ),
                      Column(
                        children: [
                          Text(
                            '₹${loan.totalPaid.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.completed,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Paid',
                            style: TextStyle(
                              color: AppColors.getSubtitleColor(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.1),
                      ),
                      Column(
                        children: [
                          Text(
                            '₹${loan.remainingAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.mediumPriority,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Remaining',
                            style: TextStyle(
                              color: AppColors.getSubtitleColor(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: loan.payments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 48,
                          color: AppColors.getSubtitleColor(context)
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No payments yet',
                          style: TextStyle(
                            color: AppColors.getSubtitleColor(context),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: loan.payments.length,
                    itemBuilder: (context, index) {
                      final payment = loan.payments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.completed.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${payment.monthNumber ?? index + 1}',
                                  style: const TextStyle(
                                    color: AppColors.completed,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        '₹${payment.amount.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          color: AppColors.getTextColor(context),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.purpleGradientStart
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          payment.paymentMethod.toUpperCase(),
                                          style: TextStyle(
                                            color: AppColors.purpleGradientStart,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Paid on ${payment.paidDate != null ? DateFormat('MMM dd, yyyy').format(payment.paidDate!) : 'N/A'}',
                                    style: TextStyle(
                                      color: AppColors.getSubtitleColor(context),
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (payment.transactionId != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'TXN: ${payment.transactionId}',
                                      style: TextStyle(
                                        color: AppColors.getSubtitleColor(context),
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.completed,
                              size: 20,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}