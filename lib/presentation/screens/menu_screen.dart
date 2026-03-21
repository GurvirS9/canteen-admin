import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager_app/data/models/menu_item.dart';
import 'package:manager_app/presentation/providers/menu_provider.dart';
import 'package:manager_app/core/constants/constants.dart';
import 'package:manager_app/presentation/widgets/empty_state.dart';
import 'package:manager_app/presentation/widgets/loading_shimmer.dart';
import 'package:manager_app/presentation/widgets/menu_item_card.dart';
import 'package:manager_app/presentation/screens/add_edit_menu_item_screen.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(menuProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(menuProvider.notifier).fetchAll(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEdit(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search menu items...',
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

          // Category filter chips
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CategoryChip(
                  label: 'All',
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                ...AppConstants.menuCategories.map(
                  (cat) => _CategoryChip(
                    label: cat,
                    isSelected: _selectedCategory == cat,
                    onTap: () => setState(() => _selectedCategory = cat),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Items list
          Expanded(
            child: menuState.when(
              data: (items) {
                var filtered = items;
                if (_selectedCategory != null) {
                  filtered = filtered
                      .where((i) => i.category == _selectedCategory)
                      .toList();
                }
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  filtered = filtered
                      .where(
                        (i) =>
                            i.name.toLowerCase().contains(q) ||
                            i.description.toLowerCase().contains(q),
                      )
                      .toList();
                }

                if (filtered.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.restaurant_menu,
                    title: 'No menu items found',
                    subtitle: _searchQuery.isNotEmpty
                        ? 'Try a different search query'
                        : 'Tap + to add your first item',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(menuProvider.notifier).fetchAll(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => MenuItemCard(
                      item: filtered[i],
                      onTap: () => _navigateToAddEdit(ctx, item: filtered[i]),
                      onAvailabilityChanged: (_) {
                        ref
                            .read(menuProvider.notifier)
                            .toggleAvailability(filtered[i].id);
                      },
                      onDelete: () => _confirmDelete(ctx, filtered[i]),
                    ),
                  ),
                );
              },
              loading: () => const LoadingShimmer(),
              error: (e, _) => EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Failed to load menu',
                subtitle: '$e',
                action: ElevatedButton(
                  onPressed: () => ref.read(menuProvider.notifier).fetchAll(),
                  child: const Text('Retry'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAddEdit(BuildContext context, {MenuItem? item}) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (_) => AddEditMenuItemScreen(item: item)),
    );
  }

  void _confirmDelete(BuildContext context, MenuItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(menuProvider.notifier).delete(item.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            color: isSelected ? AppColors.primary : unselectedBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : unselectedText,
            ),
          ),
        ),
      ),
    );
  }
}
