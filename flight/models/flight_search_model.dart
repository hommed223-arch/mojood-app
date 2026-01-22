/// 🔍 نموذج بحث الطيران
class FlightSearchModel {
  final bool isRoundTrip;       // ذهاب وعودة أم ذهاب فقط
  final String fromCity;        // مدينة الإقلاع
  final String toCity;          // مدينة الوصول
  final String fromCode;        // كود المطار (مثل: RUH)
  final String toCode;          // كود المطار (مثل: JED)
  final DateTime departDate;    // تاريخ الذهاب
  final DateTime? returnDate;   // تاريخ العودة (اختياري)
  final int adults;             // عدد البالغين
  final int children;           // عدد الأطفال
  final int infants;            // عدد الرضع
  final String cabin;           // الدرجة (Economy, Business, First)

  FlightSearchModel({
    required this.isRoundTrip,
    required this.fromCity,
    required this.toCity,
    required this.fromCode,
    required this.toCode,
    required this.departDate,
    this.returnDate,
    required this.adults,
    required this.children,
    required this.infants,
    required this.cabin,
  });

  /// 👥 إجمالي الركاب
  int get totalPassengers => adults + children + infants;

  /// 📋 تحويل إلى Map للإرسال للـ API
  Map<String, dynamic> toJson() {
    return {
      'is_round_trip': isRoundTrip,
      'from_city': fromCity,
      'to_city': toCity,
      'from_code': fromCode,
      'to_code': toCode,
      'depart_date': departDate.toIso8601String().split('T').first,
      'return_date': returnDate?.toIso8601String().split('T').first,
      'adults': adults,
      'children': children,
      'infants': infants,
      'cabin': cabin,
      'total_passengers': totalPassengers,
    };
  }

  /// 📥 إنشاء من Map
  factory FlightSearchModel.fromJson(Map<String, dynamic> json) {
    return FlightSearchModel(
      isRoundTrip: json['is_round_trip'] ?? false,
      fromCity: json['from_city'] ?? '',
      toCity: json['to_city'] ?? '',
      fromCode: json['from_code'] ?? '',
      toCode: json['to_code'] ?? '',
      departDate: DateTime.parse(json['depart_date']),
      returnDate: json['return_date'] != null 
          ? DateTime.parse(json['return_date']) 
          : null,
      adults: json['adults'] ?? 1,
      children: json['children'] ?? 0,
      infants: json['infants'] ?? 0,
      cabin: json['cabin'] ?? 'Economy',
    );
  }

  /// 📝 نسخة معدلة
  FlightSearchModel copyWith({
    bool? isRoundTrip,
    String? fromCity,
    String? toCity,
    String? fromCode,
    String? toCode,
    DateTime? departDate,
    DateTime? returnDate,
    int? adults,
    int? children,
    int? infants,
    String? cabin,
  }) {
    return FlightSearchModel(
      isRoundTrip: isRoundTrip ?? this.isRoundTrip,
      fromCity: fromCity ?? this.fromCity,
      toCity: toCity ?? this.toCity,
      fromCode: fromCode ?? this.fromCode,
      toCode: toCode ?? this.toCode,
      departDate: departDate ?? this.departDate,
      returnDate: returnDate ?? this.returnDate,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      infants: infants ?? this.infants,
      cabin: cabin ?? this.cabin,
    );
  }

  @override
  String toString() {
    return 'FlightSearch(from: $fromCity, to: $toCity, date: $departDate, passengers: $totalPassengers)';
  }
}