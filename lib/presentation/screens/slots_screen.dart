import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager_app/data/models/slot.dart';
import 'package:manager_app/presentation/providers/slot_provider.dart';
import 'package:manager_app/core/constants/constants.dart';
import 'package:manager_app/presentation/widgets/empty_state.dart';
import 'package:manager_app/presentation/widgets/loading_shimmer.dart';
import 'package:manager_app/presentation/widgets/slot_card.dart';

class SlotsScreen extends ConsumerWidget {
  const SlotsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotState = ref.watch(slotProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Slots'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(slotProvider.notifier).fetchAll(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(slotProvider.notifier).fetchAll(),
        child: slotState.when(
          data: (slots) {
            if (slots.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.schedule,
                title: 'No time slots configured',
                subtitle: 'Tap + to add your first slot',
                action: ElevatedButton.icon(
                  onPressed: () => _showAddDialog(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Slot'),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: slots.length + 1,
              itemBuilder: (ctx, i) {
                if (i == 0) {
                  return _buildSummary(slots);
                }
                final slot = slots[i - 1];
                return SlotCard(
                  slot: slot,
                  onToggle: (_) {
                    ref.read(slotProvider.notifier).toggleOpen(slot.id);
                  },
                  onEdit: () => _showEditDialog(ctx, slot, ref),
                );
              },
            );
          },
          loading: () => const LoadingShimmer(itemCount: 4, height: 100),
          error: (e, _) => EmptyStateWidget(
            icon: Icons.error_outline,
            title: 'Failed to load slots',
            subtitle: '$e',
            action: ElevatedButton(
              onPressed: () => ref.read(slotProvider.notifier).fetchAll(),
              child: const Text('Retry'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(List<Slot> slots) {
    final openCount = slots.where((s) => s.isOpen).length;
    final totalCapacity = slots.fold<int>(0, (s, slot) => s + slot.maxOrders);
    final currentOrders = slots.fold<int>(
      0,
      (s, slot) => s + slot.currentOrders,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  '$openCount',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Open Slots',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$currentOrders',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Orders Today',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$totalCapacity',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Total Capacity',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final labelCtrl = TextEditingController();
    final startCtrl = TextEditingController();
    final endCtrl = TextEditingController();
    final maxOrdersCtrl = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Slot'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: labelCtrl,
                decoration: const InputDecoration(
                  labelText: 'Slot Name',
                  hintText: 'e.g. Lunch Slot',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Start Time',
                        hintText: '12:00 PM',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: endCtrl,
                      decoration: const InputDecoration(
                        labelText: 'End Time',
                        hintText: '01:00 PM',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: maxOrdersCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Max Orders'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (labelCtrl.text.isEmpty ||
                  startCtrl.text.isEmpty ||
                  endCtrl.text.isEmpty) {
                return;
              }
              final maxOrders = int.tryParse(maxOrdersCtrl.text) ?? 30;
              ref
                  .read(slotProvider.notifier)
                  .create(
                    Slot(
                      id: '',
                      label: labelCtrl.text,
                      startTime: startCtrl.text,
                      endTime: endCtrl.text,
                      isOpen: true,
                      maxOrders: maxOrders,
                      currentOrders: 0,
                    ),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Slot slot, WidgetRef ref) {
    final maxOrdersCtrl = TextEditingController(
      text: slot.maxOrders.toString(),
    );
    final labelCtrl = TextEditingController(text: slot.label);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Slot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelCtrl,
              decoration: const InputDecoration(labelText: 'Slot Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: maxOrdersCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Max Orders'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final maxOrders =
                  int.tryParse(maxOrdersCtrl.text) ?? slot.maxOrders;
              ref
                  .read(slotProvider.notifier)
                  .update(
                    slot.copyWith(label: labelCtrl.text, maxOrders: maxOrders),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
