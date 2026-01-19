import 'package:flutter/material.dart';

/// 🎨 ألوان التطبيق الموحدة
class AppColors {
  AppColors._(); // منع الإنشاء

  // ================= الألوان الأساسية =================
  static const Color primary = Color(0xFF6A1B9A);      // بنفسجي
  static const Color secondary = Color(0xFFFFD700);     // ذهبي
  
  // ================= الخلفيات (Dark Theme) =================
  static const Color bgDark = Color(0xFF121212);        // خلفية رئيسية
  static const Color cardDark = Color(0xFF1E1E1E);      // خلفية الكروت
  static const Color borderDark = Color(0xFF2A2A2A);    // حدود الكروت
  
  // ================= ألوان النصوص =================
  static const Color textPrimary = Color(0xFFFFFFFF);   // نص أساسي
  static const Color textSecondary = Color(0xFFB3B3B3); // نص ثانوي
  static const Color textDisabled = Color(0xFF666666);  // نص معطل
  
  // ================= ألوان الحالة =================
  static const Color success = Color(0xFF4CAF50);       // نجاح
  static const Color error = Color(0xFFF44336);         // خطأ
  static const Color warning = Color(0xFFFF9800);       // تحذير (برتقالي)
  static const Color info = Color(0xFF2196F3);          // معلومة
  
  // ================= ألوان إضافية =================
  static const Color accent1 = Color(0xFF00BCD4);       // لون مميز 1
  static const Color accent2 = Color(0xFFE91E63);       // لون مميز 2
}