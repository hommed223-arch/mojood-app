import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// 👥 كارد اختيار الركاب
class PassengersCard extends StatelessWidget {
  final int adults;
  final int children;
  final int infants;
  final VoidCallback onPickPassengers;

  const PassengersCard({
    super.key,
    required this.adults,
    required this.children,
    required this.infants,
    required this.onPickPassengers,
  });

  int get totalPassengers => adults + children + infants;

  String get passengersText {
    final parts = <String>[];
    
    if (adults > 0) {
      parts.add('$adults ${adults == 1 ? "بالغ" : "بالغين"}');
    }
    
    if (children > 0) {
      parts.add('$children ${children == 1 ? "طفل" : "أطفال"}');
    }
    
    if (infants > 0) {
      parts.add('$infants ${infants == 1 ? "رضيع" : "رضع"}');
    }
    
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPickPassengers,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            // ======= أيقونة =======
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(.15),
                border: Border.all(
                  color: AppColors.primary.withOpacity(.4),
                ),
              ),
              child: Icon(
                Icons.people,
                color: AppColors.primary,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // ======= النص =======
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "الركاب",
                    style: TextStyle(
                      color: Colors.white.withOpacity(.65),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    passengersText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            // ======= سهم =======
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white.withOpacity(.6),
            ),
          ],
        ),
      ),
    );
  }
}