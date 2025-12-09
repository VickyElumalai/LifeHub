import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/providers/expense_provider.dart';
import 'package:life_hub/features/expense/screens/add_expense_screen.dart';
import 'package:life_hub/features/expense/widgets/expense_item_card.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
            _buildBudgetCard(context, isDark),
            _buildTabBar(context, isDark),
            Expanded(
              child: Consumer<ExpenseProvider>(
                builder: (context, provider, _) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildExpensesList(provider),
                      _buildBorrowedList(provider),
                      _buildLentList(provider),
                      _buildSettledList(provider),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
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
                  'Expense Tracker',
                  style: TextStyle(
                    color: AppColors.getTextColor(context),
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Track spending & money flow',
                  style: TextStyle(
                    color: AppColors.getSubtitleColor(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showBudgetDialog(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.yellowGradientStart,
                    AppColors.yellowGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, bool isDark) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, _) {
        final percentage = provider.budgetPercentage;
        final isOverBudget = provider.totalSpent > provider.monthlyBudget;

        return Container(
          margin: const EdgeInsets.all(25),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (isOverBudget
                        ? AppColors.highPriority
                        : AppColors.yellowGradientStart)
                    .withOpacity(0.15),
                (isOverBudget
                        ? AppColors.highPriority
                        : AppColors.yellowGradientEnd)
                    .withOpacity(0.15),
              ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Monthly Budget',
                        style: TextStyle(
                          color: AppColors.getSubtitleColor(context),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${provider.monthlyBudget.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isOverBudget
                          ? AppColors.highPriority.withOpacity(0.2)
                          : AppColors.completed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isOverBudget
                              ? Icons.trending_up
                              : Icons.check_circle,
                          color: isOverBudget
                              ? AppColors.highPriority
                              : AppColors.completed,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOverBudget ? 'Over Budget' : 'On Track',
                          style: TextStyle(
                            color: isOverBudget
                                ? AppColors.highPriority
                                : AppColors.completed,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildBudgetStat(
                      context,
                      'Spent',
                      '₹${provider.totalSpent.toStringAsFixed(0)}',
                      AppColors.highPriority,
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
                    child: _buildBudgetStat(
                      context,
                      'Remaining',
                      '₹${provider.remainingBudget.toStringAsFixed(0)}',
                      AppColors.completed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (percentage / 100).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverBudget
                        ? AppColors.highPriority
                        : (percentage > 80
                            ? AppColors.mediumPriority
                            : AppColors.completed),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${percentage.toStringAsFixed(1)}% used',
                style: TextStyle(
                  color: AppColors.getSubtitleColor(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBudgetStat(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.getSubtitleColor(context),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
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
              AppColors.yellowGradientStart,
              AppColors.yellowGradientEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.getSubtitleColor(context),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: const [
          Tab(text: 'Expenses'),
          Tab(text: 'Borrowed'),
          Tab(text: 'Lent'),
          Tab(text: 'Settled'),
        ],
      ),
    );
  }

  Widget _buildExpensesList(ExpenseProvider provider) {
    if (provider.regularExpenses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.receipt_long,
        title: 'No expenses yet',
        subtitle: 'Start tracking your spending',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(25),
      itemCount: provider.regularExpenses.length,
      itemBuilder: (context, index) {
        return ExpenseItemCard(
          expense: provider.regularExpenses[index],
          onTap: () => _handleEdit(provider.regularExpenses[index].id),
          onDelete: () => _handleDelete(provider.regularExpenses[index].id),
        );
      },
    );
  }

  Widget _buildBorrowedList(ExpenseProvider provider) {
    if (provider.borrowedMoney.isEmpty) {
      return _buildEmptyState(
        icon: Icons.account_balance_wallet,
        title: 'No borrowed money',
        subtitle: 'Track money you need to pay back',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(25),
      itemCount: provider.borrowedMoney.length,
      itemBuilder: (context, index) {
        return ExpenseItemCard(
          expense: provider.borrowedMoney[index],
          onTap: () => _handleEdit(provider.borrowedMoney[index].id),
          onSettle: () => _handleSettle(provider.borrowedMoney[index].id),
          onDelete: () => _handleDelete(provider.borrowedMoney[index].id),
        );
      },
    );
  }

  Widget _buildLentList(ExpenseProvider provider) {
    if (provider.lentMoney.isEmpty) {
      return _buildEmptyState(
        icon: Icons.handshake,
        title: 'No lent money',
        subtitle: 'Track money others owe you',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(25),
      itemCount: provider.lentMoney.length,
      itemBuilder: (context, index) {
        return ExpenseItemCard(
          expense: provider.lentMoney[index],
          onTap: () => _handleEdit(provider.lentMoney[index].id),
          onSettle: () => _handleSettle(provider.lentMoney[index].id),
          onDelete: () => _handleDelete(provider.lentMoney[index].id),
        );
      },
    );
  }

  Widget _buildSettledList(ExpenseProvider provider) {
    if (provider.settledTransactions.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'No settled transactions',
        subtitle: 'Completed borrowed/lent transactions appear here',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(25),
      itemCount: provider.settledTransactions.length,
      itemBuilder: (context, index) {
        return ExpenseItemCard(
          expense: provider.settledTransactions[index],
          onTap: () => _handleEdit(provider.settledTransactions[index].id),
          onDelete: () => _handleDelete(provider.settledTransactions[index].id),
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

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddExpenseOptions(context),
      backgroundColor: Colors.transparent,
      elevation: 0,
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.yellowGradientStart,
              AppColors.yellowGradientEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.yellowGradientStart.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.add, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddExpenseOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              'Add Transaction',
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildAddOption(
              context,
              icon: Icons.shopping_bag,
              label: 'Add Expense',
              subtitle: 'Money you spent',
              color: AppColors.highPriority,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddExpenseScreen(initialType: 'expense'),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildAddOption(
              context,
              icon: Icons.account_balance_wallet,
              label: 'Money Borrowed',
              subtitle: 'Money you took (you owe)',
              color: AppColors.mediumPriority,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddExpenseScreen(initialType: 'borrowed'),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildAddOption(
              context,
              icon: Icons.handshake,
              label: 'Money Lent',
              subtitle: 'Money you gave (they owe you)',
              color: AppColors.completed,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddExpenseScreen(initialType: 'lent'),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.getTextColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.getSubtitleColor(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.getSubtitleColor(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showBudgetDialog(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final controller = TextEditingController(
      text: provider.monthlyBudget.toStringAsFixed(0),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Set Monthly Budget',
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          style: TextStyle(color: AppColors.getTextColor(context)),
          decoration: InputDecoration(
            prefixText: '₹ ',
            labelText: 'Budget Amount',
            labelStyle: TextStyle(color: AppColors.getSubtitleColor(context)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                await provider.updateBudget(amount);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Budget updated!'),
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
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.yellowGradientStart,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleEdit(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddExpenseScreen(expenseId: id),
      ),
    );
  }

  void _handleSettle(String id) async {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    await provider.markAsSettled(id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Marked as settled!'),
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

  void _handleDelete(String id) {
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
              await provider.deleteExpense(id);

              if (mounted) {
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