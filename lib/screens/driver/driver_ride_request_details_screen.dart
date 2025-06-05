import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:yalla_ride_app/config/theme_config.dart';
import 'package:yalla_ride_app/services/map_service.dart';

/// شاشة تفاصيل طلب الرحلة للسائق
/// تعرض تفاصيل طلب الرحلة ونقاط الانطلاق والوصول على الخريطة
class DriverRideRequestDetailsScreen extends StatefulWidget {
  const DriverRideRequestDetailsScreen({Key? key}) : super(key: key);

  @override
  State<DriverRideRequestDetailsScreen> createState() => _DriverRideRequestDetailsScreenState();
}

class _DriverRideRequestDetailsScreenState extends State<DriverRideRequestDetailsScreen> {
  late MapController _mapController;
  bool _isLoading = false;
  
  // إحداثيات نقطة الانطلاق والوصول
  final LatLng _pickupLocation = LatLng(33.3482, 43.7743); // الفلوجة - حي القادسية
  final LatLng _destinationLocation = LatLng(33.3582, 43.7843); // الفلوجة - شارع الجمهورية
  
  // المسار بين نقطة الانطلاق والوصول
  List<LatLng> _routePoints = [];
  
  // معلومات الراكب
  final Map<String, dynamic> _passengerInfo = {
    'name': 'أحمد محمد',
    'rating': 4.5,
    'photo': 'assets/images/passenger_photo.png',
  };
  
  // معلومات الرحلة
  final Map<String, dynamic> _rideInfo = {
    'distance': '2.5 كم',
    'duration': '10 دقائق',
    'price': '5,000 د.ع',
    'type': 'عائلي',
  };

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    // تهيئة المسار بين نقطة الانطلاق والوصول
    _initRoute();
  }
  
  // دالة تهيئة المسار
  Future<void> _initRoute() async {
    // الحصول على المسار بين نقطة الانطلاق والوصول
    final routePoints = await LocationService.getRouteBetweenPoints(
      _pickupLocation,
      _destinationLocation,
    );
    
    setState(() {
      _routePoints = routePoints;
    });
  }
  
  // دالة قبول الرحلة
  void _acceptRide() async {
    setState(() {
      _isLoading = true;
    });
    
    // محاكاة تأخير لعملية قبول الرحلة
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
    });
    
    // الانتقال إلى شاشة تتبع الرحلة
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/driver_trip_tracking');
    }
  }
  
  // دالة رفض الرحلة
  void _rejectRide() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الطلب'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // الخريطة
          Expanded(
            child: MapboxMapWidget(
              initialLatitude: (_pickupLocation.latitude + _destinationLocation.latitude) / 2,
              initialLongitude: (_pickupLocation.longitude + _destinationLocation.longitude) / 2,
              initialZoom: 14,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: [
                // علامة نقطة الانطلاق
                createLocationMarker(
                  position: _pickupLocation,
                  color: ThemeConfig.primaryColor,
                  icon: Icons.my_location,
                ),
                // علامة نقطة الوصول
                createLocationMarker(
                  position: _destinationLocation,
                  color: ThemeConfig.accentColor,
                  icon: Icons.location_on,
                ),
              ],
              polylines: [
                // مسار الرحلة
                if (_routePoints.isNotEmpty)
                  createRouteLine(
                    points: _routePoints,
                    color: ThemeConfig.accentColor,
                    strokeWidth: 4,
                  ),
              ],
            ),
          ),
          
          // تفاصيل الرحلة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // معلومات الراكب
                Row(
                  children: [
                    // صورة الراكب
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: ThemeConfig.primaryColor.withOpacity(0.1),
                      child: Text(
                        'أح',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: ThemeConfig.fontWeightBold,
                          color: ThemeConfig.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // معلومات الراكب
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _passengerInfo['name'],
                            style: TextStyle(
                              fontSize: ThemeConfig.fontSizeMedium,
                              fontWeight: ThemeConfig.fontWeightSemiBold,
                              color: ThemeConfig.textPrimaryColor,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _passengerInfo['rating'].toString(),
                                style: TextStyle(
                                  fontSize: ThemeConfig.fontSizeSmall,
                                  color: ThemeConfig.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // نوع الرحلة
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeConfig.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _rideInfo['type'],
                        style: TextStyle(
                          fontSize: ThemeConfig.fontSizeSmall,
                          fontWeight: ThemeConfig.fontWeightMedium,
                          color: ThemeConfig.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // نقاط الرحلة
                _buildRidePoints(),
                const SizedBox(height: 16),
                
                // معلومات الرحلة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRideInfoItem(
                      icon: Icons.route,
                      title: 'المسافة',
                      value: _rideInfo['distance'],
                    ),
                    _buildRideInfoItem(
                      icon: Icons.access_time,
                      title: 'المدة',
                      value: _rideInfo['duration'],
                    ),
                    _buildRideInfoItem(
                      icon: Icons.account_balance_wallet,
                      title: 'الأرباح',
                      value: _rideInfo['price'],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // أزرار القبول والرفض
                Row(
                  children: [
                    // زر الرفض
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _rejectRide,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ThemeConfig.errorColor,
                            side: BorderSide(color: ThemeConfig.errorColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
                            ),
                          ),
                          child: const Text(
                            'رفض',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // زر القبول
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _acceptRide,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConfig.accentColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : const Text(
                                  'قبول',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // دالة بناء نقاط الرحلة
  Widget _buildRidePoints() {
    return Column(
      children: [
        // نقطة الانطلاق
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: ThemeConfig.primaryColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'حي القادسية، الفلوجة',
                style: TextStyle(
                  fontSize: ThemeConfig.fontSizeRegular,
                  color: ThemeConfig.textPrimaryColor,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 5),
          child: Container(
            width: 1,
            height: 20,
            color: Colors.grey[300],
          ),
        ),
        
        // نقطة الوصول
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: ThemeConfig.accentColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'شارع الجمهورية، الفلوجة',
                style: TextStyle(
                  fontSize: ThemeConfig.fontSizeRegular,
                  color: ThemeConfig.textPrimaryColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // دالة بناء عنصر معلومات الرحلة
  Widget _buildRideInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: ThemeConfig.accentColor,
          size: 24,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: ThemeConfig.fontSizeRegular,
            fontWeight: ThemeConfig.fontWeightSemiBold,
            color: ThemeConfig.textPrimaryColor,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: ThemeConfig.fontSizeSmall,
            color: ThemeConfig.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}
