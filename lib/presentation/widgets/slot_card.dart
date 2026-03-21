import 'package:flutter/material.dart';
import 'package:manager_app/data/models/slot.dart';
import 'package:manager_app/core/constants/constants.dart';

class SlotCard extends StatelessWidget {
  final Slot slot;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onEdit;

  const SlotCard({super.key, required this.slot, this.onToggle, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.grey.shade100;
    final subtitleColor = isDark ? Colors.white54 : Colors.grey.shade500;
    final iconColor = isDark ? Colors.white30 : Colors.grey.shade400;
    final trackBg = isDark ? const Color(0xFF3A3A3C) : Colors.grey.shade100;

    final fillColor = slot.fillPercentage > 0.8
        ? AppColors.error
        : slot.fillPercentage > 0.5
        ? AppColors.warning
        : AppColors.success;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: slot.isOpen
                      ? AppColors.success.withValues(alpha: isDark ? 0.2 : 0.1)
                      : (isDark
                            ? const Color(0xFF3A3A3C)
                            : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.schedule,
                  size: 20,
                  color: slot.isOpen ? AppColors.success : iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${slot.startTime} — ${slot.endTime}',
                      style: TextStyle(fontSize: 12, color: subtitleColor),
                    ),
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 18, color: iconColor),
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
              if (onToggle != null)
                Switch.adaptive(
                  value: slot.isOpen,
                  onChanged: onToggle,
                  activeThumbColor: AppColors.success,
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Capacity bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: slot.fillPercentage,
                    backgroundColor: trackBg,
                    valueColor: AlwaysStoppedAnimation(fillColor),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${slot.currentOrders}/${slot.maxOrders}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: fillColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
