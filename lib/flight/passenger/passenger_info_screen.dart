import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

import '../models/flight_search_model.dart';
import '../fare/fare_screen.dart';
import '../review/review_booking_screen.dart';
import '../models/flight_offer.dart';

import 'widgets/passenger_form_card.dart';
import 'widgets/primary_button_bar.dart';

class PassengerInfoScreen extends StatefulWidget {
  final FlightSearchModel search;
  final FlightOffer offer;
  final FareType fare;
  final int totalPrice;

  const PassengerInfoScreen({
    super.key,
    required this.search,
    required this.offer,
    required this.fare,
    required this.totalPrice,
  });

  @override
  State<PassengerInfoScreen> createState() => _PassengerInfoScreenState();
}

class _PassengerInfoScreenState extends State<PassengerInfoScreen> {
  late final List<PassengerDraft> passengers;

  final phoneCtrl = TextEditingController(text: "+966");
  final emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final count = widget.search.totalPassengers;
    passengers = List.generate(
      count < 1 ? 1 : count,
      (i) => PassengerDraft(index: i + 1),
    );
  }

  @override
  void dispose() {
    phoneCtrl.dispose();
    emailCtrl.dispose();
    for (final p in passengers) {
      p.dispose();
    }
    super.dispose();
  }

  // =======================
  // ✅ Validation
  // =======================
  bool get isValid {
    final email = emailCtrl.text.trim();
    final phone = phoneCtrl.text.trim();

    if (!email.contains("@") || !email.contains(".")) return false;
    if (phone.length < 9) return false;

    for (final p in passengers) {
      if (p.firstNameCtrl.text.trim().isEmpty) return false;
      if (p.lastNameCtrl.text.trim().isEmpty) return false;
    }
    return true;
  }

  String fareName(FareType f) {
    switch (f) {
      case FareType.basic:
        return "الضيافة الأساسية";
      case FareType.flexible:
        return "الضيافة المرنة";
      case FareType.premium:
        return "الضيافة المميزة";
    }
  }

  void onContinue() {
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("فضلاً عبّي بيانات المسافرين ومعلومات التواصل"),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewBookingScreen(
          search: widget.search,
          offer: widget.offer,
          fare: widget.fare,
          totalPrice: widget.totalPrice,
          passengers: passengers
              .map(
                (p) => PassengerData(
                  firstName: p.firstNameCtrl.text.trim(),
                  lastName: p.lastNameCtrl.text.trim(),
                  passportOrId: p.docCtrl.text.trim(),
                  birthDate: p.birthDate,
                  nationality: p.nationality,
                ),
              )
              .toList(),
          phone: phoneCtrl.text.trim(),
          email: emailCtrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.search;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "معلومات المسافر",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ),

        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            // ===== Summary =====
            Container(
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
                    "${s.fromCode} → ${s.toCode} • ${widget.offer.departTime}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${s.totalPassengers} مسافر • ${fareName(widget.fare)}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.75),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ===== Passengers =====
            ...passengers.map((p) => PassengerFormCard(draft: p)),

            const SizedBox(height: 14),

            // ===== Contact Info =====
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "معلومات التواصل",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _field(
                    label: "رقم الجوال",
                    controller: phoneCtrl,
                    hint: "+9665xxxxxxxx",
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),

                  _field(
                    label: "البريد الإلكتروني",
                    controller: emailCtrl,
                    hint: "name@email.com",
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 6),

                  Text(
                    "سنرسل تفاصيل الحجز على هذا البريد.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 90),
          ],
        ),

        // ===== Bottom Button =====
        bottomNavigationBar: PrimaryButtonBar(
          title: "متابعة",
          subtitle: "${widget.totalPrice} ر.س",
          enabled: isValid,
          onPressed: onContinue,
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(.8),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(.35)),
            filled: true,
            fillColor: Colors.white.withOpacity(.06),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: Colors.white.withOpacity(.10)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  BorderSide(color: AppColors.primary.withOpacity(.8)),
            ),
          ),
        ),
      ],
    );
  }
}

// =======================
// Passenger Draft
// =======================
class PassengerDraft {
  final int index;

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final docCtrl = TextEditingController();

  DateTime? birthDate;
  String nationality = "المملكة العربية السعودية";

  PassengerDraft({required this.index});

  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    docCtrl.dispose();
  }
}

// =======================
// Passenger Data (Final)
// =======================
class PassengerData {
  final String firstName;
  final String lastName;
  final String passportOrId;
  final DateTime? birthDate;
  final String nationality;

  PassengerData({
    required this.firstName,
    required this.lastName,
    required this.passportOrId,
    required this.birthDate,
    required this.nationality,
  });
}