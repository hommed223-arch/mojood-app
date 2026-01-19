import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'المفضلة',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.borderDark),
            boxShadow: [
              BoxShadow(
                blurRadius: 22,
                offset: const Offset(0, 12),
                color: Colors.black.withOpacity(.35),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(.15),
                ),
                child: Icon(
                  Icons.favorite_border_rounded,
                  size: 38,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "لا توجد عناصر مفضلة",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "ابدأ بإضافة الفنادق أو الرحلات التي تعجبك\nلتجدها هنا بسهولة",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(.65),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}