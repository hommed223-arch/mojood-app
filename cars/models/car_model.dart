/// 🚗 نموذج السيارة
class CarModel {
  final String id;
  final String brand;              // الماركة
  final String model;              // الموديل
  final int year;                  // السنة
  final String? color;             // اللون
  final String category;           // التصنيف
  final int seats;                 // عدد المقاعد
  final String transmission;       // ناقل الحركة
  final String fuelType;           // نوع الوقود
  final String city;               // المدينة
  final bool available;            // متاحة؟
  final double pricePerDay;        // السعر/اليوم
  final double? priceWithDriver;   // السعر مع سائق
  final String? imageUrl;          // صورة رئيسية
  final List<String>? images;      // صور إضافية
  final String? description;       // الوصف
  final List<String>? features;    // المميزات
  final bool insuranceIncluded;    // التأمين مشمول؟
  final bool unlimitedKm;          // كيلومترات غير محدودة؟
  final int? kmLimit;              // حد الكيلومترات
  final int minRentalDays;         // الحد الأدنى للإيجار

  CarModel({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    this.color,
    required this.category,
    required this.seats,
    required this.transmission,
    required this.fuelType,
    required this.city,
    required this.available,
    required this.pricePerDay,
    this.priceWithDriver,
    this.imageUrl,
    this.images,
    this.description,
    this.features,
    required this.insuranceIncluded,
    required this.unlimitedKm,
    this.kmLimit,
    required this.minRentalDays,
  });

  /// 📥 إنشاء من قاعدة البيانات
  factory CarModel.fromDb(Map<String, dynamic> json) {
    return CarModel(
      id: json['id']?.toString() ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? 2023,
      color: json['color'],
      category: json['category'] ?? 'متوسطة',
      seats: json['seats'] ?? 5,
      transmission: json['transmission'] ?? 'أوتوماتيك',
      fuelType: json['fuel_type'] ?? 'بنزين',
      city: json['city'] ?? '',
      available: json['available'] ?? true,
      pricePerDay: (json['price_per_day'] ?? 0).toDouble(),
      priceWithDriver: json['price_with_driver'] != null
          ? (json['price_with_driver'] as num).toDouble()
          : null,
      imageUrl: json['image_url'],
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,
      description: json['description'],
      features: json['features'] != null
          ? List<String>.from(json['features'])
          : null,
      insuranceIncluded: json['insurance_included'] ?? true,
      unlimitedKm: json['unlimited_km'] ?? false,
      kmLimit: json['km_limit'],
      minRentalDays: json['min_rental_days'] ?? 1,
    );
  }

  /// 🚗 اسم السيارة الكامل
  String get fullName => '$brand $model $year';

  /// 💰 نص السعر
  String get priceText => '${pricePerDay.toStringAsFixed(0)} ر.س/اليوم';

  /// 🏷️ أيقونة الفئة
  String get categoryIcon {
    switch (category) {
      case 'صغيرة':
        return '🚗';
      case 'متوسطة':
        return '🚙';
      case 'كبيرة':
        return '🚐';
      case 'فاخرة':
        return '✨';
      case 'رياضية':
        return '🏎️';
      default:
        return '🚗';
    }
  }

  /// 📋 تحويل إلى Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'category': category,
      'seats': seats,
      'transmission': transmission,
      'fuel_type': fuelType,
      'city': city,
      'available': available,
      'price_per_day': pricePerDay,
      'price_with_driver': priceWithDriver,
      'image_url': imageUrl,
      'images': images,
      'description': description,
      'features': features,
      'insurance_included': insuranceIncluded,
      'unlimited_km': unlimitedKm,
      'km_limit': kmLimit,
      'min_rental_days': minRentalDays,
    };
  }

  @override
  String toString() => fullName;
}