import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_colors.dart';
import '../../core/core.dart';
import '../models/car_model.dart';
import '../models/car_booking_model.dart';

class CarBookingScreen extends StatefulWidget {
  final CarModel car;

  const CarBookingScreen({super.key, required this.car});

  @override
  State<CarBookingScreen> createState() => _CarBookingScreenState();
}

class _CarBookingScreenState extends State<CarBookingScreen> {
  final supabase = Supabase.instance.client;

  DateTime? pickupDate;
  DateTime? returnDate;
  bool withDriver = false;
  String selectedPayment = 'mada';
  bool loading = false;

  User? get currentUser => supabase.auth.currentUser;

  int get rentalDays {
    if (pickupDate == null || returnDate == null) return 0;
    final diff = returnDate!.difference(pickupDate!).inDays;
    return diff <= 0 ? 0 : diff;
  }

  double get dailyPrice {
    if (withDriver && widget.car.priceWithDriver != null) {
      return widget.car.priceWithDriver!;
    }
    return widget.car.pricePerDay;
  }

  double get totalPrice => rentalDays * dailyPrice;

  Future<void> pickDate(bool isPickup) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isPickup
          ? (pickupDate ?? now)
          : (returnDate ?? now.add(Duration(days: widget.car.minRentalDays))),
      firstDate: isPickup
          ? now
          : (pickupDate ?? now).add(Duration(days: widget.car.minRentalDays)),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isPickup) {
          pickupDate = picked;
          // إعادة تعيين تاريخ التسليم إذا كان قبل الاستلام
          if (returnDate != null && !returnDate!.isAfter(pickupDate!)) {
            returnDate = null;
          }
        } else {
          returnDate = picked;
        }
      });
    }
  }

  Future<void> confirmBooking() async {
    if (currentUser == null) {
      _showLoginRequired();
      return;
    }

    if (pickupDate == null || returnDate == null || rentalDays == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء تحديد تواريخ صحيحة")),
      );
      return;
    }

    if (rentalDays < widget.car.minRentalDays) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "الحد الأدنى للإيجار ${widget.car.minRentalDays} ${widget.car.minRentalDays == 1 ? "يوم" : "أيام"}",
          ),
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final bookingRef = CarBookingModel.generateBookingRef();

      await supabase.from('car_bookings').insert({
        'car_id': widget.car.id,
        'user_id': currentUser!.id,
        'car_brand': widget.car.brand,
        'car_model': widget.car.model,
        'car_year': widget.car.year,
        'pickup_date': pickupDate!.toIso8601String().split('T').first,
        'return_date': returnDate!.toIso8601String().split('T').first,
        'rental_days': rentalDays,
        'pickup_city': widget.car.city,
        'return_city': widget.car.city,
        'with_driver': withDriver,
        'driver_price':
            withDriver ? widget.car.priceWithDriver : null,
        'daily_price': dailyPrice,
        'total_price': totalPrice,
        'payment_method': selectedPayment,
        'status': 'confirmed',
        'booking_ref': bookingRef,
      });

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: const Text(
            "تم الحجز بنجاح 🎉",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "رقم الحجز: $bookingRef",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "السيارة: ${widget.car.fullName}",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Text(
                "المدة: $rentalDays ${rentalDays == 1 ? "يوم" : "أيام"}",
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Text(
                "الإجمالي: ${totalPrice.toStringAsFixed(0)} ر.س",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // أغلق الـ Dialog
                Navigator.pop(context); // ارجع للتفاصيل
                Navigator.pop(context); // ارجع للقائمة
              },
              child: const Text("حسناً"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showLoginRequired() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text(
          "تسجيل الدخول مطلوب",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "يجب تسجيل الدخول لإكمال الحجز",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("حسناً"),
          ),
        ],
      ),
    );
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
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "إتمام الحجز",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات السيارة
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.car.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.car.city,
                      style: TextStyle(color: Colors.white.withOpacity(.7)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // التواريخ
              _card(
                child: Column(
                  children: [
                    _dateButton(
                      label: "تاريخ الاستلام",
                      date: pickupDate,
                      onTap: () => pickDate(true),
                    ),
                    const SizedBox(height: 12),
                    _dateButton(
                      label: "تاريخ التسليم",
                      date: returnDate,
                      onTap: () => pickDate(false),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // خيار السائق
              if (widget.car.priceWithDriver != null)
                _card(
                  child: CheckboxListTile(
                    title: const Text(
                      "مع سائق",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "${widget.car.priceWithDriver!.toStringAsFixed(0)} ر.س/اليوم",
                      style: TextStyle(color: AppColors.primary),
                    ),
                    value: withDriver,
                    activeColor: AppColors.primary,
                    onChanged: (v) => setState(() => withDriver = v!),
                  ),
                ),

              const SizedBox(height: 16),

              // ملخص السعر
              if (rentalDays > 0)
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ملخص السعر",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _priceRow(
                        "السعر اليومي",
                        "${dailyPrice.toStringAsFixed(0)} ر.س",
                      ),
                      _priceRow(
                        "عدد الأيام",
                        "$rentalDays ${rentalDays == 1 ? "يوم" : "أيام"}",
                      ),
                      const Divider(color: Colors.white24),
                      _priceRow(
                        "الإجمالي",
                        "${totalPrice.toStringAsFixed(0)} ر.س",
                        isTotal: true,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // طريقة الدفع
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "طريقة الدفع",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _paymentOption('mada', 'مدى', Icons.credit_card),
                    const SizedBox(height: 8),
                    _paymentOption('visa', 'Visa/Mastercard', Icons.credit_card),
                    const SizedBox(height: 8),
                    _paymentOption('apple_pay', 'Apple Pay', Icons.apple),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // زر التأكيد
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: loading ? null : confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Text(
                          rentalDays > 0
                              ? "تأكيد الحجز - ${totalPrice.toStringAsFixed(0)} ر.س"
                              : "اختر التواريخ",
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
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

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: child,
    );
  }

  Widget _dateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(.7),
                fontSize: 15,
              ),
            ),
            Text(
              date != null
                  ? DateFormatter.formatDateArabic(date)
                  : "اختر التاريخ",
              style: TextStyle(
                color: date != null ? Colors.white : Colors.white54,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(isTotal ? 1 : .7),
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOption(String value, String label, IconData icon) {
    final isSelected = selectedPayment == value;

    return InkWell(
      onTap: () => setState(() => selectedPayment = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.white.withOpacity(.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color:
                  isSelected ? AppColors.primary : Colors.white.withOpacity(.7),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}