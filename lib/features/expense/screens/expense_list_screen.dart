import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/providers/expense_provider.dart';
import 'package:life_hub/features/expense/screens/add_expense_screen.dart';
import 'package:life_hub/features/expense/widgets/expense_item_card.dart';
import 'package:intl/intl.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showAllExpenses = false;
  String _settledFilter = 'all';

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
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showHistoryDialog(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.purpleGradientStart,
                    AppColors.purpleGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.history,
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
          margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          padding: const EdgeInsets.all(16),
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
            borderRadius: BorderRadius.circular(16),
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
                        'Budget',
                        style: TextStyle(
                          color: AppColors.getSubtitleColor(context),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${provider.monthlyBudget.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isOverBudget
                          ? AppColors.highPriority.withOpacity(0.2)
                          : AppColors.completed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
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
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOverBudget ? 'Over' : 'Good',
                          style: TextStyle(
                            color: isOverBudget
                                ? AppColors.highPriority
                                : AppColors.completed,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                    height: 30,
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                  Expanded(
                    child: _buildBudgetStat(
                      context,
                      'Left',
                      '₹${provider.remainingBudget.toStringAsFixed(0)}',
                      AppColors.completed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (percentage / 100).clamp(0.0, 1.0),
                  minHeight: 6,
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
              const SizedBox(height: 6),
              Text(
                '${percentage.toStringAsFixed(1)}% used',
                style: TextStyle(
                  color: AppColors.getSubtitleColor(context),
                  fontSize: 14,
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
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
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
        isScrollable: false,
        tabAlignment: TabAlignment.center,        
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
    final expenses = _showAllExpenses 
        ? provider.regularExpenses 
        : provider.lastWeekExpenses;
    
    if (expenses.isEmpty) {
      return _buildEmptyState(
        icon: Icons.receipt_long,
        title: _showAllExpenses ? 'No expenses yet' : 'No expenses this week',
        subtitle: _showAllExpenses 
            ? 'Start tracking your spending'
            : 'You haven\'t spent anything in the last 7 days',
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Filter toggle
        Container(
          margin: const EdgeInsets.fromLTRB(25, 15, 25, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _showAllExpenses 
                      ? 'Showing all expenses (${expenses.length})'
                      : 'Last 7 days (${expenses.length})',
                  style: TextStyle(
                    color: AppColors.getSubtitleColor(context),
                    fontSize: 12,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showAllExpenses = !_showAllExpenses;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _showAllExpenses
                        ? AppColors.yellowGradientStart.withOpacity(0.2)
                        : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                    border: Border.all(
                      color: _showAllExpenses
                          ? AppColors.yellowGradientStart
                          : (isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.1)),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _showAllExpenses ? Icons.filter_alt : Icons.filter_alt_outlined,
                        size: 14,
                        color: _showAllExpenses
                            ? AppColors.yellowGradientStart
                            : AppColors.getSubtitleColor(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _showAllExpenses ? 'Show Week' : 'Show All',
                        style: TextStyle(
                          color: _showAllExpenses
                              ? AppColors.yellowGradientStart
                              : AppColors.getSubtitleColor(context),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              return ExpenseItemCard(
                expense: expenses[index],
                onTap: () => _handleEdit(expenses[index].id),
                onDelete: () => _handleDelete(expenses[index].id),
              );
            },
          ),
        ),
      ],
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Total Borrowed Summary
        Container(
          margin: const EdgeInsets.fromLTRB(25, 15, 25, 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.mediumPriority.withOpacity(0.15),
                AppColors.mediumPriority.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.mediumPriority.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.mediumPriority.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_down,
                  color: AppColors.mediumPriority,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total You Owe',
                      style: TextStyle(
                        color: AppColors.getSubtitleColor(context),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${provider.totalBorrowed.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.mediumPriority,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${provider.borrowedMoney.length} ${provider.borrowedMoney.length == 1 ? 'person' : 'people'}',
                style: TextStyle(
                  color: AppColors.getSubtitleColor(context),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
            itemCount: provider.borrowedMoney.length,
            itemBuilder: (context, index) {
              return ExpenseItemCard(
                expense: provider.borrowedMoney[index],
                onTap: () => _handleEdit(provider.borrowedMoney[index].id),
                onSettle: () => _handleSettle(provider.borrowedMoney[index].id),
                onDelete: () => _handleDelete(provider.borrowedMoney[index].id),
              );
            },
          ),
        ),
      ],
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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Total Lent Summary
        Container(
          margin: const EdgeInsets.fromLTRB(25, 15, 25, 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.completed.withOpacity(0.15),
                AppColors.completed.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.completed.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.completed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: AppColors.completed,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total They Owe You',
                      style: TextStyle(
                        color: AppColors.getSubtitleColor(context),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₹${provider.totalLent.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.completed,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${provider.lentMoney.length} ${provider.lentMoney.length == 1 ? 'person' : 'people'}',
                style: TextStyle(
                  color: AppColors.getSubtitleColor(context),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
            itemCount: provider.lentMoney.length,
            itemBuilder: (context, index) {
              return ExpenseItemCard(
                expense: provider.lentMoney[index],
                onTap: () => _handleEdit(provider.lentMoney[index].id),
                onSettle: () => _handleSettle(provider.lentMoney[index].id),
                onDelete: () => _handleDelete(provider.lentMoney[index].id),
              );
            },
          ),
        ),
      ],
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Filter transactions based on selected filter
    final filteredTransactions = provider.getFilteredSettledTransactions(_settledFilter);

    return Column(
      children: [
        // Filter chips
        Container(
          margin: const EdgeInsets.fromLTRB(25, 15, 25, 10),
          height: 40,
          child: Consumer<ExpenseProvider>(
            builder: (context, provider, _) {
              final borrowed = provider.settledTransactions.where((e) => e.isBorrowed).toList();
              final lent = provider.settledTransactions.where((e) => e.isLent).toList();

              return Row(
                children: [
                  _buildFilterChip(
                    context,
                    'All (${provider.settledTransactions.length})',
                    _settledFilter == 'all',
                    isDark,
                    onTap: () {
                      setState(() {
                        _settledFilter = 'all';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    'Borrowed (${borrowed.length})',
                    _settledFilter == 'borrowed',
                    isDark,
                    onTap: () {
                      setState(() {
                        _settledFilter = 'borrowed';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    'Lent (${lent.length})',
                    _settledFilter == 'lent',
                    isDark,
                    onTap: () {
                      setState(() {
                        _settledFilter = 'lent';
                      });
                    },
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          child: filteredTransactions.isEmpty
              ? _buildEmptyState(
                  icon: Icons.filter_list_off,
                  title: 'No ${_settledFilter} transactions',
                  subtitle: 'Try selecting a different filter',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 25),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    return ExpenseItemCard(
                      expense: filteredTransactions[index],
                      onTap: () => _handleEdit(filteredTransactions[index].id),
                      onDelete: () => _handleDelete(filteredTransactions[index].id),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    bool isDark, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.completed.withOpacity(0.2)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          border: Border.all(
            color: isSelected
                ? AppColors.completed
                : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1)),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.completed
                : AppColors.getSubtitleColor(context),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
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

  void _showHistoryDialog(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate last 10 months data, but only include months with expenses
    final now = DateTime.now();
    final monthsData = <Map<String, dynamic>>[];

    for (int i = 0; i < 10; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final expenses = provider.regularExpenses.where((e) {
        return e.date.year == month.year && e.date.month == month.month;
      }).toList();

      // FIXED: Only include months that have expenses
      if (expenses.isNotEmpty) {
        final spent = expenses.fold(0.0, (sum, e) => sum + e.amount);
        final remaining = provider.monthlyBudget - spent;

        monthsData.add({
          'month': month,
          'spent': spent,
          'remaining': remaining,
          'count': expenses.length,
        });
      }
    }

    // If no history, show message
    if (monthsData.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.history,
                color: AppColors.purpleGradientStart,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Budget History',
                style: TextStyle(
                  color: AppColors.getTextColor(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppColors.getSubtitleColor(context).withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No expense history yet',
                style: TextStyle(
                  color: AppColors.getTextColor(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Start tracking your expenses to see monthly history',
                style: TextStyle(
                  color: AppColors.getSubtitleColor(context),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: AppColors.purpleGradientStart,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // Show history dialog with actual data
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.purpleGradientStart,
                      AppColors.purpleGradientEnd,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.history,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Budget History',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${monthsData.length} month${monthsData.length > 1 ? 's' : ''} with expenses',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: monthsData.length,
                  itemBuilder: (context, index) {
                    final data = monthsData[index];
                    final month = data['month'] as DateTime;
                    final spent = data['spent'] as double;
                    final remaining = data['remaining'] as double;
                    final count = data['count'] as int;
                    final percentage = (spent / provider.monthlyBudget * 100).clamp(0, 100);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMMM yyyy').format(month),
                                style: TextStyle(
                                  color: AppColors.getTextColor(context),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.purpleGradientStart.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$count expense${count > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    color: AppColors.purpleGradientStart,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Spent',
                                      style: TextStyle(
                                        color: AppColors.getSubtitleColor(context),
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      '₹${spent.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        color: AppColors.highPriority,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Remaining',
                                      style: TextStyle(
                                        color: AppColors.getSubtitleColor(context),
                                        fontSize: 10,
                                      ),
                                    ),
                                    Text(
                                      '₹${remaining.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: remaining >= 0
                                            ? AppColors.completed
                                            : AppColors.highPriority,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (percentage / 100).clamp(0.0, 1.0),
                              minHeight: 4,
                              backgroundColor: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                spent > provider.monthlyBudget
                                    ? AppColors.highPriority
                                    : AppColors.completed,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${percentage.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: AppColors.getSubtitleColor(context),
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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