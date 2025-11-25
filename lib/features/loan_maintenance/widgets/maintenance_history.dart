import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/data/models/loan_maintenance_model.dart';

class MaintenanceHistoryDialog extends StatelessWidget {
  final maintenance;

  const MaintenanceHistoryDialog({
    super.key,
    required this.maintenance,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
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
                    AppColors.pinkGradientEnd,
                    AppColors.pinkGradientStart,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Maintenance History',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
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
                  const SizedBox(height: 12),
                  Text(
                    maintenance.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Summary Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blueGradientStart.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryStat(
                    context,
                    'Completed',
                    '${maintenance.paymentHistory.length}',
                    AppColors.completed,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.1),
                  ),
                  _buildSummaryStat(
                    context,
                    'Recurrence',
                    _getRecurrenceLabel(maintenance.recurrence),
                    AppColors.purpleGradientStart,
                  ),
                ],
              ),
            ),

            // History List
            if (maintenance.paymentHistory.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: AppColors.getSubtitleColor(context)
                            .withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No maintenance history yet',
                        style: TextStyle(
                          color: AppColors.getSubtitleColor(context),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: maintenance.paymentHistory.length,
                  itemBuilder: (context, index) {
                    // Show in reverse order (newest first)
                    final record = maintenance.paymentHistory[
                        maintenance.paymentHistory.length - 1 - index];
                    return _buildMaintenanceItem(context, record, isDark, index);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStat(
      BuildContext context, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.getSubtitleColor(context),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _getRecurrenceLabel(String? recurrence) {
    switch (recurrence) {
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Quarterly';
      case 'halfyearly':
        return '6 Months';
      case 'yearly':
        return 'Yearly';
      case 'custom':
        return 'Custom';
      case 'none':
      default:
        return 'One-time';
    }
  }

  Widget _buildMaintenanceItem(
      BuildContext context, PaymentRecord record, bool isDark, int index) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.completed.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.completed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completed #${maintenance.paymentHistory.length - index}',
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('MMM dd, yyyy').format(record.paidDate),
                      style: TextStyle(
                        color: AppColors.getSubtitleColor(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle,
                color: AppColors.completed,
                size: 20,
              ),
            ],
          ),
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.purpleGradientStart.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 14,
                    color: AppColors.getSubtitleColor(context),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      record.notes!,
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}