import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'hotel_details_screen.dart';
import '../../core/app_colors.dart';

class HotelsScreen extends StatefulWidget {
  const HotelsScreen({super.key});

  @override
  State<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends State<HotelsScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  String? errorMessage;
  List<dynamic> hotels = [];

  String searchQuery = "";

  String selectedCity = "الكل";
  String? selectedPriceSort;
  String? selectedRatingSort;

  bool filterWifi = false;
  bool filterParking = false;
  bool filterPool = false;
  bool filterGym = false;

  @override
  void initState() {
    super.initState();
    fetchHotels();
  }

  Future<void> fetchHotels() async {
    try {
      final response = await supabase
          .from('hotels')
          .select()
          .order('rating', ascending: false);

      setState(() {
        hotels = response;
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    }
  }

  List<dynamic> applyFilters() {
    List<dynamic> result = [...hotels];

    if (selectedCity != "الكل") {
      result = result.where((h) => h['city'] == selectedCity).toList();
    }

    result = result.where((hotel) {
      final name = hotel['name'].toString().toLowerCase();
      final city = hotel['city'].toString().toLowerCase();
      final q = searchQuery.toLowerCase();
      return name.contains(q) || city.contains(q);
    }).toList();

    if (filterWifi) result = result.where((h) => h['wifi'] == true).toList();
    if (filterParking) result = result.where((h) => h['parking'] == true).toList();
    if (filterPool) result = result.where((h) => h['swimming_pool'] == true).toList();
    if (filterGym) result = result.where((h) => h['gym'] == true).toList();

    if (selectedPriceSort == "الأقل سعراً") {
      result.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
    } else if (selectedPriceSort == "الأعلى سعراً") {
      result.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
    }

    if (selectedRatingSort == "الأعلى تقييماً") {
      result.sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
    } else if (selectedRatingSort == "الأقل تقييماً") {
      result.sort((a, b) => (a['rating'] as num).compareTo(b['rating'] as num));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final filteredHotels = applyFilters();

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "الفنادق",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.white),
            onPressed: openFilterSheet,
          )
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "ابحث عن فندق أو مدينة",
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(.6)),
                      prefixIcon:
                          Icon(Icons.search, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.cardDark,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) => setState(() => searchQuery = v),
                  ),
                ),

                Expanded(
                  child: filteredHotels.isEmpty
                      ? const Center(
                          child: Text(
                            "لا توجد نتائج",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredHotels.length,
                          itemBuilder: (context, index) {
                            return HotelCard(hotel: filteredHotels[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // ================= FILTER SHEET =================
  void openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        "تصفية الفنادق",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _dropdown(
                      label: "المدينة",
                      value: selectedCity,
                      items: [
                        const DropdownMenuItem(
                            value: "الكل", child: Text("الكل")),
                        ...hotels
                            .map((h) => h['city'])
                            .toSet()
                            .map((city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                )),
                      ],
                      onChanged: (v) =>
                          setStateSheet(() => selectedCity = v!),
                    ),

                    const SizedBox(height: 12),

                    _dropdown(
                      label: "السعر",
                      value: selectedPriceSort,
                      items: const [
                        DropdownMenuItem(
                            value: "الأقل سعراً",
                            child: Text("الأقل سعراً")),
                        DropdownMenuItem(
                            value: "الأعلى سعراً",
                            child: Text("الأعلى سعراً")),
                      ],
                      onChanged: (v) =>
                          setStateSheet(() => selectedPriceSort = v),
                    ),

                    const SizedBox(height: 12),

                    _dropdown(
                      label: "التقييم",
                      value: selectedRatingSort,
                      items: const [
                        DropdownMenuItem(
                            value: "الأعلى تقييماً",
                            child: Text("الأعلى تقييماً")),
                        DropdownMenuItem(
                            value: "الأقل تقييماً",
                            child: Text("الأقل تقييماً")),
                      ],
                      onChanged: (v) =>
                          setStateSheet(() => selectedRatingSort = v),
                    ),

                    const SizedBox(height: 20),
                    const Text(
                      "الخدمات",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      children: [
                        _chip("WiFi", filterWifi,
                            () => setStateSheet(() => filterWifi = !filterWifi)),
                        _chip("مواقف", filterParking,
                            () => setStateSheet(() => filterParking = !filterParking)),
                        _chip("مسبح", filterPool,
                            () => setStateSheet(() => filterPool = !filterPool)),
                        _chip("جيم", filterGym,
                            () => setStateSheet(() => filterGym = !filterGym)),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                selectedCity = "الكل";
                                selectedPriceSort = null;
                                selectedRatingSort = null;
                                filterWifi = false;
                                filterParking = false;
                                filterPool = false;
                                filterGym = false;
                              });
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
                              setState(() {});
                              Navigator.pop(context);
                            },
                            child: const Text("تطبيق"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: active,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white12,
      labelStyle: TextStyle(
        color: active ? Colors.white : Colors.white70,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

// ================= HOTEL CARD =================
class HotelCard extends StatelessWidget {
  final dynamic hotel;

  const HotelCard({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    final String hotelId = hotel['id'];
    final String name = hotel['name'];
    final String city = hotel['city'];
    final double price = (hotel['price'] ?? 0).toDouble();
    final double rating = (hotel['rating'] ?? 0).toDouble();
    final String imageUrl = hotel['image_url'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
            child: Image.network(
              imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.black26,
                child: const Icon(Icons.hotel, size: 40, color: Colors.white54),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text(city,
                    style: const TextStyle(color: Colors.white60)),
                Row(
                  children: [
                    const Icon(Icons.star,
                        color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(rating.toString(),
                        style:
                            const TextStyle(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "$price ر.س / الليلة",
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: const Text("التفاصيل"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HotelDetailsScreen(
                            hotelId: hotelId,
                            hotelName: name,
                            city: city,
                            price: price,
                            imageUrl: imageUrl,
                            description: hotel['description'],
                            rating: rating,
                            latitude: hotel['latitude'],
                            longitude: hotel['longitude'],
                            images: hotel['images'],
                            wifi: hotel['wifi'],
                            parking: hotel['parking'],
                            swimmingPool: hotel['swimming_pool'],
                            gym: hotel['gym'],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}