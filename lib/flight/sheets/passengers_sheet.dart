import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// 👥 نافذة اختيار الركاب
class PassengersSheet {
  static Future<PassengersResult?> show(
    BuildContext context, {
    required int adults,
    required int children,
    required int infants,
  }) async {
    return showModalBottomSheet<PassengersResult>(
      context: context,
      backgroundColor: AppColors.bgDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _PassengersSheetContent(
        initialAdults: adults,
        initialChildren: children,
        initialInfants: infants,
      ),
    );
  }
}

/// 👤 محتوى النافذة
class _PassengersSheetContent extends StatefulWidget {
  final int initialAdults;
  final int initialChildren;
  final int initialInfants;

  const _PassengersSheetContent({
    required this.initialAdults,
    required this.initialChildren,
    required this.initialInfants,
  });

  @override
  State<_PassengersSheetContent> createState() =>
      _PassengersSheetContentState();
}

class _PassengersSheetContentState extends State<_PassengersSheetContent> {
  late int adults;
  late int children;
  late int infants;

  @override
  void initState() {
    super.initState();
    adults = widget.initialAdults;
    children = widget.initialChildren;
    infants = widget.initialInfants;
  }

  void _confirm() {
    Navigator.pop(
      context,
      PassengersResult(
        adults: adults,
        children: children,
        infants: infants,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ======= العنوان =======
            const Text(
              "عدد الركاب",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 24),

            // ======= البالغين =======
            _PassengerCounter(
              label: "البالغين",
              subtitle: "12 سنة وفوق",
              icon: Icons.person,
              count: adults,
              onIncrement: () => setState(() => adults++),
              onDecrement: () => setState(() {
                if (adults > 1) adults--;
              }),
              minValue: 1,
            ),

            const SizedBox(height: 16),

            // ======= الأطفال =======
            _PassengerCounter(
              label: "الأطفال",
              subtitle: "2 - 11 سنة",
              icon: Icons.child_care,
              count: children,
              onIncrement: () => setState(() => children++),
              onDecrement: () => setState(() {
                if (children > 0) children--;
              }),
            ),

            const SizedBox(height: 16),

            // ======= الرضع =======
            _PassengerCounter(
              label: "الرضع",
              subtitle: "أقل من سنتين",
              icon: Icons.baby_changing_station,
              count: infants,
              onIncrement: () => setState(() {
                // الرضع لا يمكن أن يزيدوا عن البالغين
                if (infants < adults) infants++;
              }),
              onDecrement: () => setState(() {
                if (infants > 0) infants--;
              }),
            ),

            const SizedBox(height: 24),

            // ======= ملاحظة =======
            if (infants > 0)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "كل رضيع يحتاج بالغ مرافق",
                        style: TextStyle(
                          color: Colors.white.withOpacity(.85),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // ======= زر التأكيد =======
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "تأكيد",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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

/// 🔢 عداد الركاب
class _PassengerCounter extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int minValue;

  const _PassengerCounter({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
    this.minValue = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          // ======= الأيقونة =======
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(.15),
              border: Border.all(
                color: AppColors.primary.withOpacity(.4),
              ),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),

          const SizedBox(width: 14),

          // ======= النص =======
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // ======= الأزرار =======
          Row(
            children: [
              _CounterButton(
                icon: Icons.remove,
                onTap: count > minValue ? onDecrement : null,
              ),
              const SizedBox(width: 12),
              Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 12),
              _CounterButton(
                icon: Icons.add,
                onTap: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 🔘 زر العداد
class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CounterButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: onTap != null
              ? AppColors.primary.withOpacity(.15)
              : Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: onTap != null
                ? AppColors.primary.withOpacity(.4)
                : Colors.white.withOpacity(.1),
          ),
        ),
        child: Icon(
          icon,
          color: onTap != null
              ? AppColors.primary
              : Colors.white.withOpacity(.3),
          size: 20,
        ),
      ),
    );
  }
}

/// 📊 نتيجة الركاب
class PassengersResult {
  final int adults;
  final int children;
  final int infants;

  PassengersResult({
    required this.adults,
    required this.children,
    required this.infants,
  });

  int get total => adults + children + infants;
}