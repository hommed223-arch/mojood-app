import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/app_colors.dart';
import 'flight_booking_details_screen.dart';

class FlightMyBookingsScreen extends StatefulWidget {
  const FlightMyBookingsScreen({super.key});

  @override
  State<FlightMyBookingsScreen> createState() =>
      _FlightMyBookingsScreenState();
}

class _FlightMyBookingsScreenState extends State<FlightMyBookingsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  bool loading = true;
  String? error;
  List<Map<String, dynamic>> flights = [];

  @override
  void initState() {
    super.initState();
    fetchFlights();
  }

  Future<void> fetchFlights() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        setState(() {
          flights = [];
          loading = false;
        });
        return;
      }

      final res = await supabase
          .from('flights')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        flights = List<Map<String, dynamic>>.from(res);
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  String _formatDate(String? value) {
    if (value == null) return "-";
    return value.contains('T') ? value.split('T').first : value;
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

  @override
  Widget build(BuildContext context) {
    // ===== Loading =====
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ===== Error =====
    if (error != null) {
      return Center(
        child: Text(
          "خطأ: $error",
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    // ===== Empty =====
    if (flights.isEmpty) {
      return const Center(
        child: Text(
          "لا توجد حجوزات طيران بعد ✈️",
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    // ===== List =====
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: flights.length,
      itemBuilder: (context, i) {
        final f = flights[i];
        final status = (f['status'] ?? 'pending').toString();

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FlightBookingDetailsScreen(flight: f),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Row(
              children: [
                Icon(Icons.flight_takeoff, color: AppColors.primary),
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
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${f['airline']} • ${_formatDate(f['date'])}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(.7),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withOpacity(.15),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: _statusColor(status),
                          ),
                        ),
                        child: Text(
                          _statusText(status),
                          style: TextStyle(
                            color: _statusColor(status),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Text(
                  "${f['total_price'] ?? f['price']} ر.س",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}