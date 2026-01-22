import 'flight_search_model.dart';
import 'flight_offer.dart';

/// 🎫 نموذج الحجز الكامل
class BookingModel {
  final String id;                    // معرف الحجز
  final String userId;                // معرف المستخدم
  final String pnr;                   // رقم الحجز (6 أحرف)
  final FlightSearchModel search;     // معلومات البحث
  final FlightOffer outboundFlight;   // رحلة الذهاب
  final FlightOffer? returnFlight;    // رحلة العودة (اختياري)
  final String status;                // الحالة
  final String paymentMethod;         // طريقة الدفع
  final double totalPrice;            // السعر الإجمالي
  final DateTime createdAt;           // تاريخ الإنشاء
  
  // معلومات الركاب
  final List<PassengerInfo> passengers;

  BookingModel({
    required this.id,
    required this.userId,
    required this.pnr,
    required this.search,
    required this.outboundFlight,
    this.returnFlight,
    required this.status,
    required this.paymentMethod,
    required this.totalPrice,
    required this.createdAt,
    required this.passengers,
  });

  /// 🎲 توليد PNR عشوائي
  static String generatePNR() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    String pnr = '';
    
    for (int i = 0; i < 6; i++) {
      pnr += chars[(random + i) % chars.length];
    }
    
    return pnr;
  }

  /// 📥 إنشاء من قاعدة البيانات
  factory BookingModel.fromDb(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] ?? '',
      pnr: json['pnr'] ?? '',
      search: FlightSearchModel.fromJson(json['search_data'] ?? {}),
      outboundFlight: FlightOffer.fromDb(json['outbound_flight'] ?? {}),
      returnFlight: json['return_flight'] != null
          ? FlightOffer.fromDb(json['return_flight'])
          : null,
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? '',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      passengers: (json['passengers'] as List?)
          ?.map((p) => PassengerInfo.fromJson(p))
          .toList() ?? [],
    );
  }

  /// 📋 تحويل إلى Map للحفظ
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pnr': pnr,
      'search_data': search.toJson(),
      'outbound_flight': outboundFlight.toJson(),
      'return_flight': returnFlight?.toJson(),
      'status': status,
      'payment_method': paymentMethod,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
      'passengers': passengers.map((p) => p.toJson()).toList(),
    };
  }

  /// ✅ هل الحجز مؤكد؟
  bool get isConfirmed => status == 'confirmed';
  
  /// ❌ هل الحجز ملغي؟
  bool get isCancelled => status == 'cancelled';
  
  /// ⏳ هل الحجز قيد المعالجة؟
  bool get isPending => status == 'pending';

  /// 🔄 هل رحلة ذهاب وعودة؟
  bool get isRoundTrip => returnFlight != null;

  @override
  String toString() {
    return 'Booking($pnr: ${outboundFlight.fromCode}→${outboundFlight.toCode}, $totalPrice SAR)';
  }
}

/// 👤 معلومات الراكب
class PassengerInfo {
  final String type;           // adult, child, infant
  final String firstName;      // الاسم الأول
  final String lastName;       // اسم العائلة
  final String? title;         // Mr, Mrs, Ms
  final DateTime? dateOfBirth; // تاريخ الميلاد
  final String? passportNo;    // رقم الجواز
  final String? nationality;   // الجنسية

  PassengerInfo({
    required this.type,
    required this.firstName,
    required this.lastName,
    this.title,
    this.dateOfBirth,
    this.passportNo,
    this.nationality,
  });

  factory PassengerInfo.fromJson(Map<String, dynamic> json) {
    return PassengerInfo(
      type: json['type'] ?? 'adult',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      title: json['title'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      passportNo: json['passport_no'],
      nationality: json['nationality'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'first_name': firstName,
      'last_name': lastName,
      'title': title,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'passport_no': passportNo,
      'nationality': nationality,
    };
  }

  String get fullName => '$title $firstName $lastName'.trim();

  @override
  String toString() => fullName;
}