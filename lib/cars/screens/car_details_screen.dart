import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/app_colors.dart';
import '../models/car_model.dart';
import '../models/rental_search_model.dart';
import 'car_extras_screen.dart';

class CarDetailsScreen extends StatefulWidget {
  final CarModel car;
  final RentalSearchModel search;

  const CarDetailsScreen({
    super.key,
    required this.car,
    required this.search,
  });

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final PageController _imageController = PageController();
  int _currentImage = 0;

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  double get totalPrice => widget.car.pricePerDay * widget.search.rentalDays;

  @override
  Widget build(BuildContext context) {
    final gallery = widget.car.images?.isNotEmpty == true
        ? widget.car.images!
        : [widget.car.imageUrl ?? ''];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.bgDark,
        body: Stack(
          children: [
            // المحتوى
            CustomScrollView(
              slivers: [
                // صور السيارة
                SliverToBoxAdapter(
                  child: _buildImageGallery(gallery),
                ),

                // معلومات السيارة
                SliverToBoxAdapter(
                  child: _buildCarInfo(),
                ),

                // المواصفات
                SliverToBoxAdapter(
                  child: _buildSpecifications(),
                ),

                // قائمة متطلبات الاستلام
                SliverToBoxAdapter(
                  child: _buildRequirements(),
                ),

                // موقع الاستلام
                SliverToBoxAdapter(
                  child: _buildPickupLocation(),
                ),

                // موقع التسليم
                if (widget.search.differentReturnLocation)
                  SliverToBoxAdapter(
                    child: _buildReturnLocation(),
                  ),

                // المزايا المشمولة
                SliverToBoxAdapter(
                  child: _buildIncludedFeatures(),
                ),

                // مساحة للزر السفلي
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),

            // زر الرجوع
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 16,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // الشريط السفلي
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(),
            ),
          ],
        ),
      ),
    );
  }

  // =============================
  // 🖼️ معرض الصور
  // =============================
  Widget _buildImageGallery(List<String> gallery) {
    return Container(
      height: 280,
      color: AppColors.cardDark,
      child: Stack(
        children: [
          PageView.builder(
            controller: _imageController,
            itemCount: gallery.length,
            onPageChanged: (index) {
              setState(() => _currentImage = index);
            },
            itemBuilder: (_, index) {
              return gallery[index].isNotEmpty
                  ? Image.network(
                      gallery[index],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder();
            },
          ),

          // مؤشرات الصور
          if (gallery.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  gallery.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentImage == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentImage == index
                          ? AppColors.primary
                          : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 80, color: Colors.white24),
          const SizedBox(height: 8),
          Text(
            widget.car.brand,
            style: TextStyle(color: Colors.white38, fontSize: 18),
          ),
        ],
      ),
    );
  }

  // =============================
  // 📋 معلومات السيارة
  // =============================
  Widget _buildCarInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اسم السيارة والشركة
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.car.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "أو سيارة مماثلة",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // لوغو الشركة
              Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        widget.car.brand.substring(0, 2).toUpperCase(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "شركة التأجير",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: AppColors.borderDark),
        ],
      ),
    );
  }

  // =============================
  // 🔧 المواصفات
  // =============================
  Widget _buildSpecifications() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "المواصفات",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildSpecChip(Icons.event_seat, "${widget.car.seats} المقاعد"),
              _buildSpecChip(Icons.settings, widget.car.transmission),
              _buildSpecChip(Icons.door_front_door, "4 الأبواب"),
              _buildSpecChip(Icons.luggage, "2 الحقائب"),
              _buildSpecChip(Icons.ac_unit, "مكيّف هواء"),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.borderDark),
        ],
      ),
    );
  }

  Widget _buildSpecChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =============================
  // 📋 متطلبات الاستلام
  // =============================
  Widget _buildRequirements() {
    final requirements = [
      "جواز سفر أو بطاقة هوية حكومية",
      "العمر بين 21 إلى 65 سنة",
      "رخصة قيادة صالحة",
      "بطاقة ائتمان أو خصم صالحة",
      "عادةً ما يُطلب وديعة تأمين قابلة للاسترداد في معاملات تأجير السيارات",
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "قائمة الأمور المطلوبة للاستلام",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          ...requirements.map((req) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    req,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "يرجى مراجعة ",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              Text(
                "شروط الاستخدام",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
              Text(
                " للمزيد من المعلومات",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.borderDark),
        ],
      ),
    );
  }

  // =============================
  // 📍 موقع الاستلام
  // =============================
  Widget _buildPickupLocation() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "موقع الاستلام",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                "المسافة من موقعك الحالي إلى الفرع • ",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
              Text(
                "4.2 كيلومترات",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.search.pickupLocation,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                "الاتجاهات",
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // الخريطة
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 180,
              color: AppColors.cardDark,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 50, color: Colors.white24),
                    const SizedBox(height: 8),
                    Text(
                      "الخريطة",
                      style: TextStyle(color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.borderDark),
        ],
      ),
    );
  }

  // =============================
  // 📍 موقع التسليم
  // =============================
  Widget _buildReturnLocation() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "موقع التسليم",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.search.returnLocation ?? widget.search.pickupLocation,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.borderDark),
        ],
      ),
    );
  }

  // =============================
  // ✅ المزايا المشمولة
  // =============================
  Widget _buildIncludedFeatures() {
    final features = [
      "إلغاء مجاني حتى 24 ساعة قبل وقت الاستلام",
      "قيادة حتى ${widget.car.kmLimit ?? 300} كيلومترات (تكلفة الكيلومتر الإضافي: 0.40 ر.س لكل كيلومتر)",
      "نظام تحديد المواقع",
      "بلوتوث",
      "كاميرا خلفية",
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "المزايا المشمولة",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // =============================
  // 📊 الشريط السفلي
  // =============================
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        border: Border(
          top: BorderSide(color: AppColors.borderDark),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // زر المتابعة
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CarExtrasScreen(
                      car: widget.car,
                      search: widget.search,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "متابعة",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // السعر
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "السعر لـ ${widget.search.rentalDays} ${widget.search.rentalDays == 1 ? 'يوم' : 'أيام'}",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    "ر.س",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    totalPrice.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}