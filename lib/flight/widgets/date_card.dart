import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/core.dart';

/// 📅 كارد اختيار التواريخ
class DateCard extends StatelessWidget {
  final bool isRoundTrip;
  final DateTime departDate;
  final DateTime? returnDate;
  final VoidCallback onPickDates;

  const DateCard({
    super.key,
    required this.isRoundTrip,
    required this.departDate,
    this.returnDate,
    required this.onPickDates,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPickDates,
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
                Icons.calendar_month,
                color: AppColors.primary,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // ======= التواريخ =======
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // تاريخ الذهاب
                  _DateRow(
                    label: "الذهاب",
                    date: departDate,
                  ),

                  // تاريخ العودة
                  if (isRoundTrip) ...[
                    const SizedBox(height: 10),
                    _DateRow(
                      label: "العودة",
                      date: returnDate,
                      isReturn: true,
                    ),
                  ],
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

/// 📆 صف التاريخ
class _DateRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isReturn;

  const _DateRow({
    required this.label,
    required this.date,
    this.isReturn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(.65),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          date != null
              ? DateFormatter.formatDateArabic(date!)
              : (isReturn ? "اختر التاريخ" : "-"),
          style: TextStyle(
            color: date != null 
                ? Colors.white 
                : Colors.white.withOpacity(.45),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}