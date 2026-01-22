import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_colors.dart';
import '../models/car_model.dart';
import '../models/rental_search_model.dart';
import '../models/car_booking_model.dart';
import 'car_booking_success_screen.dart';

class CarBookingReviewScreen extends StatefulWidget {
  final CarModel car;
  final RentalSearchModel search;
  final Map<String, double> extras;
  final double extrasTotal;

  const CarBookingReviewScreen({
    super.key,
    required this.car,
    required this.search,
    required this.extras,
    required this.extrasTotal,
  });

  @override
  State<CarBookingReviewScreen> createState() => _CarBookingReviewScreenState();
}

class _CarBookingReviewScreenState extends State<CarBookingReviewScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  String _title = "السيد";
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _promoCodeController = TextEditingController();

  String _selectedPayment = 'apple_pay';
  bool _loading = false;

  User? get currentUser => supabase.auth.currentUser;

  double get basePrice => widget.car.pricePerDay * widget.search.rentalDays;
  double get contractFee => basePrice * 0.0833;
  double get subtotal => basePrice + contractFee + widget.extrasTotal;
  double get vat => subtotal * 0.15;
  double get totalPrice => subtotal + vat;

  @override
  void initState() {
    super.initState();
    if (currentUser != null) {
      _emailController.text = currentUser!.email ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _idNumberController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final months = ["يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو",
      "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"];
    return "${months[date.month - 1]} ${date.day}";
  }

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء تسجيل الدخول أولاً")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final bookingRef = CarBookingModel.generateBookingRef();
      await supabase.from('car_bookings').insert({
        'car_id': widget.car.id,
        'user_id': currentUser!.id,
        'car_brand': widget.car.brand,
        'car_model': widget.car.model,
        'car_year': widget.car.year,
        'pickup_date': widget.search.pickupDate.toIso8601String().split('T').first,
        'return_date': widget.search.returnDate.toIso8601String().split('T').first,
        'rental_days': widget.search.rentalDays,
        'pickup_city': widget.search.pickupLocation,
        'daily_price': widget.car.pricePerDay,
        'total_price': totalPrice,
        'payment_method': _selectedPayment,
        'status': 'confirmed',
        'booking_ref': bookingRef,
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CarBookingSuccessScreen(
            bookingRef: bookingRef,
            car: widget.car,
            search: widget.search,
            totalPrice: totalPrice,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ: $e")));
    } finally {
      if (mounted) setState(() => _loading = false);
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text("مراجعة وحجز",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildBookingSummary(),
              const SizedBox(height: 24),
              _buildDriverDetails(),
              const SizedBox(height: 24),
              _buildPromoCode(),
              const SizedBox(height: 24),
              _buildPriceDetails(),
              const SizedBox(height: 24),
              _buildPaymentMethods(),
              const SizedBox(height: 24),
              _buildBookingButtons(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80, height: 60,
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: widget.car.imageUrl != null
                    ? Image.network(widget.car.imageUrl!, fit: BoxFit.contain)
                    : Icon(Icons.directions_car, color: Colors.white38),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.car.fullName,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
                    Text("أو سيارة مماثلة",
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                    Text("${widget.search.rentalDays} يوم إيجار",
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLocationRow("الاستلام", widget.search.pickupLocation,
            "${_formatDate(widget.search.pickupDate)}, ${widget.search.pickupTime}"),
          const SizedBox(height: 12),
          _buildLocationRow("التسليم", widget.search.returnLocation ?? widget.search.pickupLocation,
            "${_formatDate(widget.search.returnDate)}, ${widget.search.returnTime}"),
          const SizedBox(height: 16),
          Divider(color: AppColors.borderDark),
          const SizedBox(height: 12),
          const Text("ملخص حجزك", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _buildSummaryRow("رحلة لمدة ${widget.search.rentalDays} يوم مقابل", "${basePrice.toStringAsFixed(2)} ر.س"),
          _buildSummaryRow("رسوم العقد", "${contractFee.toStringAsFixed(2)} ر.س"),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String label, String location, String datetime) {
    return Row(
      children: [
        Icon(Icons.location_on, color: Colors.white54, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
              Text(location, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              Text(datetime, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13))),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildDriverDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("تفاصيل السائق", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        _buildDropdown("اللقب", _title, ["السيد", "السيدة"], (v) => setState(() => _title = v!)),
        const SizedBox(height: 12),
        _buildTextField("الاسم الأول", _firstNameController, required: true),
        const SizedBox(height: 12),
        _buildTextField("الاسم الأخير", _lastNameController, required: true),
        const SizedBox(height: 12),
        _buildTextField("البريد الإلكتروني", _emailController, required: true, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: const Text("966+", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField("رقم الهاتف", _phoneController, required: true, keyboardType: TextInputType.phone)),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField("رقم الهوية / الإقامة / جواز السفر", _idNumberController, required: true),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: AppColors.cardDark,
        decoration: InputDecoration(labelText: label, labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)), border: InputBorder.none),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool required = false, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      validator: required ? (v) => v == null || v.isEmpty ? "مطلوب" : null : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderDark)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.borderDark)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
      ),
    );
  }

  Widget _buildPromoCode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("كود الخصم", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Row(
            children: [
              Expanded(child: Text("إضافة كود خصم", style: TextStyle(color: Colors.white.withOpacity(0.8)))),
              Icon(Icons.arrow_back_ios, color: Colors.white38, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("تفاصيل السعر", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        _buildPriceRow("السعر الأساسي", "${basePrice.toStringAsFixed(2)} ر.س"),
        _buildPriceRow("رسوم العقد", "${contractFee.toStringAsFixed(2)} ر.س"),
        _buildPriceRow("القيمة المضافة (15%)", "${vat.toStringAsFixed(2)} ر.س"),
        const SizedBox(height: 12),
        Divider(color: AppColors.borderDark),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("إجمالي المبلغ المستحق", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            Text("${totalPrice.toStringAsFixed(2)} ر.س", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7))),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPaymentIcon("apple_pay", Icons.apple),
          _buildPaymentIcon("visa", Icons.credit_card),
          _buildPaymentIcon("mastercard", Icons.credit_card),
          _buildPaymentIcon("mada", Icons.account_balance),
        ],
      ),
    );
  }

  Widget _buildPaymentIcon(String method, IconData icon) {
    final isSelected = _selectedPayment == method;
    return InkWell(
      onTap: () => setState(() => _selectedPayment = method),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
        ),
        child: Icon(icon, color: isSelected ? AppColors.primary : Colors.white54, size: 28),
      ),
    );
  }

  Widget _buildBookingButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _loading ? null : _confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _loading
                ? const CircularProgressIndicator(color: Colors.white)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("احجز عبر ", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      Icon(Icons.apple, color: Colors.white),
                      Text("Pay", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _loading ? null : _confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("احجز الآن", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    );
  }
}