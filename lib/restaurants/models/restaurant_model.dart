/// 🍽️ نموذج المطعم
class Restaurant {
  final String id;
  final String name;
  final String? nameEn;
  final String? logoUrl;
  final String? coverImage;
  final String? description;
  final String category;
  final double rating;
  final int totalReviews;
  
  // التوصيل
  final bool deliveryAvailable;
  final double deliveryFee;
  final int? deliveryTimeMin;
  final int? deliveryTimeMax;
  final double minOrderDelivery;
  
  // الاستلام
  final bool pickupAvailable;
  final int? pickupTimeMin;
  final int? pickupTimeMax;
  final double minOrderPickup;
  
  // الموقع
  final String? address;
  final String? city;
  final double? latitude;
  final double? longitude;
  
  // أوقات العمل
  final String? openingTime;
  final String? closingTime;
  final bool isOpen;
  
  final DateTime? createdAt;

  Restaurant({
    required this.id,
    required this.name,
    this.nameEn,
    this.logoUrl,
    this.coverImage,
    this.description,
    required this.category,
    required this.rating,
    required this.totalReviews,
    required this.deliveryAvailable,
    required this.deliveryFee,
    this.deliveryTimeMin,
    this.deliveryTimeMax,
    required this.minOrderDelivery,
    required this.pickupAvailable,
    this.pickupTimeMin,
    this.pickupTimeMax,
    required this.minOrderPickup,
    this.address,
    this.city,
    this.latitude,
    this.longitude,
    this.openingTime,
    this.closingTime,
    required this.isOpen,
    this.createdAt,
  });

  /// 📥 من JSON
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['name_en'],
      logoUrl: json['logo_url'],
      coverImage: json['cover_image'],
      description: json['description'],
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      deliveryAvailable: json['delivery_available'] ?? true,
      deliveryFee: (json['delivery_fee'] ?? 0).toDouble(),
      deliveryTimeMin: json['delivery_time_min'],
      deliveryTimeMax: json['delivery_time_max'],
      minOrderDelivery: (json['min_order_delivery'] ?? 0).toDouble(),
      pickupAvailable: json['pickup_available'] ?? true,
      pickupTimeMin: json['pickup_time_min'],
      pickupTimeMax: json['pickup_time_max'],
      minOrderPickup: (json['min_order_pickup'] ?? 0).toDouble(),
      address: json['address'],
      city: json['city'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      isOpen: json['is_open'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
    );
  }

  /// 📤 إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'logo_url': logoUrl,
      'cover_image': coverImage,
      'description': description,
      'category': category,
      'rating': rating,
      'total_reviews': totalReviews,
      'delivery_available': deliveryAvailable,
      'delivery_fee': deliveryFee,
      'delivery_time_min': deliveryTimeMin,
      'delivery_time_max': deliveryTimeMax,
      'min_order_delivery': minOrderDelivery,
      'pickup_available': pickupAvailable,
      'pickup_time_min': pickupTimeMin,
      'pickup_time_max': pickupTimeMax,
      'min_order_pickup': minOrderPickup,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'opening_time': openingTime,
      'closing_time': closingTime,
      'is_open': isOpen,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// ⏱️ وقت التوصيل (نص)
  String get deliveryTimeText {
    if (deliveryTimeMin != null && deliveryTimeMax != null) {
      return '$deliveryTimeMin-$deliveryTimeMax دقيقة';
    }
    return 'غير محدد';
  }

  /// ⏱️ وقت الاستلام (نص)
  String get pickupTimeText {
    if (pickupTimeMin != null && pickupTimeMax != null) {
      return '$pickupTimeMin-$pickupTimeMax دقيقة';
    }
    return 'غير محدد';
  }

  /// 💵 رسوم التوصيل (نص)
  String get deliveryFeeText {
    if (deliveryFee == 0) {
      return 'مجاناً';
    }
    return '${deliveryFee.toStringAsFixed(0)} ر.س';
  }

  /// ⭐ التقييم (نص)
  String get ratingText => rating.toStringAsFixed(1);

  /// 🏷️ أيقونة التصنيف
  String get categoryEmoji {
    const emojis = {
      'برجر': '🍔',
      'بيتزا': '🍕',
      'دجاج': '🍗',
      'شاورما': '🌯',
      'مشويات': '🥩',
      'مأكولات بحرية': '🦐',
      'حلويات': '🍰',
      'مشروبات': '🥤',
      'إفطار': '🍳',
      'عربي': '🍛',
      'آسيوي': '🍜',
      'إيطالي': '🍝',
      'مكسيكي': '🌮',
      'سوشي': '🍱',
    };
    return emojis[category] ?? '🍽️';
  }

  @override
  String toString() => '$name ($category) - ⭐ $rating';
}