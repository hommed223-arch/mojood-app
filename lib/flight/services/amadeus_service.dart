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
      return;
    }

    try {
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

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _accessToken = data['access_token'];
        
        // Token صالح لساعة، نخليه 55 دقيقة عشان نكون آمنين
        final expiresIn = data['expires_in'] as int;
        _tokenExpiry = DateTime.now().add(
          Duration(seconds: expiresIn - 300),
        );
        
        print('✅ Amadeus Token obtained successfully');
      } else {
        print('❌ Failed to get token: ${response.statusCode}');
        print('Response: ${response.body}');
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
      // احصل على Token أولاً
      await _getAccessToken();

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
        queryParams['returnDate'] = _formatDate(returnDate);
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

      print('🔍 Searching flights: $uri');

      // اطلب البيانات
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final offers = (data['data'] as List?)?.map((json) {
          try {
            return FlightOffer.fromAmadeus(json);
          } catch (e) {
            print('⚠️ Error parsing flight: $e');
            return null;
          }
        }).whereType<FlightOffer>().toList() ?? [];

        print('✅ Found ${offers.length} flights');
        return offers;
      } else {
        print('❌ Search failed: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('فشل البحث: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error searching flights: $e');
      rethrow;
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

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['data'] as List?)?.map((json) {
          try {
            return Airport.fromJson(json);
          } catch (e) {
            return null;
          }
        }).whereType<Airport>().toList() ?? [];
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
      await _getAccessToken();
      return _accessToken != null;
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