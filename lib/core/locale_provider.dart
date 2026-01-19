import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'app_locale';

  Locale _locale = const Locale('ar');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  // =========================
  // Load saved locale
  // =========================
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);

    if (code != null) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  // =========================
  // Save & switch
  // =========================
  Future<void> setArabic() async {
    _locale = const Locale('ar');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, 'ar');
    notifyListeners();
  }

  Future<void> setEnglish() async {
    _locale = const Locale('en');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, 'en');
    notifyListeners();
  }
}