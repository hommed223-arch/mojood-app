import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/amadeus_service.dart';
import 'models/flight_offer.dart';
import 'models/flight_search_model.dart';
import '../core/app_colors.dart';

/// 📋 شاشة نتائج البحث
class FlightResultsScreen extends StatefulWidget {
  final FlightSearchModel search;
  
  const FlightResultsScreen({
    super.key,
    required this.search,
  });
  
  @override
  State<FlightResultsScreen> createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  final _amadeusService = AmadeusService();
  List<FlightOffer> _flights = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchFlights();
  }

  /// 🔍 البحث عن الرحلات
  Future<void> _searchFlights() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // استخدم fromCode و toCode مباشرة (موجودين في الـ model!)
      final flights = await _amadeusService.searchFlights(
        origin: widget.search.fromCode,
        destination: widget.search.toCode,
        departureDate: widget.search.departDate,
        returnDate: widget.search.isRoundTrip 
            ? widget.search.returnDate 
            : null,
        adults: widget.search.adults,
        children: widget.search.children,
        infants: widget.search.infants,
        maxResults: 50,
      );

      setState(() {
        _flights = flights;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ في البحث. الرجاء المحاولة مرة أخرى.';
        _isLoading = false;
      });
      print('❌ Search error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.cardDark,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'نتائج البحث',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '${widget.search.fromCity} → ${widget.search.toCity}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                // TODO: أضف فلترة
              },
            ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  /// 🎨 بناء المحتوى
  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'جاري البحث عن أفضل الرحلات...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _searchFlights,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_flights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flight_takeoff, size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            const Text(
              'لا توجد رحلات متاحة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'جرب تواريخ أخرى',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // رأس النتائج
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.cardDark,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'وجدنا ${_flights.length} رحلة',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // TODO: ترتيب
                },
                icon: const Icon(Icons.sort, size: 18),
                label: const Text('ترتيب'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        // قائمة الرحلات
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _flights.length,
            itemBuilder: (context, index) {
              return _buildFlightCard(_flights[index]);
            },
          ),
        ),
      ],
    );
  }

  /// ✈️ كارت الرحلة
  Widget _buildFlightCard(FlightOffer flight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // الهيدر: شركة الطيران + السعر
                Row(
                  children: [
                    // شعار الطيران
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.bgDark,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.network(
                        flight.airlineLogo,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.flight,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // اسم الطيران ورقم الرحلة
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flight.airline,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            flight.flightNumber,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // السعر
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          flight.priceText,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'للشخص',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // معلومات الرحلة
                Row(
                  children: [
                    // وقت ومطار الإقلاع
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            flight.departureTimeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            flight.departureAirport,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // المدة والتوقفات
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bgDark,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              flight.duration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(
                                  Icons.flight,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 2,
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            flight.stopsText,
                            style: TextStyle(
                              color: flight.stops == 0 
                                  ? Colors.green 
                                  : Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // وقت ومطار الوصول
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            flight.arrivalTimeText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            flight.arrivalAirport,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // معلومات إضافية
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.airline_seat_recline_normal,
                      flight.cabinClass,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.event_seat,
                      '${flight.availableSeats} مقاعد',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // زر الحجز
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderDark),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _bookFlight(flight),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'احجز الآن',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🏷️ شريحة معلومات
  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white54, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔗 فتح رابط الحجز
  Future<void> _bookFlight(FlightOffer flight) async {
    final url = flight.bookingUrl;
    
    if (url == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('عذراً، رابط الحجز غير متوفر'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('Cannot launch URL');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل فتح رابط الحجز'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}