import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

/// 🏙️ كارد اختيار المدن (من - إلى)
class FromToCard extends StatelessWidget {
  final String from;
  final String to;
  final VoidCallback onSwap;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;

  const FromToCard({
    super.key,
    required this.from,
    required this.to,
    required this.onSwap,
    required this.onPickFrom,
    required this.onPickTo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          // ======= من =======
          _CityRow(
            icon: Icons.flight_takeoff,
            label: "من",
            city: from,
            onTap: onPickFrom,
          ),

          const SizedBox(height: 12),

          // ======= زر التبديل =======
          InkWell(
            onTap: onSwap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(.15),
                border: Border.all(
                  color: AppColors.primary.withOpacity(.4),
                ),
              ),
              child: Icon(
                Icons.swap_vert,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ======= إلى =======
          _CityRow(
            icon: Icons.flight_land,
            label: "إلى",
            city: to,
            onTap: onPickTo,
          ),
        ],
      ),
    );
  }
}

/// 🏙️ صف المدينة
class _CityRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String city;
  final VoidCallback onTap;

  const _CityRow({
    required this.icon,
    required this.label,
    required this.city,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(.08),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(.65),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    city,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
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