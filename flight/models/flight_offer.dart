/// ✈️ نموذج عرض الرحلة
class FlightOffer {
  final String id;
  final String airline;
  final String airlineCode;
  final String flightNumber;
  final String departureAirport;
  final String arrivalAirport;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String duration;
  final double price;
  final String currency;
  final int availableSeats;
  final String cabinClass;
  final int stops;
  
  // 🆕 للحجز الخارجي
  final String? bookingUrl;
  final String? deepLink;

  FlightOffer({
    required this.id,
    required this.airline,
    required this.airlineCode,
    required this.flightNumber,
    required this.departureAirport,
    required this.arrivalAirport,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.currency,
    required this.availableSeats,
    required this.cabinClass,
    required this.stops,
    this.bookingUrl,
    this.deepLink,
  });

  /// 📥 إنشاء من Amadeus API
  factory FlightOffer.fromAmadeus(Map<String, dynamic> json) {
    try {
      // الرحلة الأولى (ذهاب)
      final itineraries = json['itineraries'] as List;
      final firstItinerary = itineraries[0] as Map<String, dynamic>;
      final segments = firstItinerary['segments'] as List;
      final firstSegment = segments[0] as Map<String, dynamic>;
      
      // السعر
      final price = json['price'] as Map<String, dynamic>;
      final total = double.parse(price['total'].toString());
      final currency = price['currency'] as String;
      
      // معلومات الناقل
      final carrierCode = firstSegment['carrierCode'] as String;
      final flightNumber = firstSegment['number'] as String;
      
      // الأوقات
      final departure = firstSegment['departure'] as Map<String, dynamic>;
      final arrival = firstSegment['arrival'] as Map<String, dynamic>;
      
      // عدد التوقفات
      final stops = segments.length - 1;

      return FlightOffer(
        id: json['id'] ?? '',
        airline: _getAirlineName(carrierCode),
        airlineCode: carrierCode,
        flightNumber: '$carrierCode$flightNumber',
        departureAirport: departure['iataCode'] ?? '',
        arrivalAirport: arrival['iataCode'] ?? '',
        departureTime: DateTime.parse(departure['at']),
        arrivalTime: DateTime.parse(arrival['at']),
        duration: _formatDuration(firstItinerary['duration'] ?? ''),
        price: total,
        currency: currency,
        availableSeats: json['numberOfBookableSeats'] ?? 9,
        cabinClass: _formatCabinClass(firstSegment['cabin'] ?? 'ECONOMY'),
        stops: stops,
        bookingUrl: _generateBookingUrl(carrierCode),
        deepLink: json['deepLink'],
      );
    } catch (e) {
      print('❌ Error parsing flight offer: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  /// ✈️ اسم شركة الطيران
  static String _getAirlineName(String code) {
    const airlines = {
      'SV': 'الخطوط السعودية',
      'XY': 'طيران ناس',
      'F3': 'فلاي دبي',
      'EK': 'طيران الإمارات',
      'QR': 'الخطوط القطرية',
      'MS': 'مصر للطيران',
      'RJ': 'الملكية الأردنية',
      'TK': 'الخطوط التركية',
      'EY': 'الاتحاد للطيران',
      'WY': 'الطيران العماني',
      'G9': 'العربية للطيران',
      'J9': 'جزيرة للطيران',
    };
    
    return airlines[code] ?? code;
  }

  /// 🔗 رابط الحجز حسب شركة الطيران
  static String _generateBookingUrl(String carrierCode) {
    const urls = {
      'SV': 'https://www.saudia.com',
      'XY': 'https://www.flynas.com',
      'F3': 'https://www.flydubai.com',
      'EK': 'https://www.emirates.com',
      'QR': 'https://www.qatarairways.com',
      'MS': 'https://www.egyptair.com',
      'RJ': 'https://www.rj.com',
      'TK': 'https://www.turkishairlines.com',
      'EY': 'https://www.etihad.com',
      'WY': 'https://www.omanair.com',
      'G9': 'https://www.airarabia.com',
    };
    
    return urls[carrierCode] ?? 'https://www.skyscanner.com';
  }

  /// 🕐 تنسيق المدة
  static String _formatDuration(String isoDuration) {
    try {
      // PT2H30M -> 2س 30د
      final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?');
      final match = regex.firstMatch(isoDuration);
      
      if (match != null) {
        final hours = match.group(1);
        final minutes = match.group(2);
        
        if (hours != null && minutes != null) {
          return '${hours}س ${minutes}د';
        } else if (hours != null) {
          return '${hours}س';
        } else if (minutes != null) {
          return '${minutes}د';
        }
      }
    } catch (e) {
      print('⚠️ Error formatting duration: $e');
    }
    
    return isoDuration;
  }

  /// 🎫 تنسيق الدرجة
  static String _formatCabinClass(String cabin) {
    const classes = {
      'ECONOMY': 'اقتصادية',
      'PREMIUM_ECONOMY': 'اقتصادية مميزة',
      'BUSINESS': 'رجال أعمال',
      'FIRST': 'أولى',
    };
    
    return classes[cabin] ?? cabin;
  }

  /// 🕐 وقت الإقلاع (نص)
  String get departureTimeText {
    final hour = departureTime.hour.toString().padLeft(2, '0');
    final minute = departureTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 🕐 وقت الوصول (نص)
  String get arrivalTimeText {
    final hour = arrivalTime.hour.toString().padLeft(2, '0');
    final minute = arrivalTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 💰 السعر (نص)
  String get priceText => '${price.toStringAsFixed(0)} $currency';

  /// 🔄 نص التوقفات
  String get stopsText {
    if (stops == 0) return 'مباشرة';
    if (stops == 1) return 'توقف واحد';
    return '$stops توقفات';
  }

  /// 🎨 لون التوقفات
  String get stopsColor {
    if (stops == 0) return 'green';
    if (stops == 1) return 'orange';
    return 'red';
  }

  /// 🖼️ شعار شركة الطيران
  String get airlineLogo {
    return 'https://images.kiwi.com/airlines/64x64/$airlineCode.png';
  }

  @override
  String toString() => '$airline $flightNumber: $departureAirport → $arrivalAirport';
}