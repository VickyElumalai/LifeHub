import 'dart:io';
import 'package:flutter/material.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/data/models/loan_maintenance_model.dart';
import 'package:intl/intl.dart';

class MaintenanceItemCard extends StatelessWidget {
  final LoanMaintenanceModel maintenance;
  final VoidCallback? onComplete;
  final VoidCallback? onViewHistory;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MaintenanceItemCard({
    super.key,
    required this.maintenance,
    this.onComplete,
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
          color: maintenance.isOverdue
              ? AppColors.highPriority.withOpacity(0.5)
              : (isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1)),
          width: maintenance.isOverdue ? 2 : 1,
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
                            AppColors.blueGradientStart,
                            AppColors.blueGradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.build_circle,
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
                          Text(
                            maintenance.title,
                            style: TextStyle(
                              color: AppColors.getTextColor(context),
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                _getRecurrenceText(),
                                style: TextStyle(
                                  color: AppColors.getSubtitleColor(context),
                                  fontSize: 13,
                                ),
                              ),
                              if (maintenance.paymentHistory.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.completed.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${maintenance.paymentHistory.length} done',
                                    style: const TextStyle(
                                      color: AppColors.completed,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (maintenance.isOverdue)
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
                _buildNextDueDateSection(context, isDark),
                if (maintenance.lastDoneDate != null) ...[
                  const SizedBox(height: 12),
                  _buildLastDoneSection(context, isDark),
                ],
                if (maintenance.notes != null && maintenance.notes!.isNotEmpty) ...[
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
                            maintenance.notes!,
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
                if (maintenance.attachmentPaths.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildAttachments(context, isDark),
                ],
              ],
            ),
          ),
          if (maintenance.status == 'active') _buildActions(context, isDark),
        ],
      ),
    );
  }

  String _getRecurrenceText() {
    switch (maintenance.recurrence) {
      case 'none':
        return 'One-time task';
      case 'monthly':
        return 'Recurring monthly';
      case 'quarterly':
        return 'Recurring quarterly';
      case 'halfyearly':
        return 'Recurring half-yearly';
      case 'yearly':
        return 'Recurring yearly';
      case 'custom':
        return 'Every ${maintenance.customRecurrenceDays} days';
      default:
        return 'One-time task';
    }
  }

  Widget _buildNextDueDateSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: maintenance.isOverdue
            ? AppColors.highPriority.withOpacity(0.1)
            : (maintenance.isDueToday
                ? AppColors.mediumPriority.withOpacity(0.1)
                : AppColors.blueGradientStart.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: maintenance.isOverdue
              ? AppColors.highPriority.withOpacity(0.3)
              : (maintenance.isDueToday
                  ? AppColors.mediumPriority.withOpacity(0.3)
                  : AppColors.blueGradientStart.withOpacity(0.3)),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            maintenance.isOverdue
                ? Icons.error_outline
                : (maintenance.isDueToday
                    ? Icons.today
                    : Icons.calendar_today),
            size: 18,
            color: maintenance.isOverdue
                ? AppColors.highPriority
                : (maintenance.isDueToday
                    ? AppColors.mediumPriority
                    : AppColors.blueGradientStart),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maintenance.isOverdue
                      ? 'Maintenance Overdue!'
                      : (maintenance.isDueToday
                          ? 'Due Today'
                          : 'Next Due Date'),
                  style: TextStyle(
                    color: maintenance.isOverdue
                        ? AppColors.highPriority
                        : (maintenance.isDueToday
                            ? AppColors.mediumPriority
                            : AppColors.getSubtitleColor(context)),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('EEEE, MMM dd, yyyy').format(maintenance.nextDueDate),
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

  Widget _buildLastDoneSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.completed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.completed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 18,
            color: AppColors.completed,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Completed',
                  style: TextStyle(
                    color: AppColors.getSubtitleColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM dd, yyyy').format(maintenance.lastDoneDate!),
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

  Widget _buildAttachments(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments (${maintenance.attachmentPaths.length})',
          style: TextStyle(
            color: AppColors.getSubtitleColor(context),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: maintenance.attachmentPaths.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showAttachment(context, maintenance.attachmentPaths[index]),
                child: Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(maintenance.attachmentPaths[index]),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.withOpacity(0.2),
                          child: const Icon(Icons.broken_image, size: 30),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAttachment(BuildContext context, String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.file(
                  File(path),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
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
          if (onViewHistory != null && maintenance.paymentHistory.isNotEmpty) ...[
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
          if (onComplete != null) ...[
            _buildActionButton(
              label: 'Mark Done',
              icon: Icons.check_circle_outline,
              color: AppColors.completed,
              onTap: onComplete,
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