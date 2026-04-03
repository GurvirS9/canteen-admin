import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:manager_app/core/theme/app_colors.dart';
import 'package:manager_app/core/utils/logger.dart';

/// Reusable widget for displaying a menu-item image with:
///   • Loading shimmer
///   • Placeholder when the URL is empty / null
///   • Error fallback when the network image fails to load
///
/// The URL is expected to already be fully resolved (the [MenuItem.fromJson]
/// handles /uploads/ → https:// normalisation in the model layer).
class MenuItemImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String itemName;

  const MenuItemImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.itemName = '',
  });

  bool get _hasValidUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return false;
    final uri = Uri.tryParse(imageUrl!);
    return uri != null && uri.hasScheme;
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.zero;

    if (!_hasValidUrl) {
      AppLogger.d('MenuItemImage', 'No image URL for "$itemName" — showing placeholder');
      return ClipRRect(
        borderRadius: radius,
        child: _PlaceholderWidget(width: width, height: height),
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _LoadingWidget(width: width, height: height),
        errorWidget: (context, url, error) {
          AppLogger.w('MenuItemImage',
              'Failed to load image for "$itemName" from $url — $error');
          return _PlaceholderWidget(width: width, height: height);
        },
      ),
    );
  }
}

// ── Placeholder ──────────────────────────────────────────────────────────────

class _PlaceholderWidget extends StatelessWidget {
  final double? width;
  final double? height;
  const _PlaceholderWidget({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.primaryLight.withValues(alpha: 0.15)
            : AppColors.primaryLight.withValues(alpha: 0.08),
      ),
      child: Icon(
        Icons.restaurant,
        size: (height ?? 64) * 0.45,
        color: AppColors.primary.withValues(alpha: 0.4),
      ),
    );
  }
}

// ── Loading shimmer ──────────────────────────────────────────────────────────

class _LoadingWidget extends StatelessWidget {
  final double? width;
  final double? height;
  const _LoadingWidget({this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      color: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF1F5F9),
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}
