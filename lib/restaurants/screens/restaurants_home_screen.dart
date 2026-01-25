import 'package:flutter/material.dart';
import '../../core/app_colors.dart'; // ✅ المسار الصحيح
import '../models/restaurant_model.dart'; // ✅ المسار الصحيح
import '../widgets/restaurant_card.dart'; // ✅ المسار الصحيح
import '../widgets/category_chips.dart'; // ✅ المسار الصحيح

/// 🍽️ الشاشة الرئيسية للمطاعم
class RestaurantsHomeScreen extends StatefulWidget {
  const RestaurantsHomeScreen({super.key});

  @override
  State<RestaurantsHomeScreen> createState() => _RestaurantsHomeScreenState();
}

class _RestaurantsHomeScreenState extends State<RestaurantsHomeScreen>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  
  // نوع الطلب: 'delivery' أو 'pickup'
  String get orderType => _tabController.index == 0 ? 'delivery' : 'pickup';

  // قائمة التصنيفات
  final List<String> _categories = [
    'الكل',
    'برجر',
    'بيتزا',
    'دجاج',
    'شاورما',
    'مشويات',
    'آسيوي',
    'حلويات',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // لتحديث المطاعم عند تغيير التبويب
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.cardDark,
          elevation: 0,
          title: const Text(
            '🍽️ المطاعم',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.delivery_dining),
                    text: 'توصيل',
                  ),
                  Tab(
                    icon: Icon(Icons.storefront),
                    text: 'استلام',
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // شريط البحث
            _buildSearchBar(),

            // التصنيفات
            CategoryChips(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),

            // قائمة المطاعم
            Expanded(
              child: _buildRestaurantsList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔍 شريط البحث
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'ابحث عن مطعم...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white54),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  /// 📋 قائمة المطاعم
  Widget _buildRestaurantsList() {
    // TODO: اجلب من Supabase
    // هنا نضع مطاعم تجريبية للآن
    final restaurants = _getDummyRestaurants();

    // فلترة حسب البحث والتصنيف
    final filteredRestaurants = restaurants.where((restaurant) {
      final matchesSearch = _searchQuery.isEmpty ||
          restaurant.name.contains(_searchQuery) ||
          (restaurant.nameEn?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

      final matchesCategory = _selectedCategory == 'الكل' ||
          restaurant.category == _selectedCategory;

      final matchesOrderType = orderType == 'delivery'
          ? restaurant.deliveryAvailable
          : restaurant.pickupAvailable;

      return matchesSearch && matchesCategory && matchesOrderType;
    }).toList();

    if (filteredRestaurants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.white38,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد مطاعم',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              orderType == 'delivery'
                  ? 'جرب البحث في قسم الاستلام'
                  : 'جرب البحث في قسم التوصيل',
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredRestaurants.length,
      itemBuilder: (context, index) {
        return RestaurantCard(
          restaurant: filteredRestaurants[index],
          orderType: orderType,
          onTap: () {
            // TODO: الانتقال لصفحة تفاصيل المطعم
            print('المطعم: ${filteredRestaurants[index].name}');
          },
        );
      },
    );
  }

  /// 🧪 مطاعم تجريبية (مؤقت - سيتم استبداله بـ Supabase)
  List<Restaurant> _getDummyRestaurants() {
    return [
      Restaurant(
        id: '1',
        name: 'البيك',
        nameEn: 'Al Baik',
        logoUrl: 'https://via.placeholder.com/100',
        category: 'دجاج',
        rating: 4.8,
        totalReviews: 2500,
        deliveryAvailable: true,
        deliveryFee: 12,
        deliveryTimeMin: 25,
        deliveryTimeMax: 35,
        minOrderDelivery: 20,
        pickupAvailable: true,
        pickupTimeMin: 15,
        pickupTimeMax: 20,
        minOrderPickup: 0,
        address: 'شارع الملك فهد، جدة',
        city: 'جدة',
        isOpen: true,
      ),
      Restaurant(
        id: '2',
        name: 'ماكدونالدز',
        nameEn: 'McDonald\'s',
        logoUrl: 'https://via.placeholder.com/100',
        category: 'برجر',
        rating: 4.5,
        totalReviews: 3200,
        deliveryAvailable: true,
        deliveryFee: 15,
        deliveryTimeMin: 30,
        deliveryTimeMax: 40,
        minOrderDelivery: 25,
        pickupAvailable: true,
        pickupTimeMin: 15,
        pickupTimeMax: 25,
        minOrderPickup: 0,
        address: 'حي السلام، الرياض',
        city: 'الرياض',
        isOpen: true,
      ),
      Restaurant(
        id: '3',
        name: 'بيتزا هت',
        nameEn: 'Pizza Hut',
        logoUrl: 'https://via.placeholder.com/100',
        category: 'بيتزا',
        rating: 4.3,
        totalReviews: 1800,
        deliveryAvailable: true,
        deliveryFee: 18,
        deliveryTimeMin: 35,
        deliveryTimeMax: 45,
        minOrderDelivery: 30,
        pickupAvailable: true,
        pickupTimeMin: 20,
        pickupTimeMax: 30,
        minOrderPickup: 0,
        address: 'طريق الملك عبدالله، جدة',
        city: 'جدة',
        isOpen: true,
      ),
      Restaurant(
        id: '4',
        name: 'هرفي',
        nameEn: 'Herfy',
        logoUrl: 'https://via.placeholder.com/100',
        category: 'برجر',
        rating: 4.4,
        totalReviews: 2100,
        deliveryAvailable: true,
        deliveryFee: 10,
        deliveryTimeMin: 25,
        deliveryTimeMax: 35,
        minOrderDelivery: 20,
        pickupAvailable: true,
        pickupTimeMin: 15,
        pickupTimeMax: 20,
        minOrderPickup: 0,
        address: 'شارع العليا، الرياض',
        city: 'الرياض',
        isOpen: true,
      ),
      Restaurant(
        id: '5',
        name: 'شاورمر',
        nameEn: 'Shawrmer',
        logoUrl: 'https://via.placeholder.com/100',
        category: 'شاورما',
        rating: 4.6,
        totalReviews: 1500,
        deliveryAvailable: true,
        deliveryFee: 8,
        deliveryTimeMin: 20,
        deliveryTimeMax: 30,
        minOrderDelivery: 15,
        pickupAvailable: true,
        pickupTimeMin: 10,
        pickupTimeMax: 15,
        minOrderPickup: 0,
        address: 'حي الروضة، جدة',
        city: 'جدة',
        isOpen: true,
      ),
      Restaurant(
        id: '6',
        name: 'الطازج',
        nameEn: 'Al Tazaj',
        logoUrl: 'https://via.placeholder.com/100',
        category: 'دجاج',
        rating: 4.7,
        totalReviews: 2800,
        deliveryAvailable: false, // تجربة: مطعم بدون توصيل
        deliveryFee: 0,
        minOrderDelivery: 0,
        pickupAvailable: true,
        pickupTimeMin: 15,
        pickupTimeMax: 20,
        minOrderPickup: 0,
        address: 'طريق الملك فهد، الدمام',
        city: 'الدمام',
        isOpen: true,
      ),
    ];
  }
}