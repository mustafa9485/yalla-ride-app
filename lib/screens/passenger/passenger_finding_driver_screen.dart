import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:yalla_ride_app/config/theme_config.dart';
import 'package:yalla_ride_app/services/map_service.dart';

/// شاشة البحث عن سائق للراكب
/// تعرض الخريطة مع مؤشر البحث عن سائق وتحديثات الحالة
class PassengerFindingDriverScreen extends StatefulWidget {
  const PassengerFindingDriverScreen({Key? key}) : super(key: key);

  @override
  State<PassengerFindingDriverScreen> createState() => _PassengerFindingDriverScreenState();
}

class _PassengerFindingDriverScreenState extends State<PassengerFindingDriverScreen> {
  late MapController _mapController;
  bool _driverFound = false;
  int _searchTimeInSeconds = 0;
  late LatLng _pickupLocation;
  late LatLng _destinationLocation;
  
  // معلومات السائق (سيتم تعبئتها عند العثور على سائق)
  Map<String, dynamic>? _driverInfo;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    // تعيين إحداثيات نقطة الانطلاق والوصول (للعرض فقط)
    _pickupLocation = LatLng(33.3482, 43.7743); // الفلوجة - حي القادسية
    _destinationLocation = LatLng(33.3582, 43.7843); // الفلوجة - شارع الجمهورية
    
    // بدء البحث عن سائق
    _startSearchingForDriver();
  }
  
  // دالة البحث عن سائق
  void _startSearchingForDriver() {
    // تشغيل مؤقت لتحديث وقت البحث
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_driverFound) {
        setState(() {
          _searchTimeInSeconds++;
        });
        
        // محاكاة العثور على سائق بعد 5 ثوانٍ
        if (_searchTimeInSeconds == 5) {
          _onDriverFound();
        } else {
          _startSearchingForDriver();
        }
      }
    });
  }
  
  // دالة تنفذ عند العثور على سائق
  void _onDriverFound() {
    setState(() {
      _driverFound = true;
      _driverInfo = {
        'name': 'محمد علي',
        'rating': 4.8,
        'car': 'تويوتا كامري',
        'plate': 'أ ن ب 1234',
        'arrivalTime': '3 دقائق',
        'photo': 'assets/images/driver_photo.png',
      };
    });
    
    // الانتقال إلى شاشة تتبع الرحلة بعد 3 ثوانٍ
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/passenger_trip_tracking');
      }
    });
  }
  
  // دالة إلغاء طلب الرحلة
  void _cancelRideRequest() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: const Text('هل أنت متأكد من رغبتك في إلغاء طلب الرحلة؟'),
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
            initialLatitude: _pickupLocation.latitude,
            initialLongitude: _pickupLocation.longitude,
            initialZoom: 15,
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
                  _cancelRideRequest();
                },
              ),
            ),
          ),
          
          // البطاقة السفلية
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _driverFound
                ? _buildDriverFoundCard()
                : _buildSearchingCard(),
          ),
        ],
      ),
    );
  }
  
  // دالة بناء بطاقة البحث عن سائق
  Widget _buildSearchingCard() {
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
          // مؤشر التحميل
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          
          // نص البحث
          Text(
            'جاري البحث عن سائق...',
            style: TextStyle(
              fontSize: ThemeConfig.fontSizeLarge,
              fontWeight: ThemeConfig.fontWeightBold,
              color: ThemeConfig.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 10),
          
          // وقت البحث
          Text(
            'وقت البحث: $_searchTimeInSeconds ثانية',
            style: TextStyle(
              fontSize: ThemeConfig.fontSizeRegular,
              color: ThemeConfig.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 20),
          
          // نقاط الرحلة
          _buildRidePoints(),
          const SizedBox(height: 20),
          
          // زر إلغاء الطلب
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _cancelRideRequest,
              style: OutlinedButton.styleFrom(
                foregroundColor: ThemeConfig.errorColor,
                side: BorderSide(color: ThemeConfig.errorColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
                ),
              ),
              child: const Text(
                'إلغاء الطلب',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // دالة بناء بطاقة العثور على سائق
  Widget _buildDriverFoundCard() {
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
          // نص العثور على سائق
          Text(
            'تم العثور على سائق!',
            style: TextStyle(
              fontSize: ThemeConfig.fontSizeLarge,
              fontWeight: ThemeConfig.fontWeightBold,
              color: ThemeConfig.successColor,
            ),
          ),
          const SizedBox(height: 20),
          
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
                      _driverInfo!['name'],
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
                          _driverInfo!['rating'].toString(),
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
              
              // وقت الوصول
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'وقت الوصول',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeSmall,
                      color: ThemeConfig.textSecondaryColor,
                    ),
                  ),
                  Text(
                    _driverInfo!['arrivalTime'],
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
                      _driverInfo!['car'],
                      style: TextStyle(
                        fontSize: ThemeConfig.fontSizeRegular,
                        color: ThemeConfig.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  _driverInfo!['plate'],
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
          
          // أزرار الاتصال وإلغاء الطلب
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
              
              // زر إلغاء الطلب
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _cancelRideRequest,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ThemeConfig.errorColor,
                      side: BorderSide(color: ThemeConfig.errorColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
                      ),
                    ),
                    child: const Text('إلغاء'),
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
