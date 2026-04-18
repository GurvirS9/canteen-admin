import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:manager_app/data/models/menu_item.dart';
import 'package:manager_app/presentation/providers/menu_provider.dart';
import 'package:manager_app/presentation/providers/shop_provider.dart';
import 'package:manager_app/core/constants/app_constants.dart';
import 'package:manager_app/core/theme/app_colors.dart';

class AddEditMenuItemScreen extends ConsumerStatefulWidget {
  final MenuItem? item;

  const AddEditMenuItemScreen({super.key, this.item});

  @override
  ConsumerState<AddEditMenuItemScreen> createState() =>
      _AddEditMenuItemScreenState();
}

class _AddEditMenuItemScreenState extends ConsumerState<AddEditMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _prepTimeCtrl;
  String _category = AppConstants.menuCategories.first;
  bool _isAvailable = true;
  bool _isVeg = true;
  bool _saving = false;

  // Tracks the locally picked file path (null = no new file picked).
  String? _localImagePath;

  // Tracks whether the user explicitly asked to remove the existing image.
  bool _removeExistingImage = false;

  bool get _isEditing => widget.item != null;

  /// The URL of the currently saved image (from the backend), if any.
  String? get _existingImageUrl => widget.item?.imageUrl;

  /// True if there is an image to display in preview (either a new local pick
  /// or an existing network image that hasn't been removed).
  bool get _hasImage =>
      _localImagePath != null ||
      (!_removeExistingImage && _existingImageUrl != null && _existingImageUrl!.isNotEmpty);

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _nameCtrl = TextEditingController(text: i?.name ?? '');
    _descCtrl = TextEditingController(text: i?.description ?? '');
    _priceCtrl = TextEditingController(
      text: i != null ? i.price.toStringAsFixed(0) : '',
    );
    _prepTimeCtrl = TextEditingController(
      text: i != null ? i.prepTime.toString() : '',
    );
    if (i != null) {
      _category = AppConstants.menuCategories.contains(i.category)
          ? i.category
          : AppConstants.menuCategories.first;
      _isAvailable = i.isAvailable;
      _isVeg = i.isVeg;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _prepTimeCtrl.dispose();
    super.dispose();
  }

  // ── Image helpers ─────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (file == null) return;

    // Launch cropper with locked 16:10 aspect ratio → 400×250 thumbnail
    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      maxWidth: 400,
      maxHeight: 250,
      aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 10),
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Thumbnail',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.primary,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Crop Thumbnail',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );

    if (cropped != null) {
      setState(() {
        _localImagePath = cropped.path;
        _removeExistingImage = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _localImagePath = null;
      _removeExistingImage = true;
    });
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      // If 'remove existing image' was requested and no new image picked,
      // we send an empty image field so the backend clears it.
      // The service will call DELETE /menu/:id/image after update if needed.
      final shopId = ref.read(shopProvider).myShop?.id;
      final item = MenuItem(
        id: widget.item?.id ?? '',
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim()),
        prepTime: int.tryParse(_prepTimeCtrl.text.trim()) ?? 10,
        category: _category,
        shopId: widget.item?.shopId ?? shopId,
        isAvailable: _isAvailable,
        isVeg: _isVeg,
        imageUrl: _removeExistingImage && _localImagePath == null
            ? null
            : widget.item?.imageUrl,
        createdAt: widget.item?.createdAt ?? DateTime.now(),
      );

      if (_isEditing) {
        // If user removed the image and didn't pick a new one, delete it first.
        if (_removeExistingImage && _localImagePath == null &&
            _existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
          await ref.read(menuProvider.notifier).deleteImage(item.id);
        }
        await ref.read(menuProvider.notifier).update(
              item,
              localImagePath: _localImagePath,
            );
      } else {
        await ref.read(menuProvider.notifier).create(
              item,
              localImagePath: _localImagePath,
            );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Item' : 'Add New Item')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Image picker ──────────────────────────────────────────────
              _buildImagePicker(isDark),
              const SizedBox(height: 20),

              // Name
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  prefixIcon: Icon(Icons.fastfood_outlined),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                // Description is optional — no validator needed
              ),
              const SizedBox(height: 16),

              // Price + Prep time (side by side)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price (₹)',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _prepTimeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Prep Time (min)',
                        prefixIcon: Icon(Icons.timer_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (int.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: AppConstants.menuCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
              const SizedBox(height: 16),

              // Veg / Non-veg + Availability toggles
              _buildToggle(
                isDark: isDark,
                title: 'Vegetarian',
                subtitle: _isVeg ? 'Veg item' : 'Non-veg item',
                value: _isVeg,
                activeColor: Colors.green,
                onChanged: (v) => setState(() => _isVeg = v),
              ),
              const SizedBox(height: 12),
              _buildToggle(
                isDark: isDark,
                title: 'Available',
                subtitle: _isAvailable
                    ? 'Visible to customers'
                    : 'Hidden from customers',
                value: _isAvailable,
                activeColor: AppColors.success,
                onChanged: (v) => setState(() => _isAvailable = v),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _saving ? null : _onSave,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(_isEditing ? 'Update Item' : 'Add Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sub-widgets ───────────────────────────────────────────────────────────

  Widget _buildImagePicker(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Preview area
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 180,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2C2C2E)
                  : AppColors.primaryLight.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _hasImage
                ? _buildImagePreview()
                : _buildAddImagePlaceholder(isDark),
          ),
        ),

        // Action row beneath the picker
        if (_hasImage)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Change'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _removeImage,
                  icon: Icon(Icons.delete_outline,
                      size: 16, color: AppColors.error),
                  label: Text('Remove',
                      style: TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildImagePreview() {
    // Prefer the locally picked file — it's a File, not a network image.
    if (_localImagePath != null) {
      return Image.file(
        File(_localImagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    // Fall back to the existing network image (already resolved to https://).
    return CachedNetworkImage(
      imageUrl: _existingImageUrl!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => const Center(
        child: Icon(Icons.broken_image_outlined, size: 40),
      ),
    );
  }

  Widget _buildAddImagePlaceholder(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 40,
          color: AppColors.primary.withValues(alpha: 0.45),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap to upload image',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.primary.withValues(alpha: 0.55),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Optional — JPEG / PNG',
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.white38 : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildToggle({
    required bool isDark,
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A3A3C) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.shade200,
        ),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.grey.shade500,
          ),
        ),
        value: value,
        activeTrackColor: activeColor,
        onChanged: onChanged,
      ),
    );
  }
}
