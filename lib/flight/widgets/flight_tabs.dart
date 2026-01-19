import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

// ... باقي الكود كما هو

/// 🔄 تبويبات الرحلة (ذهاب فقط / ذهاب وعودة)
class FlightTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const FlightTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: "ذهاب فقط",
              isSelected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _TabButton(
              label: "ذهاب وعودة",
              isSelected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected 
                  ? Colors.white 
                  : Colors.white.withOpacity(.7),
              fontWeight: isSelected 
                  ? FontWeight.w900 
                  : FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}