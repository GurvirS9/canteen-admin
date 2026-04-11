import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manager_app/core/theme/app_colors.dart';
import 'package:manager_app/presentation/providers/auth_provider.dart';
import 'package:manager_app/presentation/providers/shop_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:manager_app/data/models/shop.dart';

class ShopSettingsScreen extends ConsumerStatefulWidget {
  const ShopSettingsScreen({super.key});

  @override
  ConsumerState<ShopSettingsScreen> createState() => _ShopSettingsScreenState();
}

class _ShopSettingsScreenState extends ConsumerState<ShopSettingsScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _seatingCtrl = TextEditingController();
  final _openCtrl = TextEditingController();
  final _closeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user != null) {
        ref.read(shopProvider.notifier).loadMyShop(user.id);
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _seatingCtrl.dispose();
    _openCtrl.dispose();
    _closeCtrl.dispose();
    super.dispose();
  }

  void _populateControllers(Shop shop) {
    _nameCtrl.text = shop.name;
    _addressCtrl.text = shop.address;
    _seatingCtrl.text = shop.seatingCapacity.toString();
    _openCtrl.text = shop.openingTime;
    _closeCtrl.text = shop.closingTime;
  }

  @override
  Widget build(BuildContext context) {
    final shopState = ref.watch(shopProvider);
    final shop = shopState.myShop;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shop'),
        actions: [
          if (shop != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit_rounded),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (_isEditing) _populateControllers(shop);
                });
              },
            ),
        ],
      ),
      body: shopState.shops.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Could not load shop data', style: theme.textTheme.titleMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final user = ref.read(authStateProvider).valueOrNull;
                  if (user != null) {
                    ref.read(shopProvider.notifier).loadMyShop(user.id);
                  }
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (_) {
          if (shop == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No shop assigned to your account',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact admin to get a shop assigned.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => context.push('/onboarding'),
                    icon: const Icon(Icons.rocket_launch_rounded, size: 18),
                    label: const Text("Haven't onboarded yet?"),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            );
          }

          return _isEditing ? _buildEditForm(shop) : _buildShopDetail(shop);
        },
      ),
    );
  }

  Widget _buildShopDetail(Shop shop) {

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () {
        final user = ref.read(authStateProvider).valueOrNull;
        if (user != null) {
          return ref.read(shopProvider.notifier).loadMyShop(user.id);
        }
        return Future.value();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Shop header card
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.store_rounded,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            shop.address,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Is open toggle
                _ShopToggleRow(shop: shop),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              _StatPill(
                label: 'Seats',
                value: '${shop.seatingCapacity}',
                icon: Icons.people_rounded,
              ),
              const SizedBox(width: 12),
              _StatPill(
                label: 'Tables',
                value: '${shop.tableCount}',
                icon: Icons.table_restaurant_rounded,
              ),
              const SizedBox(width: 12),
              _StatPill(
                label: 'Rating',
                value: shop.rating.toStringAsFixed(1),
                icon: Icons.star_rounded,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Hours section
          _InfoCard(
            icon: Icons.schedule_rounded,
            title: 'Operating Hours',
            children: [
              _InfoRow('Opening', shop.openingTime),
              _InfoRow('Closing', shop.closingTime),
            ],
          ),
          const SizedBox(height: 12),

          // Queue section
          _InfoCard(
            icon: Icons.people_outline,
            title: 'Live Queue',
            children: [
              _InfoRow('Current Queue', '${shop.currentQueue}'),
            ],
          ),
          const SizedBox(height: 16),

          // Edit button
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _isEditing = true;
                _populateControllers(shop);
              });
            },
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text('Edit Shop Details'),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildEditForm(Shop shop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Shop Name'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(hintText: 'e.g. Main Canteen'),
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            const Text('Address'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _addressCtrl,
              decoration: const InputDecoration(hintText: 'e.g. Block A, Ground Floor'),
            ),
            const SizedBox(height: 16),
            const Text('Seating Capacity'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _seatingCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: '50'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Opening Time'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _openCtrl,
                        readOnly: true,
                        onTap: () async {
                          final picked =
                              await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (picked != null && mounted) {
                            _openCtrl.text = picked.format(context);
                          }
                        },
                        decoration: const InputDecoration(hintText: 'e.g. 08:00'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Closing Time'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _closeCtrl,
                        readOnly: true,
                        onTap: () async {
                          final picked =
                              await showTimePicker(context: context, initialTime: TimeOfDay.now());
                          if (picked != null && mounted) {
                            _closeCtrl.text = picked.format(context);
                          }
                        },
                        decoration: const InputDecoration(hintText: 'e.g. 22:00'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _save(shop),
                child: const Text('Save Changes'),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Future<void> _save(Shop shop) async {
    if (!_formKey.currentState!.validate()) return;
    final fields = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      'seatingCapacity': int.tryParse(_seatingCtrl.text) ?? shop.seatingCapacity,
      'openingTime': _openCtrl.text,
      'closingTime': _closeCtrl.text,
    };
    try {
      await ref.read(shopProvider.notifier).updateShopDetails(shop.id, fields);
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shop updated!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _ShopToggleRow extends ConsumerWidget {
  final Shop shop;
  const _ShopToggleRow({required this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        const Icon(Icons.circle, color: Colors.white70, size: 10),
        const SizedBox(width: 8),
        Text(
          shop.isOpen ? 'Shop is currently OPEN' : 'Shop is currently CLOSED',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const Spacer(),
        Switch.adaptive(
          value: shop.isOpen,
          thumbColor: WidgetStatePropertyAll(shop.isOpen ? Colors.white : null),
          onChanged: (v) {
            ref.read(shopProvider.notifier).toggleShopOpen(shop.id, v);
          },
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatPill({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800)),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: theme.hintColor)),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.icon, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13, color: Theme.of(context).hintColor)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
