import 'package:flutter/material.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/providers/loan_maintenance_provider.dart';
import 'package:provider/provider.dart';

class MaintenancePaymentDialog extends StatefulWidget {
  final maintenance;

  const MaintenancePaymentDialog({required this.maintenance});

  @override
  State<MaintenancePaymentDialog> createState() => _MaintenancePaymentDialogState();
}

class _MaintenancePaymentDialogState extends State<MaintenancePaymentDialog> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkCard : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.completed,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mark as Done',
                  style: TextStyle(
                    color: AppColors.getTextColor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.maintenance.title,
            style: TextStyle(
              color: AppColors.getSubtitleColor(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.blueGradientStart.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.blueGradientStart,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This will be added to maintenance history',
                    style: TextStyle(
                      color: AppColors.getTextColor(context),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 3,
            autofocus: true,
            style: TextStyle(color: AppColors.getTextColor(context)),
            decoration: InputDecoration(
              labelText: 'Notes (Optional)',
              hintText: 'e.g., Changed oil, replaced filters',
              labelStyle: TextStyle(color: AppColors.getSubtitleColor(context)),
              hintStyle: TextStyle(
                color: AppColors.getSubtitleColor(context).withOpacity(0.5),
                fontSize: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
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
            final provider = Provider.of<LoanMaintenanceProvider>(
              context,
              listen: false,
            );

            await provider.markMaintenanceAsCompleted(
              maintenanceId: widget.maintenance.id,
              notes: _notesController.text.isEmpty
                  ? null
                  : _notesController.text,
            );

            if (!mounted) return;
            Navigator.pop(context);
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Maintenance completed!'),
                  ],
                ),
                backgroundColor: AppColors.completed,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.completed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Mark as Done',style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
}