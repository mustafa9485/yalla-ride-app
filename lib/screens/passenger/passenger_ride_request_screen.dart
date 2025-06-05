import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:yalla_ride_app/config/theme_config.dart';
import 'package:yalla_ride_app/services/map_service.dart';

/// شاشة طلب رحلة للراكب
/// تعرض الخريطة مع تحديد نقطة الانطلاق والوصول واختيار نوع الرحلة
class PassengerRideRequestScreen extends StatefulWidget {
  const PassengerRideRequestScreen({Key? key}) : super(key: key);

  @override
  State<PassengerRideRequestScreen> createState() => _PassengerRideRequestScreenState();
}

class _PassengerRideRequestScreenState extends State<PassengerRideRequestScreen> {
  late MapController _mapController;
  String _selectedRideType = 'shared'; // القيمة الافتراضية
  bool _isLoading = false;
  
  // إحداثيات نقطة الانطلاق والوصول
  final LatLng _pickupLocation = LatLng(33.3482, 43.7743); // الفلوجة - حي القادسية
  final LatLng _destinationLocation = LatLng(33.3582, 43.7843); // الفلوجة - شارع الجمهورية
  
  // المسار بين نقطة الانطلاق والوصول
  List<LatLng> _routePoints = [];
  
  // معلومات الرحلة
  final Map<String, dynamic> _rideInfo = {
    'distance': '2.5 كم',
    'duration': '10 دقائق',
    'price': {
      'shared': '2,500 د.ع',
      'family': '5,000 د.ع',
      'vip': '7,500 د.ع',
    },
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
  
  // دالة طلب الرحلة
  void _requestRide() async {
    setState(() {
      _isLoading = true;
    });
    
    // محاكاة تأخير لعملية طلب الرحلة
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
    });
    
    // الانتقال إلى شاشة البحث عن سائق
    if (mounted) {
      Navigator.pushNamed(context, '/passenger_finding_driver');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلب رحلة'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // الخريطة
          MapboxMapWidget(
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
                  color: ThemeConfig.primaryColor,
                  strokeWidth: 4,
                ),
            ],
          ),
          
          // البطاقة السفلية لتفاصيل الرحلة
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  // نقاط الرحلة
                  _buildRidePoints(),
                  const SizedBox(height: 20),
                  
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
                        title: 'السعر',
                        value: _rideInfo['price'][_selectedRideType],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // أنواع الرحلات
                  Text(
                    'نوع الرحلة',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeMedium,
                      fontWeight: ThemeConfig.fontWeightSemiBold,
                      color: ThemeConfig.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // خيارات نوع الرحلة
                  Row(
                    children: [
                      Expanded(
                        child: _buildRideTypeOption(
                          title: 'مشترك',
                          value: 'shared',
                          icon: Icons.people,
                          price: _rideInfo['price']['shared'],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildRideTypeOption(
                          title: 'عائلي',
                          value: 'family',
                          icon: Icons.family_restroom,
                          price: _rideInfo['price']['family'],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildRideTypeOption(
                          title: 'VIP',
                          value: 'vip',
                          icon: Icons.star,
                          price: _rideInfo['price']['vip'],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // زر طلب الرحلة
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _requestRide,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConfig.primaryColor,
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
                              'طلب رحلة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
          color: ThemeConfig.primaryColor,
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
  
  // دالة بناء خيار نوع الرحلة
  Widget _buildRideTypeOption({
    required String title,
    required String value,
    required IconData icon,
    required String price,
  }) {
    final isSelected = _selectedRideType == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRideType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? ThemeConfig.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? ThemeConfig.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? ThemeConfig.primaryColor : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: ThemeConfig.fontSizeSmall,
                fontWeight: isSelected ? ThemeConfig.fontWeightSemiBold : ThemeConfig.fontWeightRegular,
                color: isSelected ? ThemeConfig.primaryColor : ThemeConfig.textSecondaryColor,
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: ThemeConfig.fontSizeXSmall,
                fontWeight: ThemeConfig.fontWeightMedium,
                color: isSelected ? ThemeConfig.primaryColor : ThemeConfig.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
