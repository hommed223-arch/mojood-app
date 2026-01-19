/// 🔍 موديل البحث عن السيارات
class RentalSearchModel {
  final String pickupLocation;
  final String? returnLocation;
  final DateTime pickupDate;
  final DateTime returnDate;
  final String pickupTime;
  final String returnTime;
  final bool differentReturnLocation;

  RentalSearchModel({
    required this.pickupLocation,
    this.returnLocation,
    required this.pickupDate,
    required this.returnDate,
    required this.pickupTime,
    required this.returnTime,
    this.differentReturnLocation = false,
  });

  /// عدد أيام الإيجار
  int get rentalDays {
    final diff = returnDate.difference(pickupDate).inDays;
    return diff <= 0 ? 1 : diff;
  }

  /// نص موقع الاستلام
  String get pickupText => pickupLocation;

  /// نص موقع التسليم
  String get returnText => differentReturnLocation 
      ? (returnLocation ?? pickupLocation) 
      : pickupLocation;

  /// تحويل إلى Map
  Map<String, dynamic> toJson() => {
    'pickup_location': pickupLocation,
    'return_location': returnLocation,
    'pickup_date': pickupDate.toIso8601String(),
    'return_date': returnDate.toIso8601String(),
    'pickup_time': pickupTime,
    'return_time': returnTime,
    'different_return_location': differentReturnLocation,
  };

  @override
  String toString() => 'RentalSearch($pickupLocation, $rentalDays days)';
}