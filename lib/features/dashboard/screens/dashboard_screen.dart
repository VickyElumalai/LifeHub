import 'package:flutter/material.dart';
import 'package:life_hub/core/widgets/app_logo.dart';
import 'package:provider/provider.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/core/constants/app_strings.dart';
import 'package:life_hub/providers/maintenance_provider.dart';
import 'package:life_hub/providers/event_provider.dart';
import 'package:life_hub/providers/todo_provider.dart';
import 'package:life_hub/providers/expense_provider.dart';
import 'package:life_hub/features/dashboard/widgets/dashboard_card.dart';
import 'package:life_hub/features/dashboard/widgets/stats_card.dart';
import 'package:life_hub/features/maintenance/screens/maintenance_list_screen.dart';
import 'package:life_hub/features/events/screens/events_list_screen.dart';
import 'package:life_hub/features/todo/screens/todo_list_screen.dart';
import 'package:life_hub/features/expense/screens/expense_list_screen.dart';
import 'package:life_hub/features/settings/screens/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(AppStrings.quickAccess),
                    const SizedBox(height: 15),
                    _buildQuickAccessCards(),
                    const SizedBox(height: 30),
                    _buildSectionTitle(AppStrings.todaysOverview),
                    const SizedBox(height: 15),
                    _buildQuickStats(),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppLogo(
                    size: 35,
                    showText: false,
                    animated: false,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Text(
                AppStrings.appTagline,
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.purpleGradientStart,
                  AppColors.purpleGradientEnd,
                ],
              ),
            ),
            child: const Center(
              child: Text(
                'JD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildQuickAccessCards() {
    return Consumer4<MaintenanceProvider, EventProvider, TodoProvider,
        ExpenseProvider>(
      builder: (context, maintenanceProvider, eventProvider, todoProvider,
          expenseProvider, _) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 1.1,
          children: [
            DashboardCard(
              icon: '🔧',
              title: AppStrings.maintenance,
              count: '${maintenanceProvider.pendingCount} pending',
              gradientColors: const [
                AppColors.pinkGradientStart,
                AppColors.pinkGradientEnd,
              ],
               onTap: () => null,
              // onTap: () => _navigateToScreen(
              //   //const MaintenanceListScreen()
              // ),
            ),
            DashboardCard(
              icon: '📅',
              title: AppStrings.events,
              count: '${eventProvider.upcomingCount} upcoming',
              gradientColors: const [
                AppColors.blueGradientStart,
                AppColors.blueGradientEnd,
              ],
               onTap: () => null,
              // onTap: () => _navigateToScreen(
              //  // const EventsListScreen()
              // ),
            ),
            DashboardCard(
              icon: '✓',
              title: AppStrings.todo,
              count: '${todoProvider.totalTasks} tasks',
              gradientColors: const [
                AppColors.greenGradientStart,
                AppColors.greenGradientEnd,
              ],
               onTap: () => null,
              // onTap: () => _navigateToScreen(
              //  // const TodoListScreen()
              // ),
            ),
            DashboardCard(
              icon: '💰',
              title: AppStrings.expense,
              count: '\$${expenseProvider.totalSpent.toStringAsFixed(0)}',
              gradientColors: const [
                AppColors.yellowGradientStart,
                AppColors.yellowGradientEnd,
              ],
               onTap: () => null,
              // onTap: () => _navigateToScreen(
              //  // const ExpenseListScreen()
              // ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return Consumer2<TodoProvider, ExpenseProvider>(
      builder: (context, todoProvider, expenseProvider, _) {
        return StatsCardGroup(
          stats: [
            StatsCardData(
              label: 'Tasks Completed',
              value: '${todoProvider.completedTasks}/${todoProvider.totalTasks}',
              progress: todoProvider.completionPercentage / 100,
            ),
            StatsCardData(
              label: 'Budget Used',
              value: '\$${expenseProvider.totalSpent.toStringAsFixed(0)}/\$${expenseProvider.monthlyBudget.toStringAsFixed(0)}',
              progress: expenseProvider.budgetPercentage / 100,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, '🏠', 'Home'),
          _buildNavItem(1, '📊', 'Stats'),
          _buildNavItem(2, '➕', 'Add'),
          _buildNavItem(3, '⚙️', 'Settings'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String icon, String label) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.purpleGradientStart : AppColors.textGrey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }
}