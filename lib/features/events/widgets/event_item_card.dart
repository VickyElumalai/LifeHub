import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/data/models/event_model.dart';

class EventItemCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const EventItemCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onDelete,
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
            color: AppColors.blueGradientStart.withOpacity(0.3),
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
            // Header with image preview, time and recurrence
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Image preview (if exists)
                  if (event.attachmentPath != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(event.attachmentPath!),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey.withOpacity(0.2),
                            child: const Icon(Icons.broken_image, size: 20),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  // Time
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.blueGradientStart.withOpacity(0.2),
                          AppColors.blueGradientEnd.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.blueGradientStart,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('hh:mm a').format(event.dateTime),
                          style: const TextStyle(
                            color: AppColors.blueGradientStart,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Recurrence badge
                  _buildRecurrenceBadge(),
                  const Spacer(),
                ],
              ),
            ),
            
            // Divider
            Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: TextStyle(
                      color: AppColors.getTextColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (event.location != null && event.location!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.getSubtitleColor(context),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: TextStyle(
                              color: AppColors.getSubtitleColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (event.reminderMinutes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: event.reminderMinutes.map((minutes) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.purpleGradientStart.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.purpleGradientStart.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.notifications_active,
                                size: 12,
                                color: AppColors.purpleGradientStart,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getReminderText(int.parse(minutes)),
                                style: const TextStyle(
                                  color: AppColors.purpleGradientStart,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceBadge() {
    Color color;
    IconData icon;
    String label;
    
    switch (event.recurrence) {
    case Recurrence.daily:
      color = AppColors.greenGradientStart;
      icon = Icons.repeat;
      label = 'DAILY';
      break;
    case Recurrence.weekly:
      color = AppColors.yellowGradientStart;
      icon = Icons.calendar_today;
      label = 'WEEKLY';
      break;
    case Recurrence.once:
    default:
      color = AppColors.purpleGradientStart;
      icon = Icons.event;
      label = 'ONCE';
  }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _getReminderText(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else if (minutes < 1440) {
      final hours = minutes ~/ 60;
      return '${hours}h';
    } else {
      final days = minutes ~/ 1440;
      return '${days}d';
    }
  }
}