import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager_app/data/models/order.dart';
import 'package:manager_app/presentation/providers/order_provider.dart';
import 'package:manager_app/core/theme/app_colors.dart';
import 'package:manager_app/presentation/widgets/empty_state.dart';
import 'package:manager_app/presentation/widgets/loading_shimmer.dart';
import 'package:manager_app/presentation/widgets/order_card.dart';
import 'package:manager_app/presentation/widgets/status_badge.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  OrderStatus? _selectedFilter;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(orderProvider.notifier).fetchAll(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by order ID or customer...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),

          // Status filter chips
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == null,
                  onTap: () => setState(() => _selectedFilter = null),
                ),
                ...OrderStatus.values.map(
                  (status) => _FilterChip(
                    label: status.label,
                    isSelected: _selectedFilter == status,
                    color: AppColors.statusColor(status),
                    onTap: () => setState(() => _selectedFilter = status),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Order list
          Expanded(
            child: ordersState.when(
              data: (orders) {
                var filtered = orders;
                if (_selectedFilter != null) {
                  filtered = filtered
                      .where((o) => o.status == _selectedFilter)
                      .toList();
                }
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  filtered = filtered
                      .where(
                        (o) =>
                            o.id.toLowerCase().contains(q) ||
                            o.customerName.toLowerCase().contains(q),
                      )
                      .toList();
                }

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.receipt_long,
                    title: 'No orders found',
                    subtitle: _selectedFilter != null
                        ? 'No ${_selectedFilter!.label.toLowerCase()} orders'
                        : 'Orders will appear here',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(orderProvider.notifier).fetchAll(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => OrderCard(
                      order: filtered[i],
                      onTap: () => _showOrderDetail(ctx, filtered[i]),
                    ),
                  ),
                );
              },
              loading: () => const LoadingShimmer(),
              error: (e, _) => EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Failed to load orders',
                subtitle: '$e',
                action: ElevatedButton(
                  onPressed: () => ref.read(orderProvider.notifier).fetchAll(),
                  child: const Text('Retry'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetail(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OrderDetailBottomSheet(order: order, ref: ref),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipColor = color ?? AppColors.primary;
    final unselectedBg = isDark
        ? const Color(0xFF3A3A3C)
        : Colors.grey.shade100;
    final unselectedText = isDark ? Colors.white60 : Colors.grey.shade600;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? chipColor.withValues(alpha: isDark ? 0.25 : 0.15)
                : unselectedBg,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? Border.all(color: chipColor.withValues(alpha: 0.4))
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? chipColor : unselectedText,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderDetailBottomSheet extends StatelessWidget {
  final Order order;
  final WidgetRef ref;

  const _OrderDetailBottomSheet({required this.order, required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? AppColors.cardDark : Colors.white;
    final handleColor = isDark ? Colors.white24 : Colors.grey.shade300;
    final subtitleColor = isDark ? Colors.white54 : Colors.grey.shade600;
    final qtyBg = AppColors.primaryLight.withValues(alpha: isDark ? 0.2 : 0.1);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
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

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.shortId}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.customerName,
                          style: TextStyle(fontSize: 14, color: subtitleColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  StatusBadge(status: order.status),
                ],
              ),
            ),

            const Divider(height: 24),

            // Item list
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: qtyBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'x${item.quantity}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.primaryLight
                                : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                      '₹${item.total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 24),

            // Total
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.primaryLight
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.note,
                        size: 16,
                        color: AppColors.warning,
                      ),
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
            ],

            const SizedBox(height: 20),

            // Action buttons
            if (order.status != OrderStatus.collected)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(children: _buildActions(context)),
              ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final nextStatus = order.status.nextStatus;
    if (nextStatus == null) return [];

    void updateAndClose(OrderStatus newStatus) {
      Navigator.pop(context);
      ref.read(orderProvider.notifier).updateStatus(order.id, newStatus).catchError((e) {
        // Show error if optimistic update failed to confirm
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update status: ${e.toString()}'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      });
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
        icon = Icons.check_circle;
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
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    ];
  }
}
