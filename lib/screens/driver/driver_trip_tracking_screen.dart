import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:yalla_ride_app/config/theme_config.dart';
import 'package:yalla_ride_app/services/map_service.dart';

/// شاشة تتبع الرحلة للسائق
/// تعرض الخريطة مع موقع السائق والمسار وتحديثات الحالة
class DriverTripTrackingScreen extends StatefulWidget {
  const DriverTripTrackingScreen({Key? key}) : super(key: key);

  @override
  State<DriverTripTrackingScreen> createState() => _DriverTripTrackingScreenState();
}

class _DriverTripTrackingScreenState extends State<DriverTripTrackingScreen> {
  late MapController _mapController;
  String _tripStatus = 'في الطريق إلى الراكب'; // حالة الرحلة الافتراضية
  int _tripTimeInSeconds = 0;
  int _tripStage = 0; // 0: في الطريق إلى الراكب، 1: وصل إلى الراكب، 2: الرحلة جارية، 3: الرحلة انتهت
  
  // إحداثيات نقطة الانطلاق والوصول والسائق
  late LatLng _pickupLocation;
  late LatLng _destinationLocation;
  late LatLng _driverLocation;
  
  // معلومات الراكب
  final Map<String, dynamic> _passengerInfo = {
    'name': 'أحمد محمد',
    'rating': 4.5,
    'photo': 'assets/images/passenger_photo.png',
  };
  
  // المسار بين نقطة الانطلاق والوصول
  List<LatLng> _routePoints = [];
  
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
    
    // تعيين إحداثيات نقطة الانطلاق والوصول والسائق
    _pickupLocation = LatLng(33.3482, 43.7743); // الفلوجة - حي القادسية
    _destinationLocation = LatLng(33.3582, 43.7843); // الفلوجة - شارع الجمهورية
    _driverLocation = LatLng(33.3462, 43.7723); // موقع السائق الافتراضي
    
    // تهيئة المسار بين نقطة الانطلاق والوصول
    _initRoute();
    
    // بدء محاكاة الرحلة
    _startTripSimulation();
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
  
  // دالة محاكاة الرحلة
  void _startTripSimulation() {
    // تشغيل مؤقت لتحديث وقت الرحلة وحالتها
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _tripTimeInSeconds++;
          
          // تحديث موقع السائق (محاكاة)
          if (_tripStage == 0 && _tripTimeInSeconds % 3 == 0) {
            // تحريك السائق نحو نقطة الانطلاق
            _driverLocation = LatLng(
              _driverLocation.latitude + (_pickupLocation.latitude - _driverLocation.latitude) * 0.2,
              _driverLocation.longitude + (_pickupLocation.longitude - _driverLocation.longitude) * 0.2,
            );
            
            // التحقق من وصول السائق إلى نقطة الانطلاق
            if ((_driverLocation.latitude - _pickupLocation.latitude).abs() < 0.0005 &&
                (_driverLocation.longitude - _pickupLocation.longitude).abs() < 0.0005) {
              _tripStage = 1;
              _tripStatus = 'وصلت إلى موقع الراكب';
            }
          } else if (_tripStage == 1 && _tripTimeInSeconds % 5 == 0) {
            // انتقال إلى مرحلة الرحلة الجارية بعد 5 ثوانٍ
            _tripStage = 2;
            _tripStatus = 'الرحلة جارية';
          } else if (_tripStage == 2 && _tripTimeInSeconds % 3 == 0) {
            // تحريك السائق نحو نقطة الوصول
            _driverLocation = LatLng(
              _driverLocation.latitude + (_destinationLocation.latitude - _driverLocation.latitude) * 0.2,
              _driverLocation.longitude + (_destinationLocation.longitude - _driverLocation.longitude) * 0.2,
            );
            
            // التحقق من وصول السائق إلى نقطة الوصول
            if ((_driverLocation.latitude - _destinationLocation.latitude).abs() < 0.0005 &&
                (_driverLocation.longitude - _destinationLocation.longitude).abs() < 0.0005) {
              _tripStage = 3;
              _tripStatus = 'وصلت إلى الوجهة';
              
              // الانتقال إلى شاشة التقييم بعد 3 ثوانٍ
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/driver_trip_rating');
                }
              });
            }
          }
        });
        
        // استمرار المحاكاة إذا لم تنتهِ الرحلة
        if (_tripStage < 3) {
          _startTripSimulation();
        }
      }
    });
  }
  
  // دالة إلغاء الرحلة
  void _cancelTrip() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الرحلة'),
        content: const Text('هل أنت متأكد من رغبتك في إلغاء الرحلة؟ قد يؤثر ذلك على تقييمك.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );
  }
  
  // دالة بدء الرحلة (عند الوصول إلى الراكب)
  void _startTrip() {
    setState(() {
      _tripStage = 2;
      _tripStatus = 'الرحلة جارية';
    });
  }
  
  // دالة إنهاء الرحلة (عند الوصول إلى الوجهة)
  void _endTrip() {
    Navigator.pushReplacementNamed(context, '/driver_trip_rating');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخريطة
          MapboxMapWidget(
            initialLatitude: (_pickupLocation.latitude + _destinationLocation.latitude) / 2,
            initialLongitude: (_pickupLocation.longitude + _destinationLocation.longitude) / 2,
            initialZoom: 15,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: [
              // علامة نقطة الانطلاق (تظهر فقط في المرحلة 0 و 1)
              if (_tripStage < 2)
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
              // علامة السائق
              createCarMarker(
                position: _driverLocation,
                rotation: 0.0, // في الإصدار النهائي، سيتم حساب الزاوية بناءً على اتجاه الحركة
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
          
          // حالة الرحلة
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  _tripStatus,
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSizeMedium,
                    fontWeight: ThemeConfig.fontWeightSemiBold,
                    color: _tripStage == 3 ? ThemeConfig.successColor : ThemeConfig.accentColor,
                  ),
                ),
              ),
            ),
          ),
          
          // البطاقة السفلية
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildTripCard(),
          ),
        ],
      ),
    );
  }
  
  // دالة بناء بطاقة الرحلة
  Widget _buildTripCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // معلومات الراكب
          Row(
            children: [
              // صورة الراكب
              CircleAvatar(
                radius: 30,
                backgroundColor: ThemeConfig.primaryColor.withOpacity(0.1),
                child: Text(
                  'أح',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: ThemeConfig.fontWeightBold,
                    color: ThemeConfig.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              
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
              
              // وقت الرحلة
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'وقت الرحلة',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeSmall,
                      color: ThemeConfig.textSecondaryColor,
                    ),
                  ),
                  Text(
                    '${_tripTimeInSeconds ~/ 60}:${(_tripTimeInSeconds % 60).toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeMedium,
                      fontWeight: ThemeConfig.fontWeightBold,
                      color: ThemeConfig.accentColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // معلومات الرحلة
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
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
          ),
          const SizedBox(height: 15),
          
          // نقاط الرحلة
          _buildRidePoints(),
          const SizedBox(height: 15),
          
          // أزرار التحكم في الرحلة
          _buildActionButtons(),
        ],
      ),
    );
  }
  
  // دالة بناء أزرار التحكم في الرحلة
  Widget _buildActionButtons() {
    // أزرار مختلفة حسب مرحلة الرحلة
    if (_tripStage == 0) {
      // في الطريق إلى الراكب
      return Row(
        children: [
          // زر الاتصال
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // الاتصال بالراكب
                },
                icon: const Icon(Icons.phone),
                label: const Text('اتصال'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          
          // زر الدردشة
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () {
                  // فتح الدردشة مع الراكب
                },
                icon: const Icon(Icons.message),
                label: const Text('دردشة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeConfig.accentColor,
                  side: BorderSide(color: ThemeConfig.accentColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          
          // زر إلغاء الرحلة
          SizedBox(
            height: 50,
            child: IconButton(
              onPressed: _cancelTrip,
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: ThemeConfig.errorColor.withOpacity(0.1),
                foregroundColor: ThemeConfig.errorColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (_tripStage == 1) {
      // وصل إلى الراكب
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _startTrip,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeConfig.accentColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
            ),
          ),
          child: const Text(
            'بدء الرحلة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else if (_tripStage == 2) {
      // الرحلة جارية
      return Row(
        children: [
          // زر الاتصال
          Expanded(
            child: SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  // الاتصال بالراكب
                },
                icon: const Icon(Icons.phone),
                label: const Text('اتصال'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConfig.accentColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          
          // زر إنهاء الرحلة
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: _endTrip,
                style: OutlinedButton.styleFrom(
                  foregroundColor: ThemeConfig.successColor,
                  side: BorderSide(color: ThemeConfig.successColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
                  ),
                ),
                child: const Text('إنهاء الرحلة'),
              ),
            ),
          ),
        ],
      );
    } else {
      // الرحلة انتهت
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _endTrip,
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeConfig.successColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
            ),
          ),
          child: const Text(
            'تقييم الرحلة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
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
          size: 20,
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: ThemeConfig.fontSizeSmall,
            fontWeight: ThemeConfig.fontWeightSemiBold,
            color: ThemeConfig.textPrimaryColor,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: ThemeConfig.fontSizeXSmall,
            color: ThemeConfig.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}
