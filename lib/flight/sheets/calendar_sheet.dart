import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// 📅 نافذة اختيار التواريخ
class CalendarSheet {
  static Future<CalendarResult?> show(
    BuildContext context, {
    required bool isRoundTrip,
    required DateTime initialDepart,
    DateTime? initialReturn,
  }) async {
    return showModalBottomSheet<CalendarResult>(
      context: context,
      backgroundColor: AppColors.bgDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _CalendarSheetContent(
        isRoundTrip: isRoundTrip,
        initialDepart: initialDepart,
        initialReturn: initialReturn,
      ),
    );
  }
}

/// 📆 محتوى النافذة
class _CalendarSheetContent extends StatefulWidget {
  final bool isRoundTrip;
  final DateTime initialDepart;
  final DateTime? initialReturn;

  const _CalendarSheetContent({
    required this.isRoundTrip,
    required this.initialDepart,
    this.initialReturn,
  });

  @override
  State<_CalendarSheetContent> createState() => _CalendarSheetContentState();
}

class _CalendarSheetContentState extends State<_CalendarSheetContent> {
  late DateTime departDate;
  DateTime? returnDate;
  bool selectingDepart = true;

  @override
  void initState() {
    super.initState();
    departDate = widget.initialDepart;
    returnDate = widget.initialReturn;
  }

  void _pickDate(DateTime date) {
    setState(() {
      if (selectingDepart) {
        departDate = date;
        
        // إذا ذهاب وعودة، انتقل لاختيار العودة
        if (widget.isRoundTrip) {
          selectingDepart = false;
          
          // إذا العودة قبل الذهاب، امسحها
          if (returnDate != null && returnDate!.isBefore(departDate)) {
            returnDate = null;
          }
        }
      } else {
        // يجب أن تكون العودة بعد الذهاب
        if (date.isAfter(departDate) || date.isAtSameMomentAs(departDate)) {
          returnDate = date;
        }
      }
    });
  }

  void _confirm() {
    if (!widget.isRoundTrip || returnDate != null) {
      Navigator.pop(
        context,
        CalendarResult(depart: departDate, ret: returnDate),
      );
    }
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
              "اختر التواريخ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 16),

            // ======= التبويبات =======
            if (widget.isRoundTrip)
              Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      label: "تاريخ الذهاب",
                      date: departDate,
                      isSelected: selectingDepart,
                      onTap: () => setState(() => selectingDepart = true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TabButton(
                      label: "تاريخ العودة",
                      date: returnDate,
                      isSelected: !selectingDepart,
                      onTap: () => setState(() => selectingDepart = false),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // ======= التقويم =======
            CalendarDatePicker(
              initialDate: selectingDepart ? departDate : (returnDate ?? departDate),
              firstDate: selectingDepart 
                  ? DateTime.now() 
                  : departDate,
              lastDate: DateTime.now().add(const Duration(days: 365)),
              onDateChanged: _pickDate,
            ),

            const SizedBox(height: 20),

            // ======= زر التأكيد =======
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (!widget.isRoundTrip || returnDate != null)
                    ? _confirm
                    : null,
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

/// 🔘 زر التبويب
class _TabButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(.15)
              : AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : AppColors.borderDark,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(.7),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null ? _formatDate(date!) : '—',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 📊 نتيجة التقويم
class CalendarResult {
  final DateTime depart;
  final DateTime? ret;

  CalendarResult({required this.depart, this.ret});
}