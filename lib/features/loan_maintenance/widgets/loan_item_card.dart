import 'package:flutter/material.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/data/models/loan_maintenance_model.dart';
import 'package:intl/intl.dart';

class LoanItemCard extends StatelessWidget {
  final LoanMaintenanceModel loan;
  final VoidCallback? onPaid;
  final VoidCallback? onViewHistory;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LoanItemCard({
    super.key,
    required this.loan,
    this.onPaid,
    this.onViewHistory,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: Border.all(
          color: loan.isOverdue
              ? AppColors.highPriority.withOpacity(0.5)
              : (isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1)),
          width: loan.isOverdue ? 2 : 1,
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
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.greenGradientStart,
                            AppColors.greenGradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 24,
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
                              Expanded(
                                child: Text(
                                  loan.title,
                                  style: TextStyle(
                                    color: AppColors.getTextColor(context),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              // MOVED: Total amount to right side of title
                              Text(
                                '₹${loan.totalAmount?.toStringAsFixed(0) ?? '0'}',
                                style: TextStyle(
                                  color: AppColors.getTextColor(context),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Month ${loan.completedMonths}/${loan.totalMonths}',
                            style: TextStyle(
                              color: AppColors.getSubtitleColor(context),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (loan.isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.highPriority.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.warning_amber,
                              color: AppColors.highPriority,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'OVERDUE',
                              style: TextStyle(
                                color: AppColors.highPriority,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProgressSection(context, isDark),
                const SizedBox(height: 16),
                // CHANGED: Show Paid, Remaining, and next due date
                _buildAmountSection(context),
                const SizedBox(height: 16),
                _buildNextDueDateSection(context, isDark),
                if (loan.notes != null && loan.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.purpleGradientStart.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 16,
                          color: AppColors.getSubtitleColor(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loan.notes!,
                            style: TextStyle(
                              color: AppColors.getTextColor(context),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildActions(context, isDark),
        ],
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                color: AppColors.getSubtitleColor(context),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${loan.progressPercentage.toStringAsFixed(1)}%',
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: loan.progressPercentage / 100,
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
              loan.progressPercentage >= 75
                  ? AppColors.completed
                  : (loan.progressPercentage >= 50
                      ? AppColors.mediumPriority
                      : AppColors.pinkGradientStart),
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${loan.remainingMonths} months remaining',
          style: TextStyle(
            color: AppColors.getSubtitleColor(context),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // UPDATED: Now shows Paid and Remaining
  Widget _buildAmountSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.greenGradientStart.withOpacity(0.1),
            AppColors.greenGradientEnd.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greenGradientStart.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paid',
                  style: TextStyle(
                    color: AppColors.getSubtitleColor(context),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${loan.totalPaid.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.completed,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.greenGradientStart.withOpacity(0.3),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remaining',
                  style: TextStyle(
                    color: AppColors.getSubtitleColor(context),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${loan.remainingAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.mediumPriority,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextDueDateSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: loan.isOverdue
            ? AppColors.highPriority.withOpacity(0.1)
            : (loan.isDueToday
                ? AppColors.mediumPriority.withOpacity(0.1)
                : AppColors.pinkGradientStart.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: loan.isOverdue
              ? AppColors.highPriority.withOpacity(0.3)
              : (loan.isDueToday
                  ? AppColors.mediumPriority.withOpacity(0.3)
                  : AppColors.pinkGradientStart.withOpacity(0.1)),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            loan.isOverdue
                ? Icons.error_outline
                : (loan.isDueToday
                    ? Icons.today
                    : Icons.calendar_today),
            size: 18,
            color: loan.isOverdue
                ? AppColors.highPriority
                : (loan.isDueToday
                    ? AppColors.mediumPriority
                    : AppColors.getSubtitleColor(context)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan.isOverdue
                      ? 'Payment Overdue!'
                      : (loan.isDueToday
                          ? 'Payment Due Today'
                          : 'Next Payment Due'),
                  style: TextStyle(
                    color: loan.isOverdue
                        ? AppColors.highPriority
                        : (loan.isDueToday
                            ? AppColors.mediumPriority
                            : AppColors.getSubtitleColor(context)),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(loan.nextDueDate),
                  style: TextStyle(
                    color: AppColors.getTextColor(context),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          if (onViewHistory != null && loan.paymentHistory.isNotEmpty) ...[
            _buildActionButton(
              label: 'History',
              icon: Icons.history,
              color: AppColors.purpleGradientStart,
              onTap: onViewHistory,
            ),
            const SizedBox(width: 20),
          ],
          if (onEdit != null) ...[
            _buildActionButton(
              label: 'Edit',
              icon: Icons.edit,
              color: AppColors.blueGradientStart,
              onTap: onEdit,
            ),
            const SizedBox(width: 20),
          ],
          if (onPaid != null && loan.status == 'active') ...[
            _buildActionButton(
              label: 'Mark Paid',
              icon: Icons.payment,
              color: AppColors.completed,
              onTap: onPaid,
            ),
            const SizedBox(width: 20),
          ],
          if (onDelete != null) ...[
            _buildActionButton(
              label: 'Delete',
              icon: Icons.delete,
              color: AppColors.highPriority,
              onTap: onDelete,
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}