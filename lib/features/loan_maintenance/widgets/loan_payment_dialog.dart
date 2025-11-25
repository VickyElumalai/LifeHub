import 'package:flutter/material.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/providers/loan_maintenance_provider.dart';
import 'package:provider/provider.dart';

class LoanPaymentDialog extends StatefulWidget {
  final loan;

  const LoanPaymentDialog({required this.loan});

  @override
  State<LoanPaymentDialog> createState() => _LoanPaymentDialogState();
}

class _LoanPaymentDialogState extends State<LoanPaymentDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
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
          Text(
            'Mark as Paid',
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.loan.title,
            style: TextStyle(
              color: AppColors.getSubtitleColor(context),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Month ${widget.loan.completedMonths + 1}/${widget.loan.totalMonths}',
            style: TextStyle(
              color: AppColors.getSubtitleColor(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: TextStyle(color: AppColors.getTextColor(context)),
            decoration: InputDecoration(
              labelText: 'Amount Paid *',
              prefixText: '₹ ',
              labelStyle: TextStyle(color: AppColors.getSubtitleColor(context)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 2,
            style: TextStyle(color: AppColors.getTextColor(context)),
            decoration: InputDecoration(
              labelText: 'Notes (Optional)',
              labelStyle: TextStyle(color: AppColors.getSubtitleColor(context)),
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
            if (_amountController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter amount')),
              );
              return;
            }

            final provider = Provider.of<LoanMaintenanceProvider>(
              context,
              listen: false,
            );

            await provider.markLoanAsPaid(
              loanId: widget.loan.id,
              amount: double.parse(_amountController.text),
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
                    Text('Payment recorded!'),
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
          child: Text('Mark as Paid',style: TextStyle(color: Colors.white),),
        ),
      ],
    );
  }
}