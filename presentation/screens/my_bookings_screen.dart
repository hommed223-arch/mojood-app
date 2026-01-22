import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/app_colors.dart';
import 'booking_details_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'flight_booking_details_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  String? errorMessage;

  // ===== فنادق =====
  List<dynamic> allBookings = [];
  List<dynamic> bookings = [];

  // ===== طيران =====
  List<dynamic> flights = [];
  String? flightsError;

  User? get currentUser => supabase.auth.currentUser;

  @override
  void initState() {
    super.initState();
    if (currentUser == null) {
      loading = false;
    } else {
      fetchAll();
    }
  }

  Future<void> fetchAll() async {
    await Future.wait([
      fetchBookings(),
      fetchFlights(),
    ]);
  }

  // ================= فنادق =================
  Future<void> fetchBookings() async {
    try {
      setState(() => loading = true);

      final response = await supabase
          .from('bookings')
          .select('*, hotels(*)')
          .eq('user_id', currentUser!.id)
          .order('check_in', ascending: false);

      allBookings = response;
      bookings = List<dynamic>.from(allBookings);
      loading = false;
      setState(() {});
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  // ================= طيران =================
  Future<void> fetchFlights() async {
    try {
      final response = await supabase
          .from('flights')
          .select('*')
          .eq('user_id', currentUser!.id)
          .order('created_at', ascending: false);

      flights = response;
      setState(() {});
    } catch (e) {
      setState(() {
        flightsError = e.toString();
        flights = [];
      });
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return "غير محدد";
    final str = value.toString();
    return str.contains('T') ? str.split('T').first : str;
  }

  void shareBooking(Map booking) {
    Share.share("تم حجز فندق عبر تطبيق موجود عندنا 🏨");
  }

  void goLogin() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Center(
          child: ElevatedButton(
            onPressed: goLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text("تسجيل الدخول"),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "حجوزاتي",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : RefreshIndicator(
                onRefresh: fetchAll,
                color: AppColors.primary,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _sectionTitle("الفنادق"),
                    const SizedBox(height: 10),

                    if (bookings.isEmpty)
                      _emptyText("لا توجد حجوزات فنادق"),

                    ...bookings.map(
                      (b) => _hotelCard(b),
                    ),

                    const SizedBox(height: 26),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 18),

                    _sectionTitle("الطيران"),
                    const SizedBox(height: 10),

                    if (flights.isEmpty)
                      _emptyText("لا توجد حجوزات طيران بعد"),

                    ...flights.map(
                      (f) => _flightCard(context, f),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ======================
  // 🏨 Hotel Card
  // ======================
  Widget _hotelCard(dynamic b) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingDetailsScreen(booking: b),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              b['hotel_name'] ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "${_formatDate(b['check_in'])} → ${_formatDate(b['check_out'])}",
              style: TextStyle(
                color: Colors.white.withOpacity(.75),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================
  // ✈️ Flight Card
  // ======================
  Widget _flightCard(BuildContext context, dynamic f) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FlightBookingDetailsScreen(flight: f),
          ),
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            Icon(Icons.flight, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${f['from_city']} → ${f['to_city']}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "PNR: ${f['pnr']}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "${f['price']} ر.س",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _emptyText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(.6),
        ),
      ),
    );
  }
}