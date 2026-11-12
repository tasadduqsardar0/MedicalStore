import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/stock_rules.dart';

class AlertChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const AlertChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory AlertChip.fromStatus(StockStatus status) {
    switch (status) {
      case StockStatus.inStock:
        return const AlertChip(
          label: 'In stock',
          backgroundColor: AppColors.successLight,
          textColor: AppColors.success,
          icon: Icons.check_circle_outline,
        );
      case StockStatus.lowStock:
        return const AlertChip(
          label: 'Low stock',
          backgroundColor: AppColors.warningLight,
          textColor: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        );
      case StockStatus.outOfStock:
        return const AlertChip(
          label: 'Out of stock',
          backgroundColor: AppColors.dangerLight,
          textColor: AppColors.danger,
          icon: Icons.cancel_outlined,
        );
      case StockStatus.expiredStock:
        return const AlertChip(
          label: 'Expired stock',
          backgroundColor: AppColors.dangerLight,
          textColor: AppColors.danger,
          icon: Icons.error_outline,
        );
      case StockStatus.nearExpiry:
        return const AlertChip(
          label: 'Near expiry',
          backgroundColor: AppColors.warningLight,
          textColor: AppColors.warning,
          icon: Icons.schedule,
        );
    }
  }

  factory AlertChip.controlled() {
    return const AlertChip(
      label: 'Controlled',
      backgroundColor: AppColors.controlledLight,
      textColor: AppColors.controlled,
      icon: Icons.lock_outline,
    );
  }

  factory AlertChip.role(String roleLabel, {bool isOwner = true}) {
    return AlertChip(
      label: roleLabel,
      backgroundColor: isOwner ? AppColors.primaryLight : AppColors.surfaceVariant,
      textColor: isOwner ? AppColors.primaryDark : AppColors.textSecondary,
      icon: isOwner ? Icons.admin_panel_settings_outlined : Icons.badge_outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

