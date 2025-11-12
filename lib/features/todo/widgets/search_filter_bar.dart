import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/providers/todo_provider.dart';

class SearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;

  const SearchFilterBar({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<TodoProvider>(
      builder: (context, todoProvider, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white,
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => todoProvider.setSearchQuery(value),
                    style: TextStyle(
                      color: AppColors.getTextColor(context),
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      hintStyle: TextStyle(
                        color: AppColors.getSubtitleColor(context).withOpacity(0.5),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.getSubtitleColor(context),
                        size: 20,
                      ),
                      suffixIcon: todoProvider.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              color: AppColors.getSubtitleColor(context),
                              onPressed: () {
                                searchController.clear();
                                todoProvider.setSearchQuery('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showFilterSheet(context, todoProvider),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: todoProvider.filterPriority != 'all'
                        ? const LinearGradient(
                            colors: [
                              AppColors.greenGradientStart,
                              AppColors.greenGradientEnd,
                            ],
                          )
                        : null,
                    color: todoProvider.filterPriority == 'all'
                        ? (isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white)
                        : null,
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.filter_list,
                    color: todoProvider.filterPriority != 'all'
                        ? Colors.white
                        : AppColors.getTextColor(context),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context, TodoProvider todoProvider) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Filter by Priority',
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _buildFilterOption(
              context,
              'All Tasks',
              'all',
              todoProvider.filterPriority,
              () {
                todoProvider.setFilterPriority('all');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildFilterOption(
              context,
              'High Priority',
              'high',
              todoProvider.filterPriority,
              () {
                todoProvider.setFilterPriority('high');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildFilterOption(
              context,
              'Medium Priority',
              'medium',
              todoProvider.filterPriority,
              () {
                todoProvider.setFilterPriority('medium');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
            _buildFilterOption(
              context,
              'Low Priority',
              'low',
              todoProvider.filterPriority,
              () {
                todoProvider.setFilterPriority('low');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(
    BuildContext context,
    String label,
    String value,
    String currentValue,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = currentValue == value;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.greenGradientStart.withOpacity(0.1)
              : (isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.03)),
          border: Border.all(
            color: isSelected
                ? AppColors.greenGradientStart
                : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1)),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.greenGradientStart,
                size: 20,
              ),
            if (isSelected) const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.greenGradientStart
                    : AppColors.getTextColor(context),
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
