import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/data/models/expense_model.dart';

class ExpenseItemCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onTap;
  final VoidCallback? onSettle;
  final VoidCallback? onDelete;

  const ExpenseItemCard({
    super.key,
    required this.expense,
    required this.onTap,
    this.onSettle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: _getBorderColor().withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getGradientColors(),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getIcon(),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    expense.description,
                                    style: TextStyle(
                                      color: AppColors.getTextColor(context),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildStatusBadge(),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: AppColors.getSubtitleColor(context),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(expense.date),
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
                  if (expense.personName != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getBorderColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: _getBorderColor(),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            expense.isBorrowed
                                ? 'Borrowed from: ${expense.personName}'
                                : 'Lent to: ${expense.personName}',
                            style: TextStyle(
                              color: AppColors.getTextColor(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Amount',
                        style: TextStyle(
                          color: AppColors.getSubtitleColor(context),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '₹${expense.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: _getBorderColor(),
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (expense.attachmentPath != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(expense.attachmentPath!),
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            color: Colors.grey.withOpacity(0.2),
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 30),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onSettle != null || onDelete != null)
              _buildActions(context, isDark),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (expense.type) {
      case 'borrowed':
        return Icons.account_balance_wallet;
      case 'lent':
        return Icons.handshake;
      default:
        return Icons.shopping_bag;
    }
  }

  Color _getBorderColor() {
    switch (expense.type) {
      case 'borrowed':
        return AppColors.mediumPriority;
      case 'lent':
        return AppColors.completed;
      default:
        return AppColors.highPriority;
    }
  }

  List<Color> _getGradientColors() {
    switch (expense.type) {
      case 'borrowed':
        return [
          AppColors.mediumPriority,
          AppColors.mediumPriority.withOpacity(0.7),
        ];
      case 'lent':
        return [
          AppColors.greenGradientStart,
          AppColors.greenGradientEnd,
        ];
      default:
        return [
          AppColors.pinkGradientStart,
          AppColors.pinkGradientEnd,
        ];
    }
  }

  Widget _buildStatusBadge() {
    if (expense.isExpense) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: expense.isSettled
            ? AppColors.completed.withOpacity(0.2)
            : AppColors.mediumPriority.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        expense.isSettled ? 'SETTLED' : 'PENDING',
        style: TextStyle(
          color: expense.isSettled
              ? AppColors.completed
              : AppColors.mediumPriority,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (onSettle != null && expense.isPending) ...[
            GestureDetector(
              onTap: onSettle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.completed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.completed.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.completed,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Mark Settled',
                      style: TextStyle(
                        color: AppColors.completed,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.highPriority,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}