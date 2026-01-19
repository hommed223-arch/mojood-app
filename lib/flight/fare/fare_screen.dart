import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_colors.dart';
import '../models/flight_search_model.dart';
import '../models/flight_offer.dart';
import '../models/booking_model.dart';
import '../booking_success_screen.dart';

/// 💰 شاشة الأسعار والحجز
class FareScreen extends StatefulWidget {
  final FlightSearchModel search;
  final FlightOffer offer;

  const FareScreen({
    super.key,
    required this.search,
    required this.offer,
  });

  @override
  State<FareScreen> createState() => _FareScreenState();
}

class _FareScreenState extends State<FareScreen> {
  final supabase = Supabase.instance.client;

  String selectedPayment = 'mada'; // mada, visa, apple_pay
  bool loading = false;

  User? get currentUser => supabase.auth.currentUser;

  /// 💵 حساب السعر الكلي
  double get totalPrice {
    return widget.offer.calculateTotalPrice(
      adults: widget.search.adults,
      children: widget.search.children,
      infants: widget.search.infants,
    );
  }

  /// 🎫 الحجز
  Future<void> _bookFlight() async {
    if (currentUser == null) {
      _showLoginRequired();
      return;
    }

    setState(() => loading = true);

    try {
      // توليد PNR
      final pnr = BookingModel.generatePNR();

      // حفظ في قاعدة البيانات
      final bookingData = {
        'user_id': currentUser!.id,
        'pnr': pnr,
        'from_city': widget.offer.fromCity,
        'to_city': widget.offer.toCity,
        'airline': widget.offer.airline,
        'flight_no': widget.offer.flightNo,
        'date': widget.offer.date,
        'depart_time': widget.offer.departTime,
        'arrive_time': widget.offer.arriveTime,
        'duration': widget.offer.duration,
        'stops': widget.offer.stops,
        'adults': widget.search.adults,
        'children': widget.search.children,
        'infants': widget.search.infants,
        'price': widget.offer.price,
        'total_price': totalPrice,
        'payment_method': selectedPayment,
        'status': 'confirmed',
        'created_at': DateTime.now().toIso8601String(),
      };

      await supabase.from('flights').insert(bookingData);

      if (!mounted) return;

      // الانتقال لشاشة النجاح
      final booking = BookingModel(
        id: pnr,
        userId: currentUser!.id,
        pnr: pnr,
        search: widget.search,
        outboundFlight: widget.offer,
        status: 'confirmed',
        paymentMethod: selectedPayment,
        totalPrice: totalPrice,
        createdAt: DateTime.now(),
        passengers: [],
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingSuccessScreen(booking: booking),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
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
          'تسجيل الدخول مطلوب',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'يجب تسجيل الدخول لإكمال الحجز',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'تفاصيل الحجز',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ======= معلومات الرحلة =======
            _FlightInfoCard(offer: widget.offer),

            const SizedBox(height: 16),

            // ======= تفاصيل الركاب =======
            _PassengersCard(search: widget.search),

            const SizedBox(height: 16),

            // ======= تفاصيل السعر =======
            _PriceBreakdown(
              offer: widget.offer,
              search: widget.search,
              totalPrice: totalPrice,
            ),

            const SizedBox(height: 16),

            // ======= طريقة الدفع =======
            _PaymentSection(
              selected: selectedPayment,
              onChanged: (v) => setState(() => selectedPayment = v),
            ),

            const SizedBox(height: 24),

            // ======= زر الحجز =======
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: loading ? null : _bookFlight,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Text(
                        'تأكيد الحجز - ${totalPrice.toStringAsFixed(0)} ر.س',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ✈️ كارد معلومات الرحلة
class _FlightInfoCard extends StatelessWidget {
  final FlightOffer offer;

  const _FlightInfoCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                offer.airline,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                offer.flightNo,
                style: TextStyle(
                  color: Colors.white.withOpacity(.7),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TimeColumn(
                time: offer.departTime,
                city: offer.fromCity,
                code: offer.fromCode,
              ),
              Column(
                children: [
                  Text(
                    offer.duration,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.7),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(Icons.flight_takeoff, color: AppColors.primary),
                  const SizedBox(height: 6),
                  Text(
                    offer.stopsText,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              _TimeColumn(
                time: offer.arriveTime,
                city: offer.toCity,
                code: offer.toCode,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final String time;
  final String city;
  final String code;

  const _TimeColumn({
    required this.time,
    required this.city,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          code,
          style: TextStyle(
            color: Colors.white.withOpacity(.65),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

/// 👥 كارد الركاب
class _PassengersCard extends StatelessWidget {
  final FlightSearchModel search;

  const _PassengersCard({required this.search});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الركاب',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (search.adults > 0)
            _PassengerRow(
              label: 'بالغين',
              count: search.adults,
            ),
          if (search.children > 0)
            _PassengerRow(
              label: 'أطفال',
              count: search.children,
            ),
          if (search.infants > 0)
            _PassengerRow(
              label: 'رضع',
              count: search.infants,
            ),
        ],
      ),
    );
  }
}

class _PassengerRow extends StatelessWidget {
  final String label;
  final int count;

  const _PassengerRow({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(.7)),
          ),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// 💵 تفصيل السعر
class _PriceBreakdown extends StatelessWidget {
  final FlightOffer offer;
  final FlightSearchModel search;
  final double totalPrice;

  const _PriceBreakdown({
    required this.offer,
    required this.search,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تفاصيل السعر',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (search.adults > 0)
            _PriceRow(
              label: 'بالغين (${search.adults})',
              price: offer.price * search.adults,
            ),
          if (search.children > 0)
            _PriceRow(
              label: 'أطفال (${search.children})',
              price: (offer.price * 0.75) * search.children,
            ),
          if (search.infants > 0)
            _PriceRow(
              label: 'رضع (${search.infants})',
              price: (offer.price * 0.10) * search.infants,
            ),
          const Divider(color: Colors.white24),
          _PriceRow(
            label: 'الإجمالي',
            price: totalPrice,
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double price;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.price,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
            '${price.toStringAsFixed(0)} ر.س',
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
}

/// 💳 طرق الدفع
class _PaymentSection extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _PaymentSection({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'طريقة الدفع',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          _PaymentOption(
            value: 'mada',
            label: 'مدى',
            icon: Icons.credit_card,
            selected: selected,
            onTap: () => onChanged('mada'),
          ),
          const SizedBox(height: 8),
          _PaymentOption(
            value: 'visa',
            label: 'Visa / Mastercard',
            icon: Icons.credit_card,
            selected: selected,
            onTap: () => onChanged('visa'),
          ),
          const SizedBox(height: 8),
          _PaymentOption(
            value: 'apple_pay',
            label: 'Apple Pay',
            icon: Icons.apple,
            selected: selected,
            onTap: () => onChanged('apple_pay'),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final String selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;

    return InkWell(
      onTap: onTap,
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
              color: isSelected
                  ? AppColors.primary
                  : Colors.white.withOpacity(.7),
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
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}