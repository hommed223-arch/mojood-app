import 'package:flutter/material.dart';
import 'package:mojood_app/core/app_colors.dart';

import 'home_screen.dart';
import 'favorites_screen.dart';
import 'my_bookings_screen.dart';
import 'profile_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  /// 🔹 لتحديد أي تبويب يفتح عند الدخول
  /// 0 = الرئيسية
  /// 1 = المفضلة
  /// 2 = حجوزاتي
  /// 3 = حسابي
  final int initialIndex;

  const MainLayoutScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  late int currentIndex;

  final pages = const [
    HomeScreen(),
    FavoritesScreen(),
    MyBookingsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,

      // ======================
      // 📄 Page Content
      // ======================
      body: pages[currentIndex],

      // ======================
      // 🔻 Bottom Navigation
      // ======================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.35),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              if (index == currentIndex) return;
              setState(() => currentIndex = index);
            },

            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.bgDark,
            elevation: 0,

            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.white.withOpacity(.55),

            selectedFontSize: 12,
            unselectedFontSize: 12,

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_rounded),
                label: 'المفضلة',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_rounded),
                label: 'حجوزاتي',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'حسابي',
              ),
            ],
          ),
        ),
      ),
    );
  }
}