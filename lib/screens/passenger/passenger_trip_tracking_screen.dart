import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:yalla_ride_app/config/theme_config.dart';
import 'package:yalla_ride_app/services/map_service.dart';

/// شاشة تتبع الرحلة للراكب
/// تعرض الخريطة مع موقع السائق والمسار وتحديثات الحالة
class PassengerTripTrackingScreen extends StatefulWidget {
  const PassengerTripTrackingScreen({Key? key}) : super(key: key);

  @override
  State<PassengerTripTrackingScreen> createState() => _PassengerTripTrackingScreenState();
}

class _PassengerTripTrackingScreenState extends State<PassengerTripTrackingScreen> {
  late MapController _mapController;
  String _tripStatus = 'السائق في الطريق إليك'; // حالة الرحلة الافتراضية
  int _tripTimeInSeconds = 0;
  int _tripStage = 0; // 0: السائق في الطريق، 1: السائق وصل، 2: الرحلة جارية، 3: الرحلة انتهت
  
  // إحداثيات نقطة الانطلاق والوصول والسائق
  late LatLng _pickupLocation;
  late LatLng _destinationLocation;
  late LatLng _driverLocation;
  
  // معلومات السائق
  final Map<String, dynamic> _driverInfo = {
    'name': 'محمد علي',
    'rating': 4.8,
    'car': 'تويوتا كامري',
    'plate': 'أ ن ب 1234',
    'photo': 'assets/images/driver_photo.png',
  };
  
  // المسار بين نقطة الانطلاق والوصول
  List<LatLng> _routePoints = [];
  
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
              _tripStatus = 'السائق وصل إلى موقعك';
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
              _tripStatus = 'وصلت إلى وجهتك';
              
              // الانتقال إلى شاشة التقييم بعد 3 ثوانٍ
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/passenger_trip_rating');
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
        content: const Text('هل أنت متأكد من رغبتك في إلغاء الرحلة؟ قد يتم فرض رسوم إلغاء.'),
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
                  color: ThemeConfig.primaryColor,
                  strokeWidth: 4,
                ),
            ],
          ),
          
          // زر الرجوع
          Positioned(
            top: 50,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
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
                    color: _tripStage == 3 ? ThemeConfig.successColor : ThemeConfig.primaryColor,
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
          // معلومات السائق
          Row(
            children: [
              // صورة السائق
              CircleAvatar(
                radius: 30,
                backgroundColor: ThemeConfig.accentColor.withOpacity(0.1),
                child: Text(
                  'مع',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: ThemeConfig.fontWeightBold,
                    color: ThemeConfig.accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              
              // معلومات السائق
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _driverInfo['name'],
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
                          _driverInfo['rating'].toString(),
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
                      color: ThemeConfig.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // معلومات السيارة
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.directions_car,
                      color: ThemeConfig.accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _driverInfo['car'],
                      style: TextStyle(
                        fontSize: ThemeConfig.fontSizeRegular,
                        color: ThemeConfig.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  _driverInfo['plate'],
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSizeRegular,
                    fontWeight: ThemeConfig.fontWeightSemiBold,
                    color: ThemeConfig.textPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          
          // نقاط الرحلة
          _buildRidePoints(),
          const SizedBox(height: 15),
          
          // أزرار الاتصال وإلغاء الرحلة
          Row(
            children: [
              // زر الاتصال
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // الاتصال بالسائق
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('اتصال'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.primaryColor,
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
                      // فتح الدردشة مع السائق
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('دردشة'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ThemeConfig.primaryColor,
                      side: BorderSide(color: ThemeConfig.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              
              // زر إلغاء الرحلة (يظهر فقط في المرحلتين 0 و 1)
              if (_tripStage < 2)
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
}
