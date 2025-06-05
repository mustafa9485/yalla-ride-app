import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/theme_config.dart';

/// شاشة تقييم الرحلة للسائق
/// تظهر بعد انتهاء الرحلة لتقييم الراكب وإضافة تعليق
class DriverTripRatingScreen extends StatefulWidget {
  const DriverTripRatingScreen({Key? key}) : super(key: key);

  @override
  State<DriverTripRatingScreen> createState() => _DriverTripRatingScreenState();
}

class _DriverTripRatingScreenState extends State<DriverTripRatingScreen> {
  int _rating = 5; // التقييم الافتراضي
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  
  // معلومات الراكب
  final Map<String, dynamic> _passengerInfo = {
    'name': 'أحمد محمد',
    'photo': 'assets/images/passenger_photo.png',
  };
  
  // معلومات الرحلة
  final Map<String, dynamic> _tripInfo = {
    'from': 'حي القادسية، الفلوجة',
    'to': 'شارع الجمهورية، الفلوجة',
    'distance': '2.5 كم',
    'duration': '10 دقائق',
    'earnings': '5,000 د.ع',
  };
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
  
  // دالة إرسال التقييم
  void _submitRating() async {
    setState(() {
      _isLoading = true;
    });
    
    // محاكاة تأخير لعملية إرسال التقييم
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
    });
    
    // عرض رسالة نجاح التقييم
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال تقييمك بنجاح، شكراً لك!'),
          backgroundColor: ThemeConfig.successColor,
        ),
      );
      
      // العودة إلى الشاشة الرئيسية
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/driver_home',
        (route) => false,
      );
    }
  }
  
  // دالة تخطي التقييم
  void _skipRating() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/driver_home',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تقييم الرحلة'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // رسالة التقييم
            Text(
              'كيف كان تعاملك مع ${_passengerInfo['name']}؟',
              style: TextStyle(
                fontSize: ThemeConfig.fontSizeLarge,
                fontWeight: ThemeConfig.fontWeightBold,
                color: ThemeConfig.textPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // صورة الراكب
            CircleAvatar(
              radius: 50,
              backgroundColor: ThemeConfig.primaryColor.withOpacity(0.1),
              child: Text(
                'أح',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: ThemeConfig.fontWeightBold,
                  color: ThemeConfig.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // اسم الراكب
            Text(
              _passengerInfo['name'],
              style: TextStyle(
                fontSize: ThemeConfig.fontSizeMedium,
                fontWeight: ThemeConfig.fontWeightSemiBold,
                color: ThemeConfig.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 30),
            
            // نجوم التقييم
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            
            // نص التقييم
            Text(
              _getRatingText(),
              style: TextStyle(
                fontSize: ThemeConfig.fontSizeMedium,
                fontWeight: ThemeConfig.fontWeightMedium,
                color: _getRatingColor(),
              ),
            ),
            const SizedBox(height: 30),
            
            // حقل التعليق
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'أضف تعليقاً (اختياري)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
                  borderSide: BorderSide(color: ThemeConfig.accentColor),
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // ملخص الرحلة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ملخص الرحلة',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeMedium,
                      fontWeight: ThemeConfig.fontWeightSemiBold,
                      color: ThemeConfig.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTripInfoRow('من:', _tripInfo['from']),
                  _buildTripInfoRow('إلى:', _tripInfo['to']),
                  _buildTripInfoRow('المسافة:', _tripInfo['distance']),
                  _buildTripInfoRow('المدة:', _tripInfo['duration']),
                  _buildTripInfoRow('الأرباح:', _tripInfo['earnings'], isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // أزرار التقييم والتخطي
            Row(
              children: [
                // زر التخطي
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _skipRating,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ThemeConfig.textSecondaryColor,
                      side: BorderSide(color: ThemeConfig.textSecondaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('تخطي'),
                  ),
                ),
                const SizedBox(width: 16),
                
                // زر إرسال التقييم
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitRating,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('إرسال التقييم'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // دالة بناء صف معلومات الرحلة
  Widget _buildTripInfoRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ThemeConfig.fontSizeRegular,
              color: ThemeConfig.textSecondaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: ThemeConfig.fontSizeRegular,
              fontWeight: ThemeConfig.fontWeightMedium,
              color: ThemeConfig.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  // دالة الحصول على نص التقييم
  String _getRatingText() {
    switch (_rating) {
      case 1:
        return 'سيء جداً';
      case 2:
        return 'سيء';
      case 3:
        return 'مقبول';
      case 4:
        return 'جيد';
      case 5:
        return 'ممتاز';
      default:
        return '';
    }
  }
  
  // دالة الحصول على لون التقييم
  Color _getRatingColor() {
    switch (_rating) {
      case 1:
        return ThemeConfig.errorColor;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.lightGreen;
      case 5:
        return ThemeConfig.successColor;
      default:
        return ThemeConfig.textPrimaryColor;
    }
  }
}
