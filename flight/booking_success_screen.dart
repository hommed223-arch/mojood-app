import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'models/booking_model.dart';
import '../presentation/screens/main_layout_screen.dart';

class BookingSuccessScreen extends StatelessWidget {
  final BookingModel booking;

  const BookingSuccessScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 90,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),

                const Text(
                  "تم الحجز بنجاح 🎉",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "رقم الحجز (PNR)",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  booking.pnr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  "${booking.search.fromCity} → ${booking.search.toCity}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "${booking.totalPrice} ر.س",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.85),
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const Spacer(),

                // ✅ عرض الحجوزات
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const MainLayoutScreen(initialIndex: 2),
                        ),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "عرض الحجوزات",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 🏠 العودة للرئيسية
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const MainLayoutScreen(initialIndex: 0),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "العودة للرئيسية",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}