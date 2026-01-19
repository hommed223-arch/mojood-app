/// 📋 نموذج حجز السيارة
class CarBookingModel {
  final String id;
  final String carId;
  final String userId;
  final String carBrand;
  final String carModel;
  final int carYear;
  final DateTime pickupDate;
  final DateTime returnDate;
  final int rentalDays;
  final String pickupCity;
  final String? returnCity;
  final bool withDriver;
  final double? driverPrice;
  final double dailyPrice;
  final double totalPrice;
  final String? paymentMethod;
  final String status;
  final String bookingRef;
  final DateTime createdAt;

  CarBookingModel({
    required this.id,
    required this.carId,
    required this.userId,
    required this.carBrand,
    required this.carModel,
    required this.carYear,
    required this.pickupDate,
    required this.returnDate,
    required this.rentalDays,
    required this.pickupCity,
    this.returnCity,
    required this.withDriver,
    this.driverPrice,
    required this.dailyPrice,
    required this.totalPrice,
    this.paymentMethod,
    required this.status,
    required this.bookingRef,
    required this.createdAt,
  });

  /// 📥 إنشاء من قاعدة البيانات
  factory CarBookingModel.fromDb(Map<String, dynamic> json) {
    return CarBookingModel(
      id: json['id']?.toString() ?? '',
      carId: json['car_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      carBrand: json['car_brand'] ?? '',
      carModel: json['car_model'] ?? '',
      carYear: json['car_year'] ?? 2023,
      pickupDate: DateTime.parse(json['pickup_date']),
      returnDate: DateTime.parse(json['return_date']),
      rentalDays: json['rental_days'] ?? 1,
      pickupCity: json['pickup_city'] ?? '',
      returnCity: json['return_city'],
      withDriver: json['with_driver'] ?? false,
      driverPrice: json['driver_price'] != null
          ? (json['driver_price'] as num).toDouble()
          : null,
      dailyPrice: (json['daily_price'] ?? 0).toDouble(),
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'],
      status: json['status'] ?? 'pending',
      bookingRef: json['booking_ref'] ?? '',
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// 🎲 توليد رقم حجز عشوائي
  static String generateBookingRef() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String ref = 'CAR';

    for (int i = 0; i < 6; i++) {
      ref += chars[(random + i) % chars.length];
    }

    return ref;
  }

  /// 🚗 اسم السيارة الكامل
  String get carFullName => '$carBrand $carModel $carYear';

  /// ✅ هل الحجز مؤكد؟
  bool get isConfirmed => status == 'confirmed';

  /// ⏳ هل الحجز نشط؟
  bool get isActive => status == 'active';

  /// ❌ هل الحجز ملغي؟
  bool get isCancelled => status == 'cancelled';

  /// ✔️ هل الحجز مكتمل؟
  bool get isCompleted => status == 'completed';

  /// 📊 نص الحالة
  String get statusText {
    switch (status) {
      case 'confirmed':
        return 'مؤكد';
      case 'active':
        return 'نشط';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return 'قيد المعالجة';
    }
  }

  /// 📋 تحويل إلى Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car_id': carId,
      'user_id': userId,
      'car_brand': carBrand,
      'car_model': carModel,
      'car_year': carYear,
      'pickup_date': pickupDate.toIso8601String().split('T').first,
      'return_date': returnDate.toIso8601String().split('T').first,
      'rental_days': rentalDays,
      'pickup_city': pickupCity,
      'return_city': returnCity,
      'with_driver': withDriver,
      'driver_price': driverPrice,
      'daily_price': dailyPrice,
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'status': status,
      'booking_ref': bookingRef,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Booking($bookingRef: $carFullName)';
}