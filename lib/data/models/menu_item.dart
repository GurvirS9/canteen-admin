class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? imageUrl;
  final bool isAvailable;
  final bool isVeg;
  final DateTime createdAt;
  final int prepTime;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    this.isAvailable = true,
    this.isVeg = true,
    this.prepTime = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isAvailable,
    bool? isVeg,
    int? prepTime,
    DateTime? createdAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      isVeg: isVeg ?? this.isVeg,
      prepTime: prepTime ?? this.prepTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'prepTime': prepTime,
    'isVeg': isVeg,
    'image': imageUrl ?? '',
  };

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? 'No description available',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    category: json['category'] as String? ?? 'Snacks',
    imageUrl: _resolveImageUrl(json['image'] as String? ?? json['imageUrl'] as String?),
    isAvailable: json['isAvailable'] as bool? ?? true,
    isVeg: json['isVeg'] as bool? ?? true,
    prepTime: (json['prepTime'] as num?)?.toInt() ?? 0,
    createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now() : DateTime.now(),
  );

  /// Resolve relative /uploads/... paths to full https:// URLs.
  static String? _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    // Relative path from backend: prepend host
    const host = 'https://kanteen-queue-production.up.railway.app';
    return '$host$raw';
  }
}

