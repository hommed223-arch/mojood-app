import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../models/car_model.dart';
import '../models/rental_search_model.dart';
import 'car_booking_review_screen.dart';

class CarExtrasScreen extends StatefulWidget {
  final CarModel car;
  final RentalSearchModel search;

  const CarExtrasScreen({
    super.key,
    required this.car,
    required this.search,
  });

  @override
  State<CarExtrasScreen> createState() => _CarExtrasScreenState();
}

class _CarExtrasScreenState extends State<CarExtrasScreen> {
  // الإضافات المحددة
  final Map<String, bool> _selectedExtras = {
    'child_seat': false,
    'unlimited_km': false,
    'extra_protection': false,
    'gcc_permission': false,
  };

  // أسعار الإضافات (لكل يوم)
  final Map<String, double> _extrasPrices = {
    'child_seat': 28.75,
    'unlimited_km': 37.95,
    'extra_protection': 28.75,
    'gcc_permission': 115.00,
  };

  double get basePrice => widget.car.pricePerDay * widget.search.rentalDays;

  double get extrasTotal {
    double total = 0;
    _selectedExtras.forEach((key, selected) {
      if (selected) {
        total += (_extrasPrices[key] ?? 0) * widget.search.rentalDays;
      }
    });
    return total;
  }

  double get totalPrice => basePrice + extrasTotal;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "باقة الإضافات",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // قائمة الإضافات
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  "الإضافات",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // مقعد الطفل
                _buildExtraCard(
                  key: 'child_seat',
                  title: "مقعد الطفل",
                  subtitle: "مقعد لسلامة طفلك",
                  pricePerDay: _extrasPrices['child_seat']!,
                ),

                const SizedBox(height: 16),

                // كيلومترات مفتوح
                _buildExtraCard(
                  key: 'unlimited_km',
                  title: "كيلومترات مفتوح",
                  subtitle: "تجول بلا قيود !",
                  pricePerDay: _extrasPrices['unlimited_km']!,
                ),

                const SizedBox(height: 16),

                // حماية إضافية
                _buildExtraCard(
                  key: 'extra_protection',
                  title: "حماية اضافية",
                  subtitle: "التأمين الإضافي دون نسبة تحمل",
                  pricePerDay: _extrasPrices['extra_protection']!,
                ),

                const SizedBox(height: 16),

                // تفويض دول مجلس التعاون
                _buildExtraCard(
                  key: 'gcc_permission',
                  title: "تفويض دول مجلس التعاون",
                  subtitle: "سيارات مرخّصة ومؤمنة بعقود موحدة",
                  pricePerDay: _extrasPrices['gcc_permission']!,
                ),

                // مساحة للشريط السفلي
                const SizedBox(height: 100),
              ],
            ),

            // الشريط السفلي
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(),
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // 📦 كارت الإضافة
  // =============================
  Widget _buildExtraCard({
    required String key,
    required String title,
    required String subtitle,
    required double pricePerDay,
  }) {
    final isSelected = _selectedExtras[key] ?? false;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedExtras[key] = !isSelected;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderDark,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.white38,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : null,
            ),

            const SizedBox(width: 16),

            // المعلومات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "ر.س",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        pricePerDay.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        " لـ 1 يوم",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // 📊 الشريط السفلي
  // =============================
  Widget _buildBottomBar() {
    final hasExtras = _selectedExtras.values.any((v) => v);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        border: Border(
          top: BorderSide(color: AppColors.borderDark),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر المتابعة
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                // جمع الإضافات المحددة
                final selectedExtras = <String, double>{};
                _selectedExtras.forEach((key, selected) {
                  if (selected) {
                    selectedExtras[key] = _extrasPrices[key]! * widget.search.rentalDays;
                  }
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CarBookingReviewScreen(
                      car: widget.car,
                      search: widget.search,
                      extras: selectedExtras,
                      extrasTotal: extrasTotal,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                hasExtras ? "متابعة" : "متابعه بدون إضافات",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // السعر
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "السعر لـ ${widget.search.rentalDays} ${widget.search.rentalDays == 1 ? 'يوم' : 'أيام'}",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    "ر.س",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    totalPrice.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}