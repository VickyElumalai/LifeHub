import 'dart:io';
import 'package:flutter/material.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/data/models/loan_maintenance_model.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';

class MaintenanceItemCard extends StatelessWidget {
  final LoanMaintenanceModel maintenance;
  final VoidCallback? onComplete;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MaintenanceItemCard({
    super.key,
    required this.maintenance,
    this.onComplete,
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
                    _buildCategoryIcon(maintenance.category),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  maintenance.title,
                                  style: TextStyle(
                                    color: AppColors.getTextColor(context),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (maintenance.maintenanceType != null)
                                _buildTypeBadge(maintenance.maintenanceType!),
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
                _buildDateSection(context, isDark),
                if (maintenance.recurrence != null &&
                    maintenance.recurrence != 'none') ...[
                  const SizedBox(height: 12),
                  _buildRecurrenceInfo(context),
                ],
                if (maintenance.attachmentPaths.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildAttachments(context),
                ],
                if (maintenance.notes != null &&
                    maintenance.notes!.isNotEmpty) ...[
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
              ],
            ),
          ),
          _buildActions(context, isDark),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    String emoji;
    List<Color> colors;

    switch (category) {
      case 'vehicle':
        emoji = '🚗';
        colors = [AppColors.blueGradientStart, AppColors.blueGradientEnd];
        break;
      case 'home':
        emoji = '🏠';
        colors = [AppColors.purpleGradientStart, AppColors.purpleGradientEnd];
        break;
      case 'appliance':
        emoji = '🔌';
        colors = [AppColors.greenGradientStart, AppColors.greenGradientEnd];
        break;
      default:
        emoji = '🔧';
        colors = [AppColors.yellowGradientStart, AppColors.yellowGradientEnd];
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    IconData icon;
    switch (type.toLowerCase()) {
      case 'insurance renewal':
      case 'insurance':
        icon = Icons.shield;
        break;
      case 'oil change':
      case 'service':
        icon = Icons.build;
        break;
      case 'ac service':
        icon = Icons.ac_unit;
        break;
      default:
        icon = Icons.settings;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.blueGradientStart.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.blueGradientStart,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            type.toUpperCase(),
            style: const TextStyle(
              color: AppColors.blueGradientStart,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: maintenance.isOverdue
            ? AppColors.highPriority.withOpacity(0.1)
            : (maintenance.isDueToday
                ? AppColors.mediumPriority.withOpacity(0.1)
                : AppColors.blueGradientStart.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: maintenance.isOverdue
              ? AppColors.highPriority.withOpacity(0.3)
              : (maintenance.isDueToday
                  ? AppColors.mediumPriority.withOpacity(0.3)
                  : AppColors.blueGradientStart.withOpacity(0.1)),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                maintenance.isOverdue
                    ? Icons.warning_amber
                    : (maintenance.isDueToday
                        ? Icons.today
                        : Icons.calendar_today),
                size: 18,
                color: maintenance.isOverdue
                    ? AppColors.highPriority
                    : (maintenance.isDueToday
                        ? AppColors.mediumPriority
                        : AppColors.getSubtitleColor(context)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      maintenance.isOverdue
                          ? 'Overdue!'
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
                      DateFormat('EEEE, MMM dd, yyyy')
                          .format(maintenance.nextDueDate),
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (maintenance.lastDoneDate != null) ...[
            const SizedBox(height: 8),
            Divider(
              height: 1,
              color: AppColors.getSubtitleColor(context).withOpacity(0.2),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.history,
                  size: 16,
                  color: AppColors.getSubtitleColor(context),
                ),
                const SizedBox(width: 8),
                Text(
                  'Last Done: ',
                  style: TextStyle(
                    color: AppColors.getSubtitleColor(context),
                    fontSize: 12,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(maintenance.lastDoneDate!),
                  style: TextStyle(
                    color: AppColors.getTextColor(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecurrenceInfo(BuildContext context) {
    String recurrenceText;
    IconData icon = Icons.repeat;

    switch (maintenance.recurrence) {
      case 'monthly':
        recurrenceText = 'Repeats Monthly';
        break;
      case 'quarterly':
        recurrenceText = 'Repeats Every 3 Months';
        break;
      case 'halfyearly':
        recurrenceText = 'Repeats Every 6 Months';
        break;
      case 'yearly':
        recurrenceText = 'Repeats Yearly';
        break;
      case 'custom':
        recurrenceText =
            'Repeats Every ${maintenance.customRecurrenceDays} Days';
        break;
      default:
        recurrenceText = 'No Recurrence';
        icon = Icons.event_repeat;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.greenGradientStart.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.greenGradientStart.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.greenGradientStart,
          ),
          const SizedBox(width: 8),
          Text(
            recurrenceText,
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.attach_file,
              size: 14,
              color: AppColors.getSubtitleColor(context),
            ),
            const SizedBox(width: 6),
            Text(
              '${maintenance.attachmentPaths.length} Attachment${maintenance.attachmentPaths.length > 1 ? 's' : ''}',
              style: TextStyle(
                color: AppColors.getSubtitleColor(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: maintenance.attachmentPaths.take(3).map((path) {
            final fileName = path.split('/').last;
            final isImage = fileName.toLowerCase().endsWith('.jpg') ||
                fileName.toLowerCase().endsWith('.jpeg') ||
                fileName.toLowerCase().endsWith('.png');

            return GestureDetector(
              onTap: () => _openFile(path),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 100),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.pinkGradientStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.pinkGradientStart.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isImage ? Icons.image : Icons.description,
                      size: 14,
                      color: AppColors.pinkGradientStart,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        fileName,
                        style: TextStyle(
                          color: AppColors.getTextColor(context),
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (maintenance.attachmentPaths.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '+${maintenance.attachmentPaths.length - 3} more',
              style: TextStyle(
                color: AppColors.getSubtitleColor(context),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
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
          if (onEdit != null) ...[
            _buildActionButton(
              label: 'Edit',
              icon: Icons.edit,
              color: AppColors.purpleGradientStart,
              onTap: onEdit,
            ),
            const SizedBox(width: 20),
          ],
          if (onComplete != null) ...[
            _buildActionButton(
              label: 'Complete',
              icon: Icons.check_circle,
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

  Future<void> _openFile(String path) async {
    try {
      final result = await OpenFile.open(path);
      print('Open file result: ${result.message}');
    } catch (e) {
      print('Error opening file: $e');
    }
  }
}