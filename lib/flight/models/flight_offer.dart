/// ✈️ نموذج عرض الرحلة
class FlightOffer {
  final String id;              // معرف الرحلة
  final String airline;         // شركة الطيران
  final String flightNo;        // رقم الرحلة
  final String fromCity;        // مدينة الإقلاع
  final String toCity;          // مدينة الوصول
  final String fromCode;        // كود المطار
  final String toCode;          // كود المطار
  final String date;            // تاريخ الرحلة
  final String departTime;      // وقت الإقلاع
  final String arriveTime;      // وقت الوصول
  final String duration;        // مدة الرحلة
  final int stops;              // عدد التوقفات
  final double price;           // السعر الأساسي
  final String cabin;           // الدرجة
  final int availableSeats;     // المقاعد المتاحة
  
  // معلومات إضافية
  final String? aircraftType;   // نوع الطائرة
  final List<String>? amenities; // الخدمات المتوفرة
  final Map<String, dynamic>? baggage; // معلومات الحقائب

  FlightOffer({
    required this.id,
    required this.airline,
    required this.flightNo,
    required this.fromCity,
    required this.toCity,
    required this.fromCode,
    required this.toCode,
    required this.date,
    required this.departTime,
    required this.arriveTime,
    required this.duration,
    required this.stops,
    required this.price,
    required this.cabin,
    required this.availableSeats,
    this.aircraftType,
    this.amenities,
    this.baggage,
  });

  /// 📥 إنشاء من قاعدة البيانات
  factory FlightOffer.fromDb(Map<String, dynamic> json) {
    return FlightOffer(
      id: json['id']?.toString() ?? '',
      airline: json['airline'] ?? '',
      flightNo: json['flight_no'] ?? '',
      fromCity: json['from_city'] ?? '',
      toCity: json['to_city'] ?? '',
      fromCode: json['from_code'] ?? '',
      toCode: json['to_code'] ?? '',
      date: json['date'] ?? '',
      departTime: json['depart_time'] ?? '',
      arriveTime: json['arrive_time'] ?? '',
      duration: json['duration'] ?? '',
      stops: json['stops'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      cabin: json['cabin'] ?? 'Economy',
      availableSeats: json['available_seats'] ?? 0,
      aircraftType: json['aircraft_type'],
      amenities: json['amenities'] != null 
          ? List<String>.from(json['amenities']) 
          : null,
      baggage: json['baggage'],
    );
  }

  /// 📋 تحويل إلى Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'airline': airline,
      'flight_no': flightNo,
      'from_city': fromCity,
      'to_city': toCity,
      'from_code': fromCode,
      'to_code': toCode,
      'date': date,
      'depart_time': departTime,
      'arrive_time': arriveTime,
      'duration': duration,
      'stops': stops,
      'price': price,
      'cabin': cabin,
      'available_seats': availableSeats,
      'aircraft_type': aircraftType,
      'amenities': amenities,
      'baggage': baggage,
    };
  }

  /// 🎫 حساب السعر الكلي حسب الركاب
  double calculateTotalPrice({
    required int adults,
    required int children,
    required int infants,
  }) {
    // البالغين: السعر الكامل
    double total = price * adults;
    
    // الأطفال: 75% من السعر
    total += (price * 0.75) * children;
    
    // الرضع: 10% من السعر
    total += (price * 0.10) * infants;
    
    return total;
  }

  /// ⏱️ هل الرحلة متاحة؟
  bool get isAvailable => availableSeats > 0;

  /// 🛑 نص عدد التوقفات
  String get stopsText {
    if (stops == 0) return 'بدون توقف';
    if (stops == 1) return 'توقف واحد';
    return '$stops توقفات';
  }

  /// 📝 نسخة معدلة
  FlightOffer copyWith({
    String? id,
    String? airline,
    String? flightNo,
    String? fromCity,
    String? toCity,
    String? fromCode,
    String? toCode,
    String? date,
    String? departTime,
    String? arriveTime,
    String? duration,
    int? stops,
    double? price,
    String? cabin,
    int? availableSeats,
    String? aircraftType,
    List<String>? amenities,
    Map<String, dynamic>? baggage,
  }) {
    return FlightOffer(
      id: id ?? this.id,
      airline: airline ?? this.airline,
      flightNo: flightNo ?? this.flightNo,
      fromCity: fromCity ?? this.fromCity,
      toCity: toCity ?? this.toCity,
      fromCode: fromCode ?? this.fromCode,
      toCode: toCode ?? this.toCode,
      date: date ?? this.date,
      departTime: departTime ?? this.departTime,
      arriveTime: arriveTime ?? this.arriveTime,
      duration: duration ?? this.duration,
      stops: stops ?? this.stops,
      price: price ?? this.price,
      cabin: cabin ?? this.cabin,
      availableSeats: availableSeats ?? this.availableSeats,
      aircraftType: aircraftType ?? this.aircraftType,
      amenities: amenities ?? this.amenities,
      baggage: baggage ?? this.baggage,
    );
  }

  @override
  String toString() {
    return 'FlightOffer($airline $flightNo: $fromCode→$toCode, $price SAR)';
  }
}