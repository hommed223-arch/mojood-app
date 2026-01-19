import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/app_colors.dart';
import '../models/rental_search_model.dart';
import '../models/car_model.dart';
import 'car_details_screen.dart';

class CarSearchResultsScreen extends StatefulWidget {
  final RentalSearchModel search;

  const CarSearchResultsScreen({super.key, required this.search});

  @override
  State<CarSearchResultsScreen> createState() => _CarSearchResultsScreenState();
}

class _CarSearchResultsScreenState extends State<CarSearchResultsScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  String? errorMessage;
  List<CarModel> cars = [];

  // الفلاتر
  String sortBy = "السعر: من الأقل للأعلى";
  
  final List<String> sortOptions = const [
    "السعر: من الأقل للأعلى",
    "السعر: من الأعلى للأقل",
    "الأكثر شعبية",
  ];

  @override
  void initState() {
    super.initState();
    _fetchCars();
  }

  Future<void> _fetchCars() async {
    try {
      setState(() => loading = true);

      final response = await supabase
          .from('cars_catalog')
          .select()
          .eq('available', true)
          .order('price_per_day', ascending: true);

      setState(() {
        cars = (response as List).map((c) => CarModel.fromDb(c)).toList();
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  void _applySorting() {
    setState(() {
      if (sortBy == "السعر: من الأقل للأعلى") {
        cars.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
      } else if (sortBy == "السعر: من الأعلى للأقل") {
        cars.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
      }
    });
  }

  String _formatDate(DateTime date) {
    final months = [
      "يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو",
      "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"
    ];
    return "${months[date.month - 1]} ${date.day}";
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Column(
          children: [
            // الهيدر
            _buildHeader(),

            // الفلاتر
            _buildFiltersBar(),

            // عدد النتائج
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "تم العثور على ${cars.length} مركبة",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // قائمة السيارات
            Expanded(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        )
                      : cars.isEmpty
                          ? const Center(
                              child: Text(
                                "لا توجد سيارات متاحة",
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _fetchCars,
                              color: AppColors.primary,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: cars.length,
                                itemBuilder: (_, index) => _CarResultCard(
                                  car: cars[index],
                                  search: widget.search,
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // 📋 الهيدر
  // =============================
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        border: Border(
          bottom: BorderSide(color: AppColors.borderDark),
        ),
      ),
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Row(
          children: [
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.search.pickupLocation.split(" - ").first,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${_formatDate(widget.search.pickupDate)}, ${widget.search.pickupTime} - ${_formatDate(widget.search.returnDate)}, ${widget.search.returnTime}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
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

  // =============================
  // 🔧 شريط الفلاتر
  // =============================
  Widget _buildFiltersBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        border: Border(
          bottom: BorderSide(color: AppColors.borderDark),
        ),
      ),
      child: Row(
        children: [
          // ترتيب حسب
          Expanded(
            child: InkWell(
              onTap: _showSortSheet,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sort, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "ترتيب حسب",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            width: 1,
            height: 24,
            color: AppColors.borderDark,
          ),

          // تصفية النتائج
          Expanded(
            child: InkWell(
              onTap: _showFilterSheet,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tune, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "تصفية النتائج",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "ترتيب حسب",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            ...sortOptions.map((option) => ListTile(
              onTap: () {
                setState(() => sortBy = option);
                _applySorting();
                Navigator.pop(context);
              },
              title: Text(
                option,
                style: TextStyle(
                  color: sortBy == option ? AppColors.primary : Colors.white,
                  fontWeight: sortBy == option ? FontWeight.w800 : FontWeight.normal,
                ),
              ),
              trailing: sortBy == option
                  ? Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
            )),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "تصفية النتائج",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            // يمكن إضافة المزيد من الفلاتر هنا
            const Text(
              "قريباً...",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// =============================
// 🚗 كارت السيارة في النتائج
// =============================
class _CarResultCard extends StatelessWidget {
  final CarModel car;
  final RentalSearchModel search;

  const _CarResultCard({
    required this.car,
    required this.search,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CarDetailsScreen(car: car, search: search),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // الجزء العلوي - الشركة والتاجات
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // لوغو الشركة
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        car.brand.substring(0, 2).toUpperCase(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "شركة التأجير",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  // التاجات
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildTag("إلغاء مجاني", Colors.green),
                      const SizedBox(height: 4),
                      _buildTag("متاح توصيل", Colors.green.shade700),
                      const SizedBox(height: 4),
                      _buildTag("مناسب للميزانية", Colors.green.shade800),
                    ],
                  ),
                ],
              ),
            ),

            // صورة السيارة
            Container(
              height: 140,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.bgDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: car.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        car.imageUrl!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      ),
                    )
                  : _buildPlaceholder(),
            ),

            // معلومات السيارة
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم السيارة والسعر
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car.fullName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "أو سيارة مماثلة",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "السعر لـ ${search.rentalDays} ${search.rentalDays == 1 ? 'يوم' : 'أيام'}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "ر.س",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${(car.pricePerDay * search.rentalDays).toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // المواصفات السريعة
                  Row(
                    children: [
                      Text(
                        "${car.seats} المقاعد | ${car.category}",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.check, color: Colors.green, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        "يشمل ضريبة القيمة المضافة",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // الموقع
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.white.withOpacity(0.5),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        car.city,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Divider(color: AppColors.borderDark, height: 1),
                  const SizedBox(height: 12),

                  // المميزات
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeature(Icons.speed, "${car.kmLimit ?? 300} كيلومترات"),
                      _buildFeature(Icons.settings, car.transmission),
                      _buildFeature(Icons.local_gas_station, car.fuelType),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 50, color: Colors.white24),
          const SizedBox(height: 8),
          Text(
            car.brand,
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}