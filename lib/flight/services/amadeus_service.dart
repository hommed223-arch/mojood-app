import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight_offer.dart';

/// 🛫 خدمة Amadeus API
/// للبحث عن الرحلات والمطارات
class AmadeusService {
  // 🔑 مفاتيح API
  static const String _apiKey = 'jhFPwGOBzvbFAzoUzc7O4cvPAO4FSbWD';
  static const String _apiSecret = 'bHl4y9QQ5GVkBylX';
  
  // 🌐 URLs
  static const String _authUrl = 'https://test.api.amadeus.com/v1/security/oauth2/token';
  static const String _baseUrl = 'https://test.api.amadeus.com/v2';
  
  // 🎫 Access Token
  String? _accessToken;
  DateTime? _tokenExpiry;

  /// 🔐 الحصول على Access Token
  Future<void> _getAccessToken() async {
    // إذا Token موجود ومازال صالح، لا تجدده
    if (_accessToken != null && 
        _tokenExpiry != null && 
        DateTime.now().isBefore(_tokenExpiry!)) {
      print('✅ Using existing token');
      return;
    }

    try {
      print('🔑 Requesting new Amadeus token...');
      
      final response = await http.post(
        Uri.parse(_authUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'client_credentials',
          'client_id': _apiKey,
          'client_secret': _apiSecret,
        },
      );

      print('📡 Token Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        
        // Token صالح لساعة، نخليه 55 دقيقة عشان نكون آمنين
        final expiresIn = data['expires_in'] as int;
        _tokenExpiry = DateTime.now().add(
          Duration(seconds: expiresIn - 300),
        );
        
        print('✅ Amadeus Token obtained successfully');
        print('   Expires in: ${expiresIn}s');
      } else {
        print('❌ Failed to get token: ${response.statusCode}');
        print('   Response: ${response.body}');
        throw Exception('فشل الحصول على Token: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting token: $e');
      throw Exception('خطأ في الاتصال بـ Amadeus: $e');
    }
  }

  /// 🔍 البحث عن رحلات
  Future<List<FlightOffer>> searchFlights({
    required String origin,
    required String destination,
    required DateTime departureDate,
    DateTime? returnDate,
    int adults = 1,
    int children = 0,
    int infants = 0,
    int maxResults = 20,
  }) async {
    try {
      print('🔍 Starting flight search...');
      print('   From: $origin → To: $destination');
      print('   Date: ${_formatDate(departureDate)}');
      print('   Passengers: $adults adults, $children children, $infants infants');
      
      // احصل على Token أولاً
      await _getAccessToken();

      if (_accessToken == null) {
        throw Exception('فشل الحصول على Token');
      }

      // تحقق من صحة التاريخ
      final today = DateTime.now();
      final minDate = DateTime(today.year, today.month, today.day);
      
      if (departureDate.isBefore(minDate)) {
        print('❌ Invalid date: departure date is in the past');
        throw Exception('تاريخ الرحلة يجب أن يكون في المستقبل');
      }

      // تحقق من أكواد المطارات
      if (origin.length != 3 || destination.length != 3) {
        print('❌ Invalid airport codes');
        throw Exception('أكواد المطارات يجب أن تكون 3 أحرف');
      }

      // جهز parameters البحث
      final queryParams = {
        'originLocationCode': origin.toUpperCase(),
        'destinationLocationCode': destination.toUpperCase(),
        'departureDate': _formatDate(departureDate),
        'adults': adults.toString(),
        'max': maxResults.toString(),
        'currencyCode': 'SAR',
      };

      // أضف تاريخ العودة إذا موجود
      if (returnDate != null) {
        if (returnDate.isBefore(departureDate)) {
          throw Exception('تاريخ العودة يجب أن يكون بعد تاريخ الذهاب');
        }
        queryParams['returnDate'] = _formatDate(returnDate);
        print('   Return: ${_formatDate(returnDate)}');
      }

      // أضف الأطفال والرضع
      if (children > 0) {
        queryParams['children'] = children.toString();
      }
      if (infants > 0) {
        queryParams['infants'] = infants.toString();
      }

      // اصنع URL
      final uri = Uri.parse('$_baseUrl/shopping/flight-offers')
          .replace(queryParameters: queryParams);

      print('📡 Request URL: ${uri.toString()}');

      // اطلب البيانات
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Accept': 'application/json',
        },
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception('انتهت مهلة الاتصال - حاول مرة أخرى');
        },
      );

      print('📡 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // تحقق من وجود بيانات
        if (data['data'] == null || (data['data'] as List).isEmpty) {
          print('⚠️ No flights found');
          return [];
        }

        final offers = (data['data'] as List).map((json) {
          try {
            return FlightOffer.fromAmadeus(json);
          } catch (e) {
            print('⚠️ Error parsing flight: $e');
            return null;
          }
        }).whereType<FlightOffer>().toList();

        print('✅ Found ${offers.length} flights');
        return offers;
        
      } else if (response.statusCode == 400) {
        // Bad Request - مشكلة في البارامترات
        print('❌ 400 Bad Request');
        print('   Response: ${response.body}');
        
        try {
          final errorData = json.decode(response.body);
          final errors = errorData['errors'] as List?;
          
          if (errors != null && errors.isNotEmpty) {
            final errorDetail = errors[0]['detail'] ?? errors[0]['title'] ?? 'خطأ في البيانات';
            throw Exception(errorDetail);
          }
        } catch (e) {
          if (e is Exception) rethrow;
        }
        
        throw Exception('خطأ في البيانات المدخلة - تحقق من التواريخ وأكواد المطارات');
        
      } else if (response.statusCode == 401) {
        // Unauthorized - Token خاطئ أو منتهي
        print('❌ 401 Unauthorized - Token expired');
        _accessToken = null;
        _tokenExpiry = null;
        throw Exception('انتهت صلاحية الجلسة - حاول مرة أخرى');
        
      } else if (response.statusCode == 500) {
        // Server Error
        print('❌ 500 Server Error');
        print('   Response: ${response.body}');
        throw Exception('خطأ في خادم Amadeus - حاول لاحقاً');
        
      } else {
        print('❌ Unknown Error ${response.statusCode}');
        print('   Response: ${response.body}');
        throw Exception('فشل البحث - حاول مرة أخرى');
      }
    } catch (e) {
      print('❌ Error searching flights: $e');
      
      // إعادة رمي الأخطاء المعروفة
      if (e is Exception) {
        rethrow;
      }
      
      // أخطاء غير متوقعة
      throw Exception('حدث خطأ غير متوقع: ${e.toString()}');
    }
  }

  /// 🏢 البحث عن مطارات
  Future<List<Airport>> searchAirports(String keyword) async {
    if (keyword.length < 2) return [];

    try {
      await _getAccessToken();

      final uri = Uri.parse('$_baseUrl/reference-data/locations')
          .replace(queryParameters: {
        'subType': 'AIRPORT,CITY',
        'keyword': keyword,
        'page[limit]': '10',
      });

      print('🔍 Searching airports: $keyword');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final airports = (data['data'] as List?)?.map((json) {
          try {
            return Airport.fromJson(json);
          } catch (e) {
            print('⚠️ Error parsing airport: $e');
            return null;
          }
        }).whereType<Airport>().toList() ?? [];
        
        print('✅ Found ${airports.length} airports');
        return airports;
      } else {
        print('❌ Airport search failed: ${response.statusCode}');
      }
      
      return [];
    } catch (e) {
      print('❌ Error searching airports: $e');
      return [];
    }
  }

  /// 📅 تنسيق التاريخ (YYYY-MM-DD)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 🧪 اختبار الاتصال
  Future<bool> testConnection() async {
    try {
      print('🧪 Testing Amadeus connection...');
      await _getAccessToken();
      final success = _accessToken != null;
      print(success ? '✅ Connection test passed' : '❌ Connection test failed');
      return success;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }
}

/// ✈️ نموذج المطار
class Airport {
  final String iataCode;
  final String name;
  final String cityName;
  final String countryName;
  final String type;

  Airport({
    required this.iataCode,
    required this.name,
    required this.cityName,
    required this.countryName,
    required this.type,
  });

  factory Airport.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    
    return Airport(
      iataCode: json['iataCode'] ?? '',
      name: json['name'] ?? '',
      cityName: address?['cityName'] ?? '',
      countryName: address?['countryName'] ?? '',
      type: json['subType'] ?? 'AIRPORT',
    );
  }

  /// 📝 نص كامل للعرض
  String get displayText => '$name ($iataCode) - $cityName, $countryName';
  
  /// 📝 نص مختصر
  String get shortText => '$cityName ($iataCode)';

  @override
  String toString() => displayText;
}