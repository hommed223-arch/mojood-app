import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class PassengerTypeChip extends StatelessWidget {
  final String text;

  const PassengerTypeChip({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primary.withOpacity(.45),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12.5,
          letterSpacing: .2,
        ),
      ),
    );
  }
}