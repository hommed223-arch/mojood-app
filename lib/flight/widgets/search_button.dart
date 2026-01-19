import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// 🔍 زر البحث
class SearchButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;
  final String? label;

  const SearchButton({
    super.key,
    required this.enabled,
    required this.onPressed,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: enabled ? 8 : 0,
          shadowColor: AppColors.primary.withOpacity(.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              color: enabled 
                  ? Colors.white 
                  : Colors.white.withOpacity(.5),
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              label ?? "البحث عن رحلات",
              style: TextStyle(
                color: enabled 
                    ? Colors.white 
                    : Colors.white.withOpacity(.5),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}