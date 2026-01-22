import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'booking_screen.dart';
import '../../core/app_colors.dart';

class HotelDetailsScreen extends StatelessWidget {
  final String hotelId;
  final String hotelName;
  final String city;
  final num price;
  final String imageUrl;

  final String? description;
  final num? rating;
  final double? latitude;
  final double? longitude;
  final List<dynamic>? images;

  final bool wifi;
  final bool parking;
  final bool swimmingPool;
  final bool gym;

  const HotelDetailsScreen({
    super.key,
    required this.hotelId,
    required this.hotelName,
    required this.city,
    required this.price,
    required this.imageUrl,
    this.description,
    this.rating,
    this.latitude,
    this.longitude,
    this.images,
    required this.wifi,
    required this.parking,
    required this.swimmingPool,
    required this.gym,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> gallery =
        (images != null && images!.isNotEmpty)
            ? images!.map((e) => e.toString()).toList()
            : [imageUrl];

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgDark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          hotelName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= Gallery =================
            SizedBox(
              height: 260,
              child: PageView.builder(
                itemCount: gallery.length,
                itemBuilder: (_, index) {
                  return Image.network(
                    gallery[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.black26,
                      child: const Center(
                        child: Icon(Icons.hotel,
                            size: 48, color: Colors.white54),
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= Name & City =================
                  Text(
                    hotelName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    city,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white60,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ================= Rating =================
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Colors.amber, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        rating?.toString() ?? "لا يوجد تقييم",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ================= Description =================
                  Text(
                    description ?? "لا يوجد وصف متاح",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= Facilities =================
                  const Text(
                    "المرافق",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (wifi) _facility(Icons.wifi, "واي فاي مجاني"),
                  if (parking)
                    _facility(Icons.local_parking, "موقف سيارات"),
                  if (swimmingPool) _facility(Icons.pool, "مسبح"),
                  if (gym) _facility(Icons.fitness_center, "نادي رياضي"),

                  const SizedBox(height: 28),

                  // ================= Map =================
                  const Text(
                    "الموقع على الخريطة",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  (latitude != null && longitude != null)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            height: 250,
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.4),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(latitude!, longitude!),
                                zoom: 14,
                              ),
                              markers: {
                                Marker(
                                  markerId: const MarkerId("hotel"),
                                  position:
                                      LatLng(latitude!, longitude!),
                                )
                              },
                              zoomControlsEnabled: false,
                              mapToolbarEnabled: false,
                            ),
                          ),
                        )
                      : const Text(
                          "لا يوجد موقع لهذا الفندق",
                          style: TextStyle(color: Colors.white54),
                        ),

                  const SizedBox(height: 32),

                  // ================= Price & CTA =================
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.45),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$price ر.س / الليلة",
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingScreen(
                                    hotelId: hotelId,
                                    hotelName: hotelName,
                                    price: price,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "حجز الآن",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= Facility Row =================
  Widget _facility(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}