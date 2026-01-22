import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../payment/payment_screen.dart';
import '../models/flight_search_model.dart';
import '../fare/fare_screen.dart';
import '../passenger/passenger_info_screen.dart';
import '../models/flight_offer.dart';
class ReviewBookingScreen extends StatelessWidget {
  final FlightSearchModel search;
  final FlightOffer offer;
  final FareType fare;
  final int totalPrice;

  final List<PassengerData> passengers;
  final String phone;
  final String email;

  const ReviewBookingScreen({
    super.key,
    required this.search,
    required this.offer,
    required this.fare,
    required this.totalPrice,
    required this.passengers,
    required this.phone,
    required this.email,
  });

  String fareName(FareType f) {
    switch (f) {
      case FareType.basic:
        return "الضيافة الأساسية";
      case FareType.flexible:
        return "الضيافة المرنة";
      case FareType.premium:
        return "الضيافة المميزة";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "مراجعة الحجز",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _card(
              title: "الرحلة",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${search.fromCity} → ${search.toCity}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip("شركة: ${offer.airline}"),
                      _chip("الإقلاع: ${offer.departTime}"),
                      _chip("الوصول: ${offer.arriveTime}"),
                      if ((offer.duration ?? '').toString().isNotEmpty)
                        _chip("المدة: ${offer.duration}"),
                      _chip("التوقفات: ${offer.stops ?? 0}"),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    fareName(fare),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _card(
              title: "المسافرون (${passengers.length})",
              child: Column(
                children: passengers.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "${p.firstName} ${p.lastName}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            _card(
              title: "معلومات التواصل",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📞 $phone",
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 6),
                  Text("✉️ $email",
                      style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 90),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              border: Border(top: BorderSide(color: Colors.white.withOpacity(.08))),
            ),
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        search: search,
                        offer: offer,
                        fare: fare,
                        totalPrice: totalPrice,
                        passengers: passengers, // ✅ جديد
                        phone: phone, // ✅ جديد
                        email: email, // ✅ جديد
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "المتابعة إلى الدفع • $totalPrice ر.س",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(.85),
          fontWeight: FontWeight.w800,
          fontSize: 12.5,
        ),
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}