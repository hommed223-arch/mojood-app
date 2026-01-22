import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_colors.dart';
import '../models/flight_search_model.dart';
import '../models/booking_model.dart';
import '../booking_success_screen.dart';
import '../fare/fare_screen.dart'; // FareType
import '../passenger/passenger_info_screen.dart';
import '../models/flight_offer.dart';

enum PaymentMethod { card, applePay, sadad, stcPay }

class PaymentScreen extends StatefulWidget {
  final FlightSearchModel search;
  final FlightOffer offer;
  final FareType fare;
  final int totalPrice;

  final List<PassengerData> passengers;
  final String phone;
  final String email;

  const PaymentScreen({
    super.key,
    required this.search,
    required this.offer,
    required this.fare,
    required this.totalPrice,
    required this.passengers,
    required this.phone,
    required this.email,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  PaymentMethod selected = PaymentMethod.card;
  bool loading = false;

  String _methodTitle(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.card:
        return "بطاقة ائتمانية / مصرفية";
      case PaymentMethod.applePay:
        return "أبل باي";
      case PaymentMethod.sadad:
        return "سداد";
      case PaymentMethod.stcPay:
        return "STC Pay";
    }
  }

  String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  Future<void> _confirmPayment() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يجب تسجيل الدخول أولاً")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // 🔐 إنشاء رقم الحجز (PNR)
      final pnr =
          "MJ${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

      // 💾 حفظ بيانات الرحلة
      await supabase.from('flights').insert({
        'user_id': user.id,
        'pnr': pnr,

        'from_city': widget.search.fromCity,
        'to_city': widget.search.toCity,

        'airline': widget.offer.airline,
        'flight_number': widget.offer.flightNo,

        'price': widget.totalPrice,
        'total_price': widget.totalPrice,

        'date': _formatDate(widget.search.departDate),
        'depart_time': widget.offer.departTime,
        'arrive_time': widget.offer.arriveTime,

        'duration': widget.offer.duration,
        'stops': widget.offer.stops,
        'passengers': widget.passengers.length,

        // ✅ الإضافات المهمة
        'payment_method': selected.name,
        'status': 'confirmed',
      });

      // 📦 نموذج داخلي لصفحة النجاح
      final booking = BookingModel(
        pnr: pnr,
        createdAt: DateTime.now(),
        search: widget.search,
        offer: widget.offer,
        fare: widget.fare,
        totalPrice: widget.totalPrice,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingSuccessScreen(booking: booking),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ أثناء الدفع: $e")),
      );
    } finally {
      if (mounted) setState(() => loading = false);
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
            "الدفع",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: PaymentMethod.values.map(_paymentTile).toList(),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: loading ? null : _confirmPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        "ادفع الآن (${widget.totalPrice} ر.س)",
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

  Widget _paymentTile(PaymentMethod m) {
    final isSelected = selected == m;

    return InkWell(
      onTap: () => setState(() => selected = m),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderDark,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _methodTitle(m),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Radio<PaymentMethod>(
              value: m,
              groupValue: selected,
              onChanged: (_) => setState(() => selected = m),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}