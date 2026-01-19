import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../models/rental_search_model.dart';
import 'car_search_results_screen.dart';

class CarsHomeScreen extends StatefulWidget {
  const CarsHomeScreen({super.key});

  @override
  State<CarsHomeScreen> createState() => _CarsHomeScreenState();
}

class _CarsHomeScreenState extends State<CarsHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // بيانات البحث
  String pickupLocation = "";
  String? returnLocation;
  bool differentReturnLocation = false;

  DateTime pickupDate = DateTime.now();
  DateTime returnDate = DateTime.now().add(const Duration(days: 1));

  String pickupTime = "07:30 مساءً";
  String returnTime = "07:00 مساءً";

  final List<String> locations = const [
    "جدة - مطار الملك عبدالعزيز",
    "الرياض - مطار الملك خالد",
    "الدمام - مطار الملك فهد",
    "مكة المكرمة",
    "المدينة المنورة",
    "جازان - مطار الملك عبدالله",
    "أبها - مطار أبها",
    "تبوك - مطار تبوك",
  ];

  final List<String> times = const [
    "12:00 صباحاً",
    "12:30 صباحاً",
    "01:00 صباحاً",
    "01:30 صباحاً",
    "02:00 صباحاً",
    "02:30 صباحاً",
    "03:00 صباحاً",
    "03:30 صباحاً",
    "04:00 صباحاً",
    "04:30 صباحاً",
    "05:00 صباحاً",
    "05:30 صباحاً",
    "06:00 صباحاً",
    "06:30 صباحاً",
    "07:00 صباحاً",
    "07:30 صباحاً",
    "08:00 صباحاً",
    "08:30 صباحاً",
    "09:00 صباحاً",
    "09:30 صباحاً",
    "10:00 صباحاً",
    "10:30 صباحاً",
    "11:00 صباحاً",
    "11:30 صباحاً",
    "12:00 مساءً",
    "12:30 مساءً",
    "01:00 مساءً",
    "01:30 مساءً",
    "02:00 مساءً",
    "02:30 مساءً",
    "03:00 مساءً",
    "03:30 مساءً",
    "04:00 مساءً",
    "04:30 مساءً",
    "05:00 مساءً",
    "05:30 مساءً",
    "06:00 مساءً",
    "06:30 مساءً",
    "07:00 مساءً",
    "07:30 مساءً",
    "08:00 مساءً",
    "08:30 مساءً",
    "09:00 مساءً",
    "09:30 مساءً",
    "10:00 مساءً",
    "10:30 مساءً",
    "11:00 مساءً",
    "11:30 مساءً",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // =============================
  // 📍 اختيار الموقع
  // =============================
  Future<void> _pickLocation({required bool isPickup}) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _LocationPickerSheet(
        locations: locations,
        selectedLocation: isPickup ? pickupLocation : returnLocation,
      ),
    );

    if (selected != null) {
      setState(() {
        if (isPickup) {
          pickupLocation = selected;
        } else {
          returnLocation = selected;
        }
      });
    }
  }

  // =============================
  // 📅 اختيار التاريخ
  // =============================
  Future<void> _pickDate({required bool isPickup}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isPickup ? pickupDate : returnDate,
      firstDate: isPickup ? now : pickupDate,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.cardDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isPickup) {
          pickupDate = picked;
          // إذا تاريخ التسليم قبل الاستلام، نعدله
          if (returnDate.isBefore(pickupDate) ||
              returnDate.isAtSameMomentAs(pickupDate)) {
            returnDate = pickupDate.add(const Duration(days: 1));
          }
        } else {
          returnDate = picked;
        }
      });
    }
  }

  // =============================
  // ⏰ اختيار الوقت
  // =============================
  Future<void> _pickTime({required bool isPickup}) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _TimePickerSheet(
        times: times,
        selectedTime: isPickup ? pickupTime : returnTime,
      ),
    );

    if (selected != null) {
      setState(() {
        if (isPickup) {
          pickupTime = selected;
        } else {
          returnTime = selected;
        }
      });
    }
  }

  // =============================
  // 🔍 البحث
  // =============================
  void _onSearch() {
    if (pickupLocation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء اختيار موقع الاستلام")),
      );
      return;
    }

    if (differentReturnLocation && (returnLocation == null || returnLocation!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء اختيار موقع التسليم")),
      );
      return;
    }

    final search = RentalSearchModel(
      pickupLocation: pickupLocation,
      returnLocation: differentReturnLocation ? returnLocation : null,
      pickupDate: pickupDate,
      returnDate: returnDate,
      pickupTime: pickupTime,
      returnTime: returnTime,
      differentReturnLocation: differentReturnLocation,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarSearchResultsScreen(search: search),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        appBar: AppBar(
          backgroundColor: AppColors.bgDark,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "تأجير سيارات",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // العنوان
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "مرحباً، احجز رحلتك مع",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // التبويبات
              _buildTabs(),

              const SizedBox(height: 20),

              // كارت البحث
              _buildSearchCard(),

              const SizedBox(height: 24),

              // زر البحث
              _buildSearchButton(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // =============================
  // 🔘 التبويبات
  // =============================
  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: "الاستلام من الفرع"),
          Tab(text: "توصيل لموقعك"),
        ],
      ),
    );
  }

  // =============================
  // 📋 كارت البحث
  // =============================
  Widget _buildSearchCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // موقع الاستلام
          _buildLocationField(
            label: "موقع الاستلام",
            value: pickupLocation,
            onTap: () => _pickLocation(isPickup: true),
          ),

          // زر التبديل + موقع التسليم (إذا كان مختلف)
          if (differentReturnLocation) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.bgDark,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.swap_vert,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildLocationField(
              label: "موقع التسليم",
              value: returnLocation ?? "",
              hint: "أدخل مدينة، مطار أو عنوان",
              onTap: () => _pickLocation(isPickup: false),
            ),
          ],

          const SizedBox(height: 16),

          // خيار موقع تسليم مختلف
          InkWell(
            onTap: () {
              setState(() {
                differentReturnLocation = !differentReturnLocation;
                if (!differentReturnLocation) {
                  returnLocation = null;
                }
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "موقع تسليم مختلف",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: differentReturnLocation
                        ? AppColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: differentReturnLocation
                          ? AppColors.primary
                          : Colors.white38,
                      width: 2,
                    ),
                  ),
                  child: differentReturnLocation
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // التواريخ والأوقات
          Row(
            children: [
              // تاريخ ووقت التسليم
              Expanded(
                child: _buildDateTimeCard(
                  date: returnDate,
                  time: returnTime,
                  onDateTap: () => _pickDate(isPickup: false),
                  onTimeTap: () => _pickTime(isPickup: false),
                ),
              ),

              // السهم
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.bgDark,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white54,
                  size: 20,
                ),
              ),

              // تاريخ ووقت الاستلام
              Expanded(
                child: _buildDateTimeCard(
                  date: pickupDate,
                  time: pickupTime,
                  onDateTap: () => _pickDate(isPickup: true),
                  onTimeTap: () => _pickTime(isPickup: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =============================
  // 📍 حقل الموقع
  // =============================
  Widget _buildLocationField({
    required String label,
    required String value,
    String? hint,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            // الأيقونة والخريطة
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // النص
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.location_on_outlined,
                      color: Colors.white.withOpacity(0.6),
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  value.isNotEmpty ? value : (hint ?? "اختر الموقع"),
                  style: TextStyle(
                    color: value.isNotEmpty ? Colors.white : Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // 📅 كارت التاريخ والوقت
  // =============================
  Widget _buildDateTimeCard({
    required DateTime date,
    required String time,
    required VoidCallback onDateTap,
    required VoidCallback onTimeTap,
  }) {
    final dayName = _getDayName(date.weekday);
    final monthName = _getMonthName(date.month);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          // التاريخ
          InkWell(
            onTap: onDateTap,
            child: Column(
              children: [
                Text(
                  "${date.day}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  "$dayName | $monthName",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Divider(color: AppColors.borderDark, height: 1),
          const SizedBox(height: 12),

          // الوقت
          InkWell(
            onTap: onTimeTap,
            child: Text(
              "الوقت : $time",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =============================
  // 🔍 زر البحث
  // =============================
  Widget _buildSearchButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _onSearch,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Text(
            "بحث",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  // =============================
  // 🛠️ دوال مساعدة
  // =============================
  String _getDayName(int weekday) {
    const days = [
      "الاثنين",
      "الثلاثاء",
      "الأربعاء",
      "الخميس",
      "الجمعة",
      "السبت",
      "الأحد",
    ];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      "يناير",
      "فبراير",
      "مارس",
      "أبريل",
      "مايو",
      "يونيو",
      "يوليو",
      "أغسطس",
      "سبتمبر",
      "أكتوبر",
      "نوفمبر",
      "ديسمبر",
    ];
    return months[month - 1];
  }
}

// =============================
// 📍 شيت اختيار الموقع
// =============================
class _LocationPickerSheet extends StatelessWidget {
  final List<String> locations;
  final String? selectedLocation;

  const _LocationPickerSheet({
    required this.locations,
    this.selectedLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // العنوان
          const Text(
            "اختر الموقع",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),

          // حقل البحث
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "ابحث عن موقع...",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixIcon: Icon(Icons.search, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.bgDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // قائمة المواقع
          Expanded(
            child: ListView.builder(
              itemCount: locations.length,
              itemBuilder: (_, index) {
                final location = locations[index];
                final isSelected = location == selectedLocation;

                return ListTile(
                  onTap: () => Navigator.pop(context, location),
                  leading: Icon(
                    Icons.location_on,
                    color: isSelected ? AppColors.primary : Colors.white54,
                  ),
                  title: Text(
                    location,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// =============================
// ⏰ شيت اختيار الوقت
// =============================
class _TimePickerSheet extends StatelessWidget {
  final List<String> times;
  final String selectedTime;

  const _TimePickerSheet({
    required this.times,
    required this.selectedTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "اختر الوقت",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: times.length,
              itemBuilder: (_, index) {
                final time = times[index];
                final isSelected = time == selectedTime;

                return ListTile(
                  onTap: () => Navigator.pop(context, time),
                  leading: Icon(
                    Icons.access_time,
                    color: isSelected ? AppColors.primary : Colors.white54,
                  ),
                  title: Text(
                    time,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}