import 'package:flutter/material.dart';
import 'package:life_hub/core/widgets/app_logo.dart';
import 'package:life_hub/features/events/screens/events_list_screen.dart';
import 'package:life_hub/features/expense/screens/expense_list_screen.dart';
import 'package:life_hub/features/loan_maintenance/screens/loan_maintenance_list_screen.dart';
import 'package:life_hub/features/settings/widgets/profile_avatar.dart';
import 'package:life_hub/features/todo/screens/todo_list_screen.dart';
import 'package:life_hub/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/core/constants/app_strings.dart';
import 'package:life_hub/providers/loan_maintenance_provider.dart';
import 'package:life_hub/providers/event_provider.dart';
import 'package:life_hub/providers/todo_provider.dart';
import 'package:life_hub/providers/expense_provider.dart';
import 'package:life_hub/features/dashboard/widgets/dashboard_card.dart';
import 'package:life_hub/features/dashboard/widgets/stats_card.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, AppStrings.quickAccess),
                    const SizedBox(height: 15),
                    _buildQuickAccessCards(),
                    const SizedBox(height: 30),
                    _buildSectionTitle(context, AppStrings.todaysOverview),
                    const SizedBox(height: 15),
                    _buildQuickStats(),
                  ],
                ),
              ),
            ),
            _buildBottomNav(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
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
      child: Consumer<ProfileProvider>(
        builder: (context, profileProvider, _) {
          final profile = profileProvider.userProfile;
          
          return Row(
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
                  Text(
                    AppStrings.appTagline,
                    style: TextStyle(
                      color: AppColors.getSubtitleColor(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              // Use ProfileAvatar if profile exists, otherwise default avatar
              if (profile != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                  child: ProfileAvatar(
                    profile: profile,
                    size: 50,
                    showBorder: false,
                  ),
                )
              else
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
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.getTextColor(context),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildQuickAccessCards() {
    return Consumer4<LoanMaintenanceProvider, EventProvider, TodoProvider,
        ExpenseProvider>(
      builder: (context, maintenanceProvider, eventProvider, todoProvider,
          expenseProvider, _) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 0.9,
          children: [
            DashboardCard(
              icon: Image.asset(
                'assets/images/todo2.png',
                height: 40,
                width: 40,
              ),
              title: AppStrings.todo,
              count: '${todoProvider.totalTasks} tasks',
              gradientColors: const [
                AppColors.greenGradientStart,
                AppColors.greenGradientEnd,
              ],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TodoListScreen()),
                );
              },
            ),            
            DashboardCard(
              icon: Image.asset(
                'assets/images/calendar.png',
                height: 40,
                width: 40,
              ),
              title: AppStrings.events,
              count: '${eventProvider.upcomingCount} upcoming',
              gradientColors: const [
                AppColors.blueGradientStart,
                AppColors.blueGradientEnd,
              ],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EventsListScreen()),
                );
              },
            ),  
            DashboardCard(
              icon: Image.asset(
                'assets/images/maintenance.png',
                height: 30,
                width: 30,
              ),
              title: 'Loans & Maintenance',
              count: '${maintenanceProvider.totalCount} active items',
              gradientColors: const [
                AppColors.pinkGradientStart,
                AppColors.pinkGradientEnd,
              ],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  LoanMaintenanceListScreen()),
                );
              },
            ),          
            DashboardCard(
              icon: Image.asset(
                'assets/images/expense.png',
                height: 40,
                width: 40,
              ),
              title: AppStrings.expense,
              count: '\$${expenseProvider.totalSpent.toStringAsFixed(0)}',
              gradientColors: const [
                AppColors.yellowGradientStart,
                AppColors.yellowGradientEnd,
              ],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  ExpenseListScreen()),
                );
              },
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

  Widget _buildBottomNav(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.darkBackground.withOpacity(0.95)
            : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context, 0,
            Image.asset('assets/images/home.png',height: 40,width: 40,),
            'Home'
          ),
          _buildNavItem(
            context, 1,
            Image.asset('assets/images/stat.png',height: 35,width: 35,),
            'Stats'
          ),
          _buildNavItem(
            context, 2,
            Image.asset('assets/images/settings.png',height: 35,width: 35,),
            'Settings'
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, Widget icon, String label) {
    final isActive = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isActive 
                  ? AppColors.purpleGradientStart 
                  : (isDark ? AppColors.textGrey : AppColors.textLightGrey),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}