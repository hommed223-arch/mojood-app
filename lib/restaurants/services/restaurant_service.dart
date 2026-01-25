import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/restaurant_model.dart';
import '../models/menu_item_model.dart';

/// 🍽️ خدمة المطاعم - الربط بـ Supabase
class RestaurantService {
  final _supabase = Supabase.instance.client;

  /// 📋 جلب كل المطاعم
  Future<List<Restaurant>> getRestaurants({
    String? category,
    String? city,
    bool? deliveryAvailable,
    bool? pickupAvailable,
  }) async {
    try {
      var query = _supabase.from('restaurants').select();

      // فلترة حسب التصنيف
      if (category != null && category != 'الكل') {
        query = query.eq('category', category);
      }

      // فلترة حسب المدينة
      if (city != null) {
        query = query.eq('city', city);
      }

      // فلترة حسب التوصيل
      if (deliveryAvailable != null) {
        query = query.eq('delivery_available', deliveryAvailable);
      }

      // فلترة حسب الاستلام
      if (pickupAvailable != null) {
        query = query.eq('pickup_available', pickupAvailable);
      }

      // ترتيب حسب التقييم
      query = query.order('rating', ascending: false);

      final response = await query;
      
      return (response as List)
          .map((json) => Restaurant.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching restaurants: $e');
      return [];
    }
  }

  /// 🔍 البحث عن مطاعم
  Future<List<Restaurant>> searchRestaurants(String query) async {
    try {
      final response = await _supabase
          .from('restaurants')
          .select()
          .or('name.ilike.%$query%,name_en.ilike.%$query%')
          .order('rating', ascending: false);

      return (response as List)
          .map((json) => Restaurant.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error searching restaurants: $e');
      return [];
    }
  }

  /// 🏪 جلب مطعم واحد
  Future<Restaurant?> getRestaurant(String id) async {
    try {
      final response = await _supabase
          .from('restaurants')
          .select()
          .eq('id', id)
          .single();

      return Restaurant.fromJson(response);
    } catch (e) {
      print('❌ Error fetching restaurant: $e');
      return null;
    }
  }

  /// 🍔 جلب منيو المطعم
  Future<List<MenuItem>> getMenuItems(String restaurantId) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('available', true)
          .order('is_popular', ascending: false);

      return (response as List)
          .map((json) => MenuItem.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching menu items: $e');
      return [];
    }
  }

  /// 🔥 جلب الأصناف الشهيرة
  Future<List<MenuItem>> getPopularItems(String restaurantId) async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select()
          .eq('restaurant_id', restaurantId)
          .eq('is_popular', true)
          .eq('available', true)
          .limit(5);

      return (response as List)
          .map((json) => MenuItem.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching popular items: $e');
      return [];
    }
  }

  /// 📂 جلب الأصناف حسب التصنيف
  Future<Map<String, List<MenuItem>>> getMenuByCategory(
    String restaurantId,
  ) async {
    try {
      final items = await getMenuItems(restaurantId);
      
      // تجميع حسب التصنيف
      final Map<String, List<MenuItem>> grouped = {};
      
      for (var item in items) {
        if (!grouped.containsKey(item.category)) {
          grouped[item.category] = [];
        }
        grouped[item.category]!.add(item);
      }
      
      return grouped;
    } catch (e) {
      print('❌ Error grouping menu items: $e');
      return {};
    }
  }

  /// 📊 إحصائيات المطاعم
  Future<Map<String, int>> getRestaurantStats() async {
    try {
      final response = await _supabase
          .from('restaurants')
          .select('category')
          .count(CountOption.exact);

      // TODO: حساب عدد المطاعم حسب التصنيف
      return {
        'total': response.count ?? 0,
        'delivery': 0,
        'pickup': 0,
      };
    } catch (e) {
      print('❌ Error fetching stats: $e');
      return {'total': 0};
    }
  }

  /// ⭐ جلب أفضل المطاعم
  Future<List<Restaurant>> getTopRatedRestaurants({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('restaurants')
          .select()
          .gte('rating', 4.5)
          .order('rating', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => Restaurant.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching top rated: $e');
      return [];
    }
  }

  /// 🆕 جلب المطاعم الجديدة
  Future<List<Restaurant>> getNewRestaurants({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('restaurants')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => Restaurant.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching new restaurants: $e');
      return [];
    }
  }

  /// 📍 جلب المطاعم القريبة (حسب المدينة)
  Future<List<Restaurant>> getNearbyRestaurants(String city) async {
    try {
      final response = await _supabase
          .from('restaurants')
          .select()
          .eq('city', city)
          .eq('is_open', true)
          .order('rating', ascending: false);

      return (response as List)
          .map((json) => Restaurant.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching nearby restaurants: $e');
      return [];
    }
  }

  /// 🔄 تحديث حالة المطعم
  Future<bool> updateRestaurantStatus(String id, bool isOpen) async {
    try {
      await _supabase
          .from('restaurants')
          .update({'is_open': isOpen})
          .eq('id', id);
      return true;
    } catch (e) {
      print('❌ Error updating status: $e');
      return false;
    }
  }

  /// 📦 إنشاء طلب
  Future<String?> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      return response['id'];
    } catch (e) {
      print('❌ Error creating order: $e');
      return null;
    }
  }

  /// 📋 جلب طلبات المستخدم
  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, restaurants(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching user orders: $e');
      return [];
    }
  }

  /// 🔍 جلب طلب واحد
  Future<Map<String, dynamic>?> getOrder(String orderId) async {
    try {
      final response = await _supabase
          .from('orders')
          .select('*, restaurants(*)')
          .eq('id', orderId)
          .single();

      return response;
    } catch (e) {
      print('❌ Error fetching order: $e');
      return null;
    }
  }

  /// 🔄 تحديث حالة الطلب
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': status})
          .eq('id', orderId);
      return true;
    } catch (e) {
      print('❌ Error updating order status: $e');
      return false;
    }
  }
}