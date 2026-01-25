import 'package:flutter/material.dart';
import '../../core/app_colors.dart'; // ✅ المسار الصحيح

/// 🏷️ شرائح التصنيفات
class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return Container(
            margin: const EdgeInsets.only(left: 8),
            child: FilterChip(
              label: Text(
                _getCategoryWithEmoji(category),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onCategorySelected(category),
              backgroundColor: AppColors.cardDark,
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.borderDark,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  /// 🎨 إضافة emoji للتصنيف
  String _getCategoryWithEmoji(String category) {
    const emojis = {
      'الكل': '🍽️ الكل',
      'برجر': '🍔 برجر',
      'بيتزا': '🍕 بيتزا',
      'دجاج': '🍗 دجاج',
      'شاورما': '🌯 شاورما',
      'مشويات': '🥩 مشويات',
      'آسيوي': '🍜 آسيوي',
      'حلويات': '🍰 حلويات',
      'مأكولات بحرية': '🦐 مأكولات بحرية',
      'إفطار': '🍳 إفطار',
      'عربي': '🍛 عربي',
      'إيطالي': '🍝 إيطالي',
      'مكسيكي': '🌮 مكسيكي',
      'سوشي': '🍱 سوشي',
      'مشروبات': '🥤 مشروبات',
    };
    return emojis[category] ?? category;
  }
}