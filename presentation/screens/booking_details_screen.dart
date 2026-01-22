import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class BookingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

  String _formatDate(dynamic value) {
    if (value == null) return "غير محدد";
    final str = value.toString();
    return str.contains('T') ? str.split('T').first : str;
  }

  @override
  Widget build(BuildContext context) {
    final String hotelName = booking['hotel_name'] ?? 'بدون اسم';
    final String bookingId = booking['id']?.toString() ?? '-';

    final DateTime checkIn = DateTime.parse(booking['check_in']);
    final DateTime checkOut = DateTime.parse(booking['check_out']);

    final String roomType = booking['room_type'] ?? 'عادية';
    final int adults = booking['adults'] ?? 1;
    final int children = booking['children'] ?? 0;

    final num totalPrice = booking['total_price'] ?? 0;
    final num pricePerNight = booking['price_per_night'] ?? 0;

    int nights = checkOut.difference(checkIn).inDays;
    if (nights <= 0) nights = 1;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "تفاصيل الحجز",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🏨 اسم الفندق
              Text(
                hotelName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 20),

              // 📄 معلومات الحجز
              _card(
                title: "معلومات الحجز",
                children: [
                  _row("رقم الحجز", bookingId),
                  _row("تاريخ الوصول", _formatDate(checkIn)),
                  _row("تاريخ المغادرة", _formatDate(checkOut)),
                  _row("عدد الليالي", "$nights"),
                ],
              ),

              const SizedBox(height: 16),

              // 🛏️ تفاصيل الغرفة
              _card(
                title: "تفاصيل الغرفة",
                children: [
                  _chipRow(Icons.bed, "نوع الغرفة: $roomType"),
                  const SizedBox(height: 10),
                  _chipRow(Icons.person, "بالغين: $adults"),
                  const SizedBox(height: 10),
                  _chipRow(Icons.child_care, "أطفال: $children"),
                ],
              ),

              const SizedBox(height: 16),

              // 💰 تفاصيل السعر
              _card(
                title: "تفاصيل السعر",
                children: [
                  _row(
                    "السعر لليلة",
                    pricePerNight > 0
                        ? "$pricePerNight ر.س"
                        : "غير متوفر",
                  ),
                  _row("عدد الليالي", "$nights"),
                  const Divider(color: Colors.white24),
                  _row(
                    "الإجمالي",
                    "$totalPrice ر.س",
                    valueStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 🔙 رجوع
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "رجوع",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= Widgets =================

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(.85),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(.7)),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              style: valueStyle ??
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chipRow(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(.45)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }
}