import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import '../../core/app_colors.dart';

class BookingScreen extends StatefulWidget {
  final String hotelId;
  final String hotelName;
  final num price; // سعر الليلة الأساسي

  const BookingScreen({
    super.key,
    required this.hotelId,
    required this.hotelName,
    required this.price,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  DateTime? checkIn;
  DateTime? checkOut;

  int adults = 1;
  int children = 0;
  bool loading = false;

  final List<String> roomTypes = ["عادية", "ديلوكس", "جناح"];
  String selectedRoomType = "عادية";

  User? get currentUser => supabase.auth.currentUser;

  int get nights {
    if (checkIn == null || checkOut == null) return 0;
    final diff = checkOut!.difference(checkIn!).inDays;
    return diff <= 0 ? 0 : diff;
  }

  double get roomMultiplier {
    switch (selectedRoomType) {
      case "ديلوكس":
        return 1.25;
      case "جناح":
        return 1.6;
      default:
        return 1.0;
    }
  }

  double get pricePerNight {
    final base = widget.price.toDouble() * roomMultiplier;
    final extraAdults = (adults - 1).clamp(0, 99);
    final adultsExtra = extraAdults * (base * 0.35);
    final childrenExtra = children * (base * 0.20);
    return base + adultsExtra + childrenExtra;
  }

  double get totalPrice => nights <= 0 ? 0 : pricePerNight * nights;

  bool _requireLogin() {
    if (currentUser == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: const Text("تسجيل الدخول مطلوب",
              style: TextStyle(color: Colors.white)),
          content: const Text(
            "لازم تسجل دخول عشان تكمل الحجز",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text("تسجيل الدخول"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
          ],
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> pickDate(bool isCheckIn) async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate:
          isCheckIn ? (checkIn ?? now) : (checkOut ?? now.add(const Duration(days: 1))),
      firstDate:
          isCheckIn ? now : (checkIn ?? now).add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          checkIn = picked;
          if (checkOut != null && !checkOut!.isAfter(checkIn!)) {
            checkOut = null;
          }
        } else {
          checkOut = picked;
        }
      });
    }
  }

  Future<void> bookHotel() async {
    if (!_requireLogin()) return;
    if (checkIn == null || checkOut == null || nights <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تحقق من التواريخ")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await supabase.from('bookings').insert({
        'hotel_id': widget.hotelId,
        'hotel_name': widget.hotelName,
        'user_id': currentUser!.id,
        'user_name': currentUser!.email,
        'check_in': checkIn!.toIso8601String(),
        'check_out': checkOut!.toIso8601String(),
        'adults': adults,
        'children': children,
        'room_type': selectedRoomType,
        'price_per_night': pricePerNight,
        'total_price': totalPrice,
      });

      if (!mounted) return;
      setState(() => loading = false);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: const Text(
            "تم الحجز بنجاح 🎉",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            "الفندق: ${widget.hotelName}\n"
            "الغرفة: $selectedRoomType\n"
            "الليالي: $nights\n"
            "بالغين: $adults | أطفال: $children\n"
            "الإجمالي: ${totalPrice.toStringAsFixed(0)} ريال",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("حسناً"),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("خطأ: $e")));
    }
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

  Widget _counter({
    required String title,
    required String subtitle,
    required int value,
    required VoidCallback onPlus,
    required VoidCallback onMinus,
  }) {
    return _card(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style:
                        TextStyle(color: Colors.white.withOpacity(.65))),
              ],
            ),
          ),
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.primary,
          ),
          Text(
            "$value",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "إتمام الحجز",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hotelName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "السعر الأساسي: ${widget.price} ريال / ليلة",
                    style:
                        TextStyle(color: Colors.white.withOpacity(.7)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _counter(
              title: "البالغين",
              subtitle: "12 سنة وفوق",
              value: adults,
              onPlus: () => setState(() => adults++),
              onMinus: () => setState(() {
                if (adults > 1) adults--;
              }),
            ),
            const SizedBox(height: 12),
            _counter(
              title: "الأطفال",
              subtitle: "أقل من 12 سنة",
              value: children,
              onPlus: () => setState(() => children++),
              onMinus: () => setState(() {
                if (children > 0) children--;
              }),
            ),
            const SizedBox(height: 16),

            _card(
              child: DropdownButtonFormField<String>(
                value: selectedRoomType,
                dropdownColor: AppColors.cardDark,
                decoration: const InputDecoration(
                  labelText: "نوع الغرفة",
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                items: roomTypes
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e,
                            style:
                                const TextStyle(color: Colors.white)),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => selectedRoomType = v!),
              ),
            ),
            const SizedBox(height: 16),

            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("ملخص السعر",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    "السعر / ليلة: ${pricePerNight.toStringAsFixed(0)} ر.س",
                    style:
                        TextStyle(color: Colors.white.withOpacity(.75)),
                  ),
                  Text(
                    "عدد الليالي: $nights",
                    style:
                        TextStyle(color: Colors.white.withOpacity(.75)),
                  ),
                  const Divider(color: Colors.white24),
                  Text(
                    "الإجمالي: ${totalPrice.toStringAsFixed(0)} ر.س",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: loading ? null : bookHotel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text(
                        "تأكيد الحجز",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}