import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class FlightBookingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> flight;

  const FlightBookingDetailsScreen({
    super.key,
    required this.flight,
  });

  String _formatDate(String? value) {
    if (value == null) return "-";
    return value.contains('T') ? value.split('T').first : value;
  }

  String _statusText(String status) {
    switch (status) {
      case 'confirmed':
        return "مؤكدة";
      case 'cancelled':
        return "ملغاة";
      default:
        return "قيد المعالجة";
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fromCity = flight['from_city'] ?? '';
    final toCity = flight['to_city'] ?? '';
    final airline = flight['airline'] ?? '';
    final date = _formatDate(flight['date']);
    final departTime = flight['depart_time'] ?? '—';
    final arriveTime = flight['arrive_time'] ?? '—';
    final duration = flight['duration'] ?? '—';
    final stops = flight['stops'] ?? 0;
    final pnr = flight['pnr'] ?? '—';
    final price = flight['total_price'] ?? flight['price'] ?? 0;
    final status = (flight['status'] ?? 'pending').toString();
    final paymentMethod = flight['payment_method'];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "تفاصيل حجز الطيران",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _headerRoute(fromCity, toCity),

            // ✅ Status
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _statusColor(status).withOpacity(.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _statusColor(status)),
              ),
              child: Center(
                child: Text(
                  _statusText(status),
                  style: TextStyle(
                    color: _statusColor(status),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            _infoCard(
              icon: Icons.flight,
              title: "شركة الطيران",
              value: airline,
            ),
            _infoCard(
              icon: Icons.calendar_today,
              title: "تاريخ الرحلة",
              value: date,
            ),
            _infoCard(
              icon: Icons.schedule,
              title: "الوقت",
              custom: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("الإقلاع: $departTime", style: _valueStyle()),
                  const SizedBox(height: 4),
                  Text("الوصول: $arriveTime", style: _valueStyle()),
                ],
              ),
            ),
            _infoCard(
              icon: Icons.timelapse,
              title: "مدة الرحلة",
              value: duration,
            ),
            _infoCard(
              icon: Icons.alt_route,
              title: "التوقفات",
              value: stops == 0 ? "بدون توقف" : "$stops توقف",
            ),
            _infoCard(
              icon: Icons.confirmation_number,
              title: "رقم الحجز (PNR)",
              custom: Text(
                pnr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
            if (paymentMethod != null)
              _infoCard(
                icon: Icons.credit_card,
                title: "طريقة الدفع",
                value: paymentMethod.toString().toUpperCase(),
              ),
            _infoCard(
              icon: Icons.payments,
              title: "الإجمالي",
              custom: Text(
                "$price ر.س",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================
  // Header Route
  // ======================
  Widget _headerRoute(String from, String to) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            from,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.flight_takeoff, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(
            to,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ======================
  // Info Card
  // ======================
  Widget _infoCard({
    required IconData icon,
    required String title,
    String? value,
    Widget? custom,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.65),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                custom ??
                    Text(
                      value ?? '',
                      style: _valueStyle(),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _valueStyle() {
    return const TextStyle(
      color: Colors.white,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );
  }
}