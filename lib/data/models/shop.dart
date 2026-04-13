/// Shop model for the Manager app — matches the full `Shop` schema from the backend.
class Shop {
  final String id;
  final String name;
  final String? ownerId;
  final double latitude;
  final double longitude;
  final String address;
  final int seatingCapacity;
  final int tableCount;
  final double rating;
  final int currentQueue;
  final bool isActive;
  final String openingTime;
  final String closingTime;
  final bool isOpen;
  final bool isCurrentlyOpen;

  const Shop({
    required this.id,
    required this.name,
    this.ownerId,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.seatingCapacity,
    required this.tableCount,
    required this.rating,
    required this.currentQueue,
    required this.isActive,
    required this.openingTime,
    required this.closingTime,
    required this.isOpen,
    required this.isCurrentlyOpen,
  });

  Shop copyWith({
    String? id,
    String? name,
    String? ownerId,
    double? latitude,
    double? longitude,
    String? address,
    int? seatingCapacity,
    int? tableCount,
    double? rating,
    int? currentQueue,
    bool? isActive,
    String? openingTime,
    String? closingTime,
    bool? isOpen,
    bool? isCurrentlyOpen,
  }) {
    return Shop(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      seatingCapacity: seatingCapacity ?? this.seatingCapacity,
      tableCount: tableCount ?? this.tableCount,
      rating: rating ?? this.rating,
      currentQueue: currentQueue ?? this.currentQueue,
      isActive: isActive ?? this.isActive,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      isOpen: isOpen ?? this.isOpen,
      isCurrentlyOpen: isCurrentlyOpen ?? this.isCurrentlyOpen,
    );
  }

  factory Shop.fromJson(Map<String, dynamic> json) {
    double lat = 0.0;
    double lng = 0.0;
    final loc = json['location'];
    if (loc is Map) {
      final coords = loc['coordinates'] as List?;
      if (coords != null && coords.length >= 2) {
        lng = (coords[0] as num).toDouble();
        lat = (coords[1] as num).toDouble();
      }
    } else {
      lat = (json['latitude'] as num? ?? 0).toDouble();
      lng = (json['longitude'] as num? ?? 0).toDouble();
    }

    // ownerId may be an ID string or a populated user object
    String? ownerId;
    final ownerRaw = json['ownerId'] ?? json['owner'];
    if (ownerRaw is String) {
      ownerId = ownerRaw;
    } else if (ownerRaw is Map) {
      ownerId = (ownerRaw['_id'] ?? ownerRaw['id'])?.toString();
    }

    return Shop(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      ownerId: ownerId,
      latitude: lat,
      longitude: lng,
      address: json['address'] as String? ?? '',
      seatingCapacity: (json['seatingCapacity'] as num?)?.toInt() ?? 0,
      tableCount: (json['tableCount'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      currentQueue: (json['currentQueue'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      openingTime: json['openingTime'] as String? ?? '',
      closingTime: json['closingTime'] as String? ?? '',
      isOpen: json['isOpen'] as bool? ?? false,
      isCurrentlyOpen: json['isCurrentlyOpen'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (ownerId != null) 'ownerId': ownerId,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'seatingCapacity': seatingCapacity,
        'tableCount': tableCount,
        'rating': rating,
        'currentQueue': currentQueue,
        'isActive': isActive,
        'openingTime': openingTime,
        'closingTime': closingTime,
        'isOpen': isOpen,
        'isCurrentlyOpen': isCurrentlyOpen,
      };
}
