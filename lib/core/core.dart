import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 🌍 مدير اللغة في التطبيق
class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('ar'); // اللغة الافتراضية
  
  Locale get locale => _locale;
  
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';
  
  LocaleProvider() {
    _loadLocale();
  }
  
  /// 📥 تحميل اللغة المحفوظة
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('language_code') ?? 'ar';
    _locale = Locale(code);
    notifyListeners();
  }
  
  /// 💾 حفظ اللغة
  Future<void> _saveLocale(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
  }
  
  /// 🇸🇦 تفعيل العربية
  Future<void> setArabic() async {
    if (_locale.languageCode == 'ar') return;
    _locale = const Locale('ar');
    await _saveLocale('ar');
    notifyListeners();
  }
  
  /// 🇬🇧 تفعيل الإنجليزية
  Future<void> setEnglish() async {
    if (_locale.languageCode == 'en') return;
    _locale = const Locale('en');
    await _saveLocale('en');
    notifyListeners();
  }
  
  /// 🔄 التبديل بين اللغات
  Future<void> toggle() async {
    if (isArabic) {
      await setEnglish();
    } else {
      await setArabic();
    }
  }
}

/// 📱 الاتجاه حسب اللغة
TextDirection getTextDirection(Locale locale) {
  return locale.languageCode == 'ar' 
      ? TextDirection.rtl 
      : TextDirection.ltr;
}

/// 🔤 النصوص المترجمة (بسيطة)
class AppStrings {
  static Map<String, Map<String, String>> translations = {
    'ar': {
      'app_name': 'موجود عندنا',
      'welcome': 'مرحباً',
      'login': 'تسجيل الدخول',
      'register': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'hotels': 'فنادق',
      'flights': 'طيران',
      'events': 'فعاليات',
      'my_bookings': 'حجوزاتي',
      'profile': 'الملف الشخصي',
      'search': 'بحث',
      'book_now': 'احجز الآن',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'loading': 'جاري التحميل...',
      'error': 'حدث خطأ',
      'success': 'تمت العملية بنجاح',
    },
    'en': {
      'app_name': 'Mojood 3ndna',
      'welcome': 'Welcome',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'hotels': 'Hotels',
      'flights': 'Flights',
      'events': 'Events',
      'my_bookings': 'My Bookings',
      'profile': 'Profile',
      'search': 'Search',
      'book_now': 'Book Now',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'loading': 'Loading...',
      'error': 'An error occurred',
      'success': 'Operation successful',
    },
  };
  
  static String get(String key, Locale locale) {
    final lang = locale.languageCode;
    return translations[lang]?[key] ?? key;
  }
}

/// 🔧 إعدادات التطبيق العامة
class AppConfig {
  static const String appVersion = '1.0.0';
  static const String supportEmail = 'support@mojood3ndna.com';
  static const String privacyPolicyUrl = 'https://mojood3ndna.com/privacy';
  static const String termsUrl = 'https://mojood3ndna.com/terms';
}

/// 📏 أحجام ثابتة
class AppSizes {
  static const double borderRadius = 18.0;
  static const double cardPadding = 16.0;
  static const double screenPadding = 16.0;
  static const double iconSize = 24.0;
  static const double buttonHeight = 54.0;
}

/// ⏰ تنسيق التواريخ
class DateFormatter {
  static String formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
  
  static String formatDateArabic(DateTime date) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
  
  static String formatTime(String time24) {
    // تحويل من 24 ساعة إلى 12 ساعة
    final parts = time24.split(':');
    if (parts.length < 2) return time24;
    
    int hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts[1];
    
    final period = hour >= 12 ? 'م' : 'ص';
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    
    return '$hour:$minute $period';
  }
}