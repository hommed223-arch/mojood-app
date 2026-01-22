import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/restaurant_model.dart';

/// 🏪 كارت المطعم
class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final String orderType; // 'delivery' أو 'pickup'
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.orderType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDelivery = orderType == 'delivery';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // صورة/شعار المطعم
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    borderRadius: BorderRadius.circular(12),
                    image: restaurant.logoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(restaurant.logoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: restaurant.logoUrl == null
                      ? Center(
                          child: Text(
                            restaurant.categoryEmoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                        )
                      : null,
                ),

                const SizedBox(width: 12),

                // معلومات المطعم
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // اسم المطعم
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // التصنيف
                      Row(
                        children: [
                          Text(
                            restaurant.categoryEmoji,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.category,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // التقييم والوقت والرسوم
                      Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          // التقييم
                          _buildInfoChip(
                            icon: Icons.star,
                            text: restaurant.ratingText,
                            color: Colors.amber,
                          ),

                          // الوقت
                          _buildInfoChip(
                            icon: Icons.access_time,
                            text: isDelivery
                                ? restaurant.deliveryTimeText
                                : restaurant.pickupTimeText,
                            color: AppColors.primary,
                          ),

                          // رسوم التوصيل (فقط للتوصيل)
                          if (isDelivery)
                            _buildInfoChip(
                              icon: Icons.delivery_dining,
                              text: restaurant.deliveryFeeText,
                              color: restaurant.deliveryFee == 0
                                  ? Colors.green
                                  : Colors.white54,
                            ),

                          // مجاناً (للاستلام)
                          if (!isDelivery)
                            _buildInfoChip(
                              icon: Icons.money_off,
                              text: 'مجاناً',
                              color: Colors.green,
                            ),
                        ],
                      ),

                      // الحد الأدنى للطلب (إذا موجود)
                      if (isDelivery &&
                          restaurant.minOrderDelivery > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          'الحد الأدنى: ${restaurant.minOrderDelivery.toStringAsFixed(0)} ر.س',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // حالة المطعم
                Column(
                  children: [
                    // حالة مفتوح/مغلق
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: restaurant.isOpen
                            ? Colors.green.withOpacity(0.2)
                            : Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        restaurant.isOpen ? 'مفتوح' : 'مغلق',
                        style: TextStyle(
                          color: restaurant.isOpen ? Colors.green : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // سهم
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🏷️ شريحة معلومة صغيرة
  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}