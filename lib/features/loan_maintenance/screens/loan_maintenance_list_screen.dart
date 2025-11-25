import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_hub/data/models/loan_maintenance_model.dart';
import 'package:life_hub/features/loan_maintenance/widgets/loan_payment_dialog.dart';
import 'package:life_hub/features/loan_maintenance/widgets/maintenance_history.dart';
import 'package:life_hub/features/loan_maintenance/widgets/payment_history.dart';
import 'package:life_hub/features/loan_maintenance/widgets/maintenance_payment_dialog.dart';
import 'package:provider/provider.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/providers/loan_maintenance_provider.dart';
import 'package:life_hub/features/loan_maintenance/screens/add_loan_maintenance_screen.dart';
import 'package:life_hub/features/loan_maintenance/widgets/loan_item_card.dart';
import 'package:life_hub/features/loan_maintenance/widgets/maintenance_item_card.dart';

class LoanMaintenanceListScreen extends StatefulWidget {
  const LoanMaintenanceListScreen({super.key});

  @override
  State<LoanMaintenanceListScreen> createState() => _LoanMaintenanceListScreenState();
}

class _LoanMaintenanceListScreenState extends State<LoanMaintenanceListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
              Text('Add',
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
          Tab(text: 'Loans'),
          Tab(text: 'Maintenance'),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, bool isDark) {
    return Consumer<LoanMaintenanceProvider>(
      builder: (context, provider, _) {
        final isLoanTab = _tabController.index == 0;

        if (isLoanTab) {
          // SIMPLIFIED: Just show Active and Overdue counts for loans
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  '${provider.totalActiveLoans}',
                  'Active Loans',
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
                  '${provider.totalOverdueLoans}',
                  'Overdue',
                  AppColors.highPriority,
                ),
              ],
            ),
          );
        } else {
          // Show Active and Overdue counts for maintenance
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
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
                  '${provider.totalOverdueMaintenance}',
                  'Overdue',
                  AppColors.highPriority,
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
    final activeLoans = provider.activeLoans;
    final overdueLoans = provider.overdueLoans;
    
    final allLoans = [...overdueLoans, ...activeLoans.where((l) => !l.isOverdue)];

    if (allLoans.isEmpty) {
      return _buildEmptyState(
        icon: Icons.account_balance_wallet,
        title: 'No loans yet',
        subtitle: 'Track your EMIs and loan payments here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(25),
      itemCount: allLoans.length,
      itemBuilder: (context, index) {
        return LoanItemCard(
          loan: allLoans[index],
          onPaid: () => _showLoanPaymentDialog(allLoans[index]),
          onViewHistory: () => _showPaymentHistory(allLoans[index]),
          onEdit: () => _handleEdit(allLoans[index].id),
          onDelete: () => _handleDelete(allLoans[index].id, 'loan'),
        );
      },
    );
  }

  Widget _buildMaintenanceList(LoanMaintenanceProvider provider) {
    final activeMaintenance = provider.activeMaintenance;
    final overdueMaintenance = provider.overdueMaintenance;
    
    final allMaintenance = [...overdueMaintenance, ...activeMaintenance.where((m) => !m.isOverdue)];

    if (allMaintenance.isEmpty) {
      return _buildEmptyState(
        icon: Icons.build_circle,
        title: 'No maintenance tasks',
        subtitle: 'Schedule your recurring maintenance here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(25),
      itemCount: allMaintenance.length,
      itemBuilder: (context, index) {
        return MaintenanceItemCard(
          maintenance: allMaintenance[index],
          onComplete: () => _showMaintenancePaymentDialog(allMaintenance[index]),
          onViewHistory: () => _showMaintenanceHistory(allMaintenance[index]),
          onEdit: () => _handleEdit(allMaintenance[index].id),
          onDelete: () => _handleDelete(allMaintenance[index].id, 'maintenance'),
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

  void _showLoanPaymentDialog(loan) {
    showDialog(
      context: context,
      builder: (context) => LoanPaymentDialog(loan: loan),
    );
  }

  void _showMaintenancePaymentDialog(maintenance) {
    showDialog(
      context: context,
      builder: (context) => MaintenancePaymentDialog(maintenance: maintenance),
    );
  }

  void _showPaymentHistory(loan) {
    showDialog(
      context: context,
      builder: (context) => PaymentHistoryDialog(loan: loan),
    );
  }

  void _showMaintenanceHistory(maintenance) {
    showDialog(
      context: context,
      builder: (context) => MaintenanceHistoryDialog(maintenance: maintenance),
    );
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
          'Are you sure you want to delete this ${type}?',
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





