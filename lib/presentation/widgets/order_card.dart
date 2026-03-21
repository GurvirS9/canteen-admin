import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manager_app/data/models/order.dart';
import 'package:manager_app/presentation/widgets/status_badge.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.grey.shade100;
    final subtitleColor = isDark ? Colors.white54 : Colors.grey.shade500;
    final nameColor = isDark ? Colors.white70 : Colors.grey.shade700;
    final iconColor = isDark ? Colors.white30 : Colors.grey.shade400;
    final timeFormat = DateFormat('hh:mm a');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
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
                Text(
                  '#${order.id}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                StatusBadge(status: order.status, compact: true),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 15, color: iconColor),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.customerName,
                    style: TextStyle(
                      fontSize: 13,
                      color: nameColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.access_time, size: 13, color: iconColor),
                const SizedBox(width: 4),
                Text(
                  timeFormat.format(order.createdAt),
                  style: TextStyle(fontSize: 12, color: subtitleColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.items
                        .map((i) => '${i.name} x${i.quantity}')
                        .join(', '),
                    style: TextStyle(fontSize: 12, color: subtitleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Text(
                  '₹',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                Text(
                  order.totalAmount.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
