import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../passenger_info_screen.dart';

class PassengerFormCard extends StatefulWidget {
  final PassengerDraft draft;

  const PassengerFormCard({
    super.key,
    required this.draft,
  });

  @override
  State<PassengerFormCard> createState() => _PassengerFormCardState();
}

class _PassengerFormCardState extends State<PassengerFormCard> {
  PassengerDraft get draft => widget.draft;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // ===== Header =====
          Text(
            "المسافر ${draft.index}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),

          // ===== First Name =====
          _field(
            label: "الاسم الأول",
            controller: draft.firstNameCtrl,
            hint: "Mohammed",
          ),
          const SizedBox(height: 10),

          // ===== Last Name =====
          _field(
            label: "اسم العائلة",
            controller: draft.lastNameCtrl,
            hint: "Zakri",
          ),
          const SizedBox(height: 10),

          // ===== Document =====
          _field(
            label: "رقم الهوية / الجواز",
            controller: draft.docCtrl,
            hint: "A12345678",
          ),

          const SizedBox(height: 14),

          // ===== Birth Date =====
          Row(
            children: [
              Expanded(
                child: Text(
                  "تاريخ الميلاد: "
                  "${draft.birthDate == null ? "غير محدد" : _fmt(draft.birthDate!)}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(.7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton(
                onPressed: _pickBirthDate,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                child: const Text(
                  "تعديل",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, 1, 1),
      firstDate: DateTime(now.year - 100, 1, 1),
      lastDate: DateTime(now.year - 1, 12, 31),
    );

    if (picked == null) return;

    setState(() {
      draft.birthDate = picked;
    });
  }

  // =========================
  // Input Field
  // =========================
  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
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

  String _fmt(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }
}