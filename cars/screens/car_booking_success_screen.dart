import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../models/car_model.dart';
import '../models/rental_search_model.dart';

class CarBookingSuccessScreen extends StatelessWidget {
  final String bookingRef;
  final CarModel car;
  final RentalSearchModel search;
  final double totalPrice;

  const CarBookingSuccessScreen({
    super.key,
    required this.bookingRef,
    required this.car,
    required this.search,
    required this.totalPrice,
  });

  String _formatDate(DateTime date) {
    final months = [
      "يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو",
      "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // أيقونة النجاح
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                ),

                const SizedBox(height: 24),

                // العنوان
                const Text(
                  "تم الحجز بنجاح! 🎉",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "شكراً لك، تم تأكيد حجزك",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 32),

                // رقم الحجز
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "رقم الحجز",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bookingRef,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // تفاصيل الحجز
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    children: [
                      // السيارة
                      Row(
                        children: [
                          Container(
                            width: 70,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.bgDark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: car.imageUrl != null
                                ? Image.network(car.imageUrl!, fit: BoxFit.contain)
                                : const Icon(Icons.directions_car, color: Colors.white38),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  car.fullName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  "أو سيارة مماثلة",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Divider(color: AppColors.borderDark),
                      const SizedBox(height: 20),

                      // الاستلام
                      _buildInfoRow(
                        icon: Icons.location_on,
                        title: "الاستلام",
                        value: search.pickupLocation,
                        subtitle: "${_formatDate(search.pickupDate)} - ${search.pickupTime}",
                      ),

                      const SizedBox(height: 16),

                      // التسليم
                      _buildInfoRow(
                        icon: Icons.flag,
                        title: "التسليم",
                        value: search.returnLocation ?? search.pickupLocation,
                        subtitle: "${_formatDate(search.returnDate)} - ${search.returnTime}",
                      ),

                      const SizedBox(height: 16),

                      // المدة
                      _buildInfoRow(
                        icon: Icons.calendar_today,
                        title: "مدة الإيجار",
                        value: "${search.rentalDays} ${search.rentalDays == 1 ? 'يوم' : 'أيام'}",
                      ),

                      const SizedBox(height: 20),
                      Divider(color: AppColors.borderDark),
                      const SizedBox(height: 20),

                      // الإجمالي
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "الإجمالي المدفوع",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "${totalPrice.toStringAsFixed(2)} ر.س",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ملاحظات
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "احتفظ برقم الحجز وأحضر هويتك ورخصة القيادة عند الاستلام",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // الأزرار
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // مشاركة الحجز
                    },
                    icon: const Icon(Icons.share, color: Colors.white),
                    label: const Text(
                      "مشاركة الحجز",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: AppColors.borderDark),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // الرجوع للرئيسية
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "العودة للرئيسية",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}