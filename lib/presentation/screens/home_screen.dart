import 'package:flutter/material.dart';
import 'package:mojood_app/presentation/screens/hotels_screen.dart';
import 'package:mojood_app/presentation/screens/my_bookings_screen.dart';
import 'package:mojood_app/flight/flight_home_screen.dart';
import 'package:mojood_app/cars/screens/cars_home_screen.dart';
import 'package:mojood_app/restaurants/screens/restaurants_home_screen.dart';
import '../../core/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,

      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Mojood 3ndna",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= Header =================
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "مرحباً 👋",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "احجز كل شي من مكان واحد",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(.75),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= Categories =================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: .95,
                  children: [
                    _categoryCard(
                      context,
                      icon: Icons.hotel,
                      title: "فنادق",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HotelsScreen(),
                          ),
                        );
                      },
                    ),
                    _categoryCard(
                      context,
                      icon: Icons.flight,
                      title: "طيران",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FlightHomeScreen(),
                          ),
                        );
                      },
                    ),
                    _categoryCard(
                      context,
                      icon: Icons.event,
                      title: "فعاليات",
                      disabled: true,
                    ),
                    _categoryCard(
                      context,
                      icon: Icons.book_online,
                      title: "حجوزاتي",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MyBookingsScreen(),
                          ),
                        );
                      },
                    ),
                    // ✅ تم تفعيل تأجير السيارات
                    _categoryCard(
                      context,
                      icon: Icons.directions_car,
                      title: "تأجير سيارات",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CarsHomeScreen(),
                          ),
                        );
                      },
                    ),
                    // ✅ 🆕 تم تفعيل المطاعم
                    _categoryCard(
                      context,
                      icon: Icons.restaurant,
                      title: "مطاعم",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RestaurantsHomeScreen(),
                          ),
                        );
                      },
                      // disabled: true,  // ❌ احذف هذا السطر
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =======================
  // Category Card (Dark)
  // =======================
  Widget _categoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool disabled = false,
  }) {
    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderDark),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.45),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: disabled
                    ? Colors.white.withOpacity(.08)
                    : AppColors.primary.withOpacity(.18),
                border: Border.all(
                  color: disabled
                      ? Colors.white.withOpacity(.15)
                      : AppColors.primary.withOpacity(.45),
                ),
              ),
              child: Icon(
                icon,
                size: 34,
                color: disabled
                    ? Colors.white38
                    : AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color:
                    disabled ? Colors.white38 : Colors.white,
              ),
            ),
            if (disabled)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  "قريباً",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}