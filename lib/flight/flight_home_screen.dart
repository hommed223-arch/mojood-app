import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'flight_results_screen.dart';
import 'models/flight_search_model.dart';
import 'widgets/flight_tabs.dart';
import 'widgets/from_to_card.dart';
import 'widgets/date_card.dart';
import 'widgets/passengers_card.dart';
import 'widgets/search_button.dart';
import 'sheets/calendar_sheet.dart';
import 'sheets/passengers_sheet.dart';

class FlightHomeScreen extends StatefulWidget {
  const FlightHomeScreen({super.key});

  @override
  State<FlightHomeScreen> createState() => _FlightHomeScreenState();
}

class _FlightHomeScreenState extends State<FlightHomeScreen> {
  int tabIndex = 0; // 0 ذهاب فقط - 1 ذهاب وعودة

  String from = "الرياض";
  String to = "جدة";

  DateTime departDate = DateTime.now().add(const Duration(days: 2));
  DateTime? returnDate;

  int adults = 1;
  int children = 0;
  int infants = 0;

  bool get isRoundTrip => tabIndex == 1;

  final List<String> cities = const [
    "الرياض",
    "جدة",
    "الدمام",
    "المدينة",
    "مكة",
    "أبها",
    "تبوك",
    "جازان",
  ];

  String cityCode(String city) {
    switch (city) {
      case "الرياض":
        return "RUH";
      case "جدة":
        return "JED";
      case "الدمام":
        return "DMM";
      case "المدينة":
        return "MED";
      case "مكة":
        return "MKK";
      case "أبها":
        return "AHB";
      case "تبوك":
        return "TUU";
      case "جازان":
        return "GIZ";
      default:
        return "XXX";
    }
  }

  // =============================
  // 🏙️ اختيار المدينة
  // =============================
  Future<void> pickCity({required bool pickingFrom}) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.bgDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Center(
                child: Text(
                  "اختر المدينة",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...cities.map(
                (c) => ListTile(
                  title: Text(
                    c,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onTap: () => Navigator.pop(context, c),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null) return;

    setState(() {
      if (pickingFrom) {
        from = selected;
        if (from == to) {
          to = cities.firstWhere((x) => x != from);
        }
      } else {
        to = selected;
        if (to == from) {
          from = cities.firstWhere((x) => x != to);
        }
      }
    });
  }

  // =============================
  // 📅 اختيار التواريخ
  // =============================
  Future<void> pickDates() async {
    final result = await CalendarSheet.show(
      context,
      isRoundTrip: isRoundTrip,
      initialDepart: departDate,
      initialReturn: returnDate,
    );

    if (result == null) return;

    setState(() {
      departDate = result.depart;
      returnDate = isRoundTrip ? result.ret : null;
    });
  }

  // =============================
  // 👥 اختيار الركاب
  // =============================
  Future<void> pickPassengers() async {
    final result = await PassengersSheet.show(
      context,
      adults: adults,
      children: children,
      infants: infants,
    );

    if (result == null) return;

    setState(() {
      adults = result.adults;
      children = result.children;
      infants = result.infants;
    });
  }

  // =============================
  // 🔍 البحث
  // =============================
  void onSearch() {
    final model = FlightSearchModel(
      isRoundTrip: isRoundTrip,
      fromCity: from,
      toCity: to,
      fromCode: cityCode(from),
      toCode: cityCode(to),
      departDate: departDate,
      returnDate: isRoundTrip ? returnDate : null,
      adults: adults,
      children: children,
      infants: infants,
      cabin: "Economy",
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlightResultsScreen(search: model),
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
          "الطيران",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FlightTabs(
              selectedIndex: tabIndex,
              onChanged: (i) {
                setState(() {
                  tabIndex = i;
                  if (!isRoundTrip) returnDate = null;
                });
              },
            ),

            const SizedBox(height: 16),

            FromToCard(
              from: from,
              to: to,
              onSwap: () => setState(() {
                final temp = from;
                from = to;
                to = temp;
              }),
              onPickFrom: () => pickCity(pickingFrom: true),
              onPickTo: () => pickCity(pickingFrom: false),
            ),

            const SizedBox(height: 14),

            DateCard(
              isRoundTrip: isRoundTrip,
              departDate: departDate,
              returnDate: returnDate,
              onPickDates: pickDates,
            ),

            const SizedBox(height: 14),

            PassengersCard(
              adults: adults,
              children: children,
              infants: infants,
              onPickPassengers: pickPassengers,
            ),

            const SizedBox(height: 22),

            SearchButton(
              enabled: from != to,
              onPressed: onSearch,
            ),
          ],
        ),
      ),
    );
  }
}