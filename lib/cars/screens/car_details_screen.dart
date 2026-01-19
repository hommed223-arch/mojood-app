import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../models/car_model.dart';
import 'car_booking_screen.dart';

class CarDetailsScreen extends StatelessWidget {
  final CarModel car;

  const CarDetailsScreen({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final gallery = car.images?.isNotEmpty == true
        ? car.images!
        : [car.imageUrl ?? ''];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            car.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معرض الصور
              SizedBox(
                height: 260,
                child: PageView.builder(
                  itemCount: gallery.length,
                  itemBuilder: (_, index) {
                    return Image.network(
                      gallery[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.black26,
                        child: const Center(
                          child: Icon(Icons.directions_car,
                              size: 80, color: Colors.white54),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الاسم والسعر
                    Text(
                      car.fullName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          car.city,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          car.priceText,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // الوصف
                    if (car.description != null) ...[
                      const Text(
                        "الوصف",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        car.description!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // المواصفات
                    const Text(
                      "المواصفات",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _spec(Icons.event_seat, "المقاعد", "${car.seats} مقاعد"),
                    _spec(Icons.settings, "ناقل الحركة", car.transmission),
                    _spec(Icons.local_gas_station, "نوع الوقود", car.fuelType),
                    _spec(Icons.palette, "اللون", car.color ?? "غير محدد"),
                    _spec(Icons.category, "الفئة",
                        "${car.categoryIcon} ${car.category}"),

                    const SizedBox(height: 20),

                    // المميزات
                    if (car.features != null && car.features!.isNotEmpty) ...[
                      const Text(
                        "المميزات",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: car.features!
                            .map((f) => _featureChip(f))
                            .toList(),
                      ),

                      const SizedBox(height: 20),
                    ],

                    // شروط الإيجار
                    const Text(
                      "شروط الإيجار",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _condition(
                      Icons.verified_user,
                      "التأمين ${car.insuranceIncluded ? "مشمول" : "غير مشمول"}",
                    ),
                    _condition(
                      Icons.route,
                      car.unlimitedKm
                          ? "كيلومترات غير محدودة"
                          : "حد ${car.kmLimit} كم/اليوم",
                    ),
                    _condition(
                      Icons.calendar_today,
                      "الحد الأدنى ${car.minRentalDays} ${car.minRentalDays == 1 ? "يوم" : "أيام"}",
                    ),

                    if (car.priceWithDriver != null)
                      _condition(
                        Icons.person,
                        "متوفر مع سائق (${car.priceWithDriver!.toStringAsFixed(0)} ر.س/اليوم)",
                      ),

                    const SizedBox(height: 30),

                    // زر الحجز
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CarBookingScreen(car: car),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "احجز الآن",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _spec(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Text(
            "$label:",
            style: TextStyle(
              color: Colors.white.withOpacity(.7),
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureChip(String feature) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(.4)),
      ),
      child: Text(
        feature,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _condition(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}