import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/providers/todo_provider.dart';
import 'package:life_hub/features/todo/screens/create_todo_screen.dart';
import 'package:life_hub/features/todo/widgets/todo_item_card.dart';
import 'package:life_hub/features/todo/widgets/search_filter_bar.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
            SearchFilterBar(searchController: _searchController),
            _buildStats(context, isDark),
            _buildTabBar(context, isDark),
            Expanded(
              child: Consumer<TodoProvider>(
                builder: (context, todoProvider, _) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTodoList(todoProvider.pendingTodos, 'pending'),
                      _buildTodoList(todoProvider.completedTodos, 'completed'),
                      _buildTodoList(todoProvider.skippedTodos, 'skipped'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateTodoScreen()),
          );
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                AppColors.greenGradientStart,
                AppColors.greenGradientEnd,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.greenGradientStart.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
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
          Text(
            'To-Do List',
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

  Widget _buildStats(BuildContext context, bool isDark) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, _) {
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
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                '${todoProvider.totalTasks}',
                'Pending',
                AppColors.pending,
              ),
              _buildDivider(isDark),
              _buildStatItem(
                context,
                '${todoProvider.completedTasks}',
                'Completed',
                AppColors.completed,
              ),
              _buildDivider(isDark),
              _buildStatItem(
                context,
                '${todoProvider.skippedTasks}',
                'Skipped',
                AppColors.mediumPriority,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
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
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      color: isDark
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.1),
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
              AppColors.greenGradientStart,
              AppColors.greenGradientEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.getSubtitleColor(context),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'Completed'),
          Tab(text: 'Skipped'),
        ],
      ),
    );
  }

  Widget _buildTodoList(List todos, String type) {
    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              type == 'pending'
                  ? 'No pending tasks'
                  : type == 'completed'
                      ? 'No completed tasks yet'
                      : 'No skipped tasks',
              style: TextStyle(
                color: AppColors.getSubtitleColor(context),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(25),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return TodoItemCard(
          todo: todos[index],
          onDone: type == 'pending' ? () => _handleDone(todos[index].id) : null,
          onSkip: type == 'pending' ? () => _handleSkip(todos[index].id) : null,
          onRestore: type == 'skipped' ? () => _handleRestore(todos[index].id) : null,
          onDelete: () => _handleDelete(todos[index].id),
          onEdit: () => _handleEdit(todos[index].id),
        );
      },
    );
  }

  void _handleDone(String id) async {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    await provider.markAsCompleted(id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Task completed!'),
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
  }

  void _handleSkip(String id) async {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    await provider.markAsSkipped(id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.fast_forward, color: Colors.white),
              SizedBox(width: 12),
              Text('Task skipped'),
            ],
          ),
          backgroundColor: AppColors.mediumPriority,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleRestore(String id) async {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    await provider.markAsPending(id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.restore, color: Colors.white),
              SizedBox(width: 12),
              Text('Task restored to pending'),
            ],
          ),
          backgroundColor: AppColors.pending,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleEdit(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateTodoScreen(todoId: id),
      ),
    );
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
          'Delete Task',
          style: TextStyle(
            color: AppColors.getTextColor(context),
          ),
        ),
        content: Text(
          'Are you sure you want to delete this task?',
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
              final provider = Provider.of<TodoProvider>(context, listen: false);
              await provider.deleteTodo(id);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 12),
                        Text('Task deleted'),
                      ],
                    ),
                    backgroundColor: AppColors.highPriority,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(seconds: 2),
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