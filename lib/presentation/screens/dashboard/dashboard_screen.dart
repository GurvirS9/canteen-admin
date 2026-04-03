import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:manager_app/data/models/order.dart';
import 'package:manager_app/presentation/providers/dashboard_provider.dart';
import 'package:manager_app/presentation/providers/order_provider.dart';
import 'package:manager_app/core/theme/app_colors.dart';
import 'package:manager_app/presentation/widgets/loading_shimmer.dart';
import 'package:manager_app/presentation/widgets/order_card.dart';
import 'package:manager_app/presentation/widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashState = ref.watch(dashboardProvider);
    final ordersState = ref.watch(orderProvider);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.notifications_outlined, size: 20),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await ref.read(dashboardProvider.notifier).fetchSummary();
          await ref.read(orderProvider.notifier).fetchAll();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),

              // Stats grid
              dashState.when(
                data: (summary) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.25,
                    children: [
                      StatCard(
                        label: 'Total Orders',
                        value: '${summary.totalOrders}',
                        icon: Icons.receipt_long,
                        color: AppColors.primary,
                      ),
                      StatCard(
                        label: 'Revenue',
                        value: currencyFormat.format(summary.revenue),
                        icon: Icons.account_balance_wallet,
                        color: AppColors.success,
                      ),
                      StatCard(
                        label: 'Active Orders',
                        value: '${summary.activeOrders}',
                        icon: Icons.local_fire_department,
                        color: AppColors.warning,
                        subtitle: '${summary.pendingOrders} pending',
                      ),
                      StatCard(
                        label: 'Completed',
                        value: '${summary.completedOrders}',
                        icon: Icons.check_circle_outline,
                        color: AppColors.accent,
                        subtitle: '${summary.cancelledOrders} cancelled',
                      ),
                    ],
                  ),
                ),
                loading: () => const ShimmerGrid(),
                error: (e, _) =>
                    Center(child: Text('Error loading dashboard: $e')),
              ),

              const SizedBox(height: 20),

              // Quick Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _QuickAction(
                      icon: Icons.add_circle_outline,
                      label: 'Add Item',
                      color: AppColors.primary,
                      onTap: () => context.go('/menu'),
                    ),
                    _QuickAction(
                      icon: Icons.list_alt,
                      label: 'All Orders',
                      color: AppColors.info,
                      badge: dashState.valueOrNull?.pendingOrders.toString(),
                      onTap: () => context.go('/orders'),
                    ),
                    _QuickAction(
                      icon: Icons.schedule,
                      label: 'Slots',
                      color: AppColors.accent,
                      onTap: () => context.go('/slots'),
                    ),
                    _QuickAction(
                      icon: Icons.analytics_outlined,
                      label: 'Analytics',
                      color: AppColors.info,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Analytics coming soon!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Recent Orders
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Recent Orders',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'View All',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

              ordersState.when(
                data: (orders) {
                  final recent = orders.take(5).toList();
                  if (recent.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(child: Text('No recent orders')),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recent.length,
                    itemBuilder: (ctx, i) => OrderCard(
                      order: recent[i],
                      onTap: () => _showOrderDetail(ctx, recent[i], ref),
                    ),
                  );
                },
                loading: () => const LoadingShimmer(itemCount: 3),
                error: (e, _) =>
                    Center(child: Text('Error loading orders: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  void _showOrderDetail(BuildContext context, Order order, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OrderDetailSheet(order: order, ref: ref),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 24),
                if (badge != null && badge != '0')
                  Positioned(
                    top: -6,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  final Order order;
  final WidgetRef ref;

  const _OrderDetailSheet({required this.order, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.cardDark : Colors.white;
    final handleColor = isDark ? Colors.white24 : Colors.grey.shade300;
    final subtitleColor = isDark ? Colors.white54 : Colors.grey.shade700;
    final iconColor = isDark ? Colors.white30 : Colors.grey.shade400;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: handleColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Order #${order.id}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.statusColor(
                      order.status,
                    ).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.status.label,
                    style: TextStyle(
                      color: AppColors.statusColor(order.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  order.customerName,
                  style: TextStyle(color: subtitleColor),
                ),
                if (order.customerPhone != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.phone_outlined, size: 16, color: iconColor),
                  const SizedBox(width: 6),
                  Text(
                    order.customerPhone!,
                    style: TextStyle(color: subtitleColor),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 24),
          // Items
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: order.items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final item = order.items[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        'x${item.quantity}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '₹${item.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          if (order.notes != null && order.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.note, size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.notes!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Action buttons
          if (order.status != OrderStatus.collected)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(children: _buildActionButtons(context)),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final nextStatus = order.status.nextStatus;
    if (nextStatus == null) return [];

    void updateAndClose(OrderStatus newStatus) {
      ref.read(orderProvider.notifier).updateStatus(order.id, newStatus);
      Navigator.pop(context);
    }

    String label;
    IconData icon;
    Color? bgColor;

    switch (nextStatus) {
      case OrderStatus.preparing:
        label = 'Start Preparing';
        icon = Icons.restaurant;
        bgColor = AppColors.preparing;
        break;
      case OrderStatus.ready:
        label = 'Mark Ready';
        icon = Icons.check;
        bgColor = AppColors.ready;
        break;
      case OrderStatus.collected:
        label = 'Mark Collected';
        icon = Icons.done_all;
        bgColor = AppColors.success;
        break;
      default:
        return [];
    }

    return [
      Expanded(
        child: ElevatedButton.icon(
          onPressed: () => updateAndClose(nextStatus),
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: bgColor,
          ),
        ),
      ),
    ];
  }
}
