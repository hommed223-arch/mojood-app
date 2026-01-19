import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_colors.dart';
import 'models/flight_search_model.dart';
import 'models/flight_offer.dart';
import 'fare/fare_screen.dart';

class FlightResultsScreen extends StatelessWidget {
  final FlightSearchModel search;

  const FlightResultsScreen({super.key, required this.search});

  String _fmt(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  /// =====================
  /// Fetch Flights
  /// =====================
  Future<List<FlightOffer>> _fetchFlights() async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('flights_catalog') // جدول الرحلات المتاحة
        .select('*')
        .eq('from_city', search.fromCity)
        .eq('to_city', search.toCity)
        .eq(
          'date',
          search.departDate.toIso8601String().split('T').first,
        )
        .order('price', ascending: true);

    final list = (response as List).cast<Map<String, dynamic>>();
    return list.map(FlightOffer.fromDb).toList();
  }

  @override
  Widget build(BuildContext context) {
    final header = "${search.fromCode} ← ${search.toCode}";

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                header,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              Text(
                "${search.isRoundTrip ? "ذهاب وعودة" : "ذهاب فقط"} • ${_fmt(search.departDate)}",
                style: TextStyle(
                  color: Colors.white.withOpacity(.75),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        body: Column(
          children: [
            // ====== Summary ======
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${search.fromCity} (${search.fromCode}) → ${search.toCity} (${search.toCode})",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${search.totalPassengers} ركاب",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.75),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ====== Results ======
            Expanded(
              child: FutureBuilder<List<FlightOffer>>(
                future: _fetchFlights(),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snap.hasError) {
                    return Center(
                      child: Text(
                        "خطأ: ${snap.error}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final results = snap.data ?? [];

                  if (results.isEmpty) {
                    return const Center(
                      child: Text(
                        "لا توجد رحلات مطابقة للبحث",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: results.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final r = results[index];
                      return _FlightCard(
                        offer: r,
                        onPick: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FareScreen(search: search, offer: r),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =====================
/// Flight Card
/// =====================
class _FlightCard extends StatelessWidget {
  final FlightOffer offer;
  final VoidCallback onPick;

  const _FlightCard({
    required this.offer,
    required this.onPick,
  });

  String stopsText() {
    if (offer.stops == 0) return "بدون توقف";
    if (offer.stops == 1) return "توقف واحد";
    return "${offer.stops} توقفات";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              _chip(offer.airline),
              const SizedBox(width: 10),
              Text(
                offer.flightNo,
                style: TextStyle(
                  color: Colors.white.withOpacity(.8),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                "${offer.price} ر.س",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timeCol(offer.departTime, "إقلاع"),
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
                  Icon(
                    Icons.flight_takeoff,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stopsText(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              _timeCol(offer.arriveTime, "وصول"),
            ],
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onPick,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                "اختيار",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeCol(String time, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(.65),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primary.withOpacity(.35),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}