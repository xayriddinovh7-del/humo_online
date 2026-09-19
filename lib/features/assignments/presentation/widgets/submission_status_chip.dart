import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class SubmissionStatusChip extends StatelessWidget {
  const SubmissionStatusChip({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;

    switch (status) {
      case 'sent':
        color = AppColors.statusSent;
        label = 'Yuborilgan';
        icon = Icons.send_rounded;
        break;
      case 'checking':
        color = AppColors.statusChecking;
        label = 'Tekshirilmoqda';
        icon = Icons.pending_actions_rounded;
        break;
      case 'graded':
        color = AppColors.statusGraded;
        label = 'Baholangan';
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'returned':
        color = AppColors.statusReturned;
        label = 'Qaytarilgan';
        icon = Icons.refresh_rounded;
        break;
      case 'not_sent':
      default:
        color = AppColors.statusNotSent;
        label = 'Yuborilmagan';
        icon = Icons.circle_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
