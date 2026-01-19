import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_colors.dart';
import '../models/car_model.dart';
import 'car_details_screen.dart';

class CarsHomeScreen extends StatefulWidget {
  const CarsHomeScreen({super.key});

  @override
  State<CarsHomeScreen> createState() => _CarsHomeScreenState();
}

class _CarsHomeScreenState extends State<CarsHomeScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  String? errorMessage;
  List<CarModel> allCars = [];
  List<CarModel> filteredCars = [];

  String searchQuery = "";
  String selectedCity = "الكل";
  String selectedCategory = "الكل";
  String? selectedPriceSort;

  final List<String> cities = const [
    "الكل",
    "الرياض",
    "جدة",
    "الدمام",
    "مكة",
    "المدينة"
  ];

  final List<String> categories = const [
    "الكل",
    "صغيرة",
    "متوسطة",
    "كبيرة",
    "فاخرة",
    "رياضية"
  ];

  @override
  void initState() {
    super.initState();
    fetchCars();
  }

  Future<void> fetchCars() async {
    try {
      final response = await supabase
          .from('cars_catalog')
          .select()
          .eq('available', true)
          .order('price_per_day', ascending: true);

      setState(() {
        allCars = (response as List)
            .map((car) => CarModel.fromDb(car))
            .toList();
        filteredCars = List.from(allCars);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  void applyFilters() {
    List<CarModel> result = List.from(allCars);

    if (selectedCity != "الكل") {
      result = result.where((c) => c.city == selectedCity).toList();
    }

    if (selectedCategory != "الكل") {
      result = result.where((c) => c.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      result = result.where((car) {
        final q = searchQuery.toLowerCase();
        return car.brand.toLowerCase().contains(q) ||
            car.model.toLowerCase().contains(q) ||
            car.fullName.toLowerCase().contains(q);
      }).toList();
    }

    if (selectedPriceSort == "الأقل سعراً") {
      result.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
    } else if (selectedPriceSort == "الأعلى سعراً") {
      result.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
    }

    setState(() => filteredCars = result);
  }

  void openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "تصفية السيارات",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _dropdown(
                    label: "المدينة",
                    value: selectedCity,
                    items: cities
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setStateSheet(() => selectedCity = v!),
                  ),

                  const SizedBox(height: 16),

                  _dropdown(
                    label: "الفئة",
                    value: selectedCategory,
                    items: categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setStateSheet(() => selectedCategory = v!),
                  ),

                  const SizedBox(height: 16),

                  _dropdown(
                    label: "السعر",
                    value: selectedPriceSort,
                    items: const [
                      DropdownMenuItem(value: "الأقل سعراً", child: Text("الأقل سعراً")),
                      DropdownMenuItem(value: "الأعلى سعراً", child: Text("الأعلى سعراً")),
                    ],
                    onChanged: (v) => setStateSheet(() => selectedPriceSort = v),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              selectedCity = "الكل";
                              selectedCategory = "الكل";
                              selectedPriceSort = null;
                            });
                            applyFilters();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white24),
                          ),
                          child: const Text("مسح"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                          ),
                          onPressed: () {
                            applyFilters();
                            Navigator.pop(context);
                          },
                          child: const Text("تطبيق"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.cardDark,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
      ),
      items: items,
      onChanged: onChanged,
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
            "تأجير السيارات",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_alt, color: Colors.white),
              onPressed: openFilterSheet,
            ),
          ],
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "ابحث عن سيارة",
                        hintStyle: TextStyle(color: Colors.white.withOpacity(.6)),
                        prefixIcon: Icon(Icons.search, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.cardDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (v) {
                        searchQuery = v;
                        applyFilters();
                      },
                    ),
                  ),

                  Expanded(
                    child: filteredCars.isEmpty
                        ? const Center(
                            child: Text(
                              "لا توجد سيارات متاحة",
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredCars.length,
                            itemBuilder: (context, index) {
                              return _CarCard(car: filteredCars[index]);
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// 🚗 كارد السيارة (Yelo Style)
class _CarCard extends StatelessWidget {
  final CarModel car;

  const _CarCard({required this.car});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CarDetailsScreen(car: car),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardDark,
              AppColors.cardDark.withOpacity(.85),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    car.imageUrl ?? '',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.grey.shade900,
                            Colors.grey.shade800,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.directions_car, size: 70, color: Colors.white.withOpacity(.3)),
                            const SizedBox(height: 8),
                            Text(
                              car.brand,
                              style: TextStyle(
                                color: Colors.white.withOpacity(.5),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(car.categoryIcon, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 4),
                        Text(
                          car.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.brand,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${car.model} ${car.year}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _modernSpec(Icons.event_seat, "${car.seats}", Colors.blue.shade400),
                      const SizedBox(width: 16),
                      _modernSpec(Icons.settings, car.transmission == 'أوتوماتيك' ? 'A' : 'M', Colors.green.shade400),
                      const SizedBox(width: 16),
                      _modernSpec(Icons.local_gas_station, car.fuelType == 'بنزين' ? 'بنزين' : 'ديزل', Colors.orange.shade400),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.location_on, size: 16, color: AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            car.city,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${car.pricePerDay.toStringAsFixed(0)} ر.س',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'لليوم',
                            style: TextStyle(
                              color: Colors.white.withOpacity(.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CarDetailsScreen(car: car),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'احجز الآن',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_back, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernSpec(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}