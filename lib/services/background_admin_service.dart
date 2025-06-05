import 'package:yalla_ride_app/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// خدمة الربط الخفي مع المنصة الإدارية
/// تعمل في الخلفية دون علم المستخدمين
class BackgroundAdminService {
  // رابط المنصة الإدارية
  static const String adminPlatformUrl = 'https://lwqmlpnv.manus.space';
  
  // إرسال بيانات عامة للمنصة الإدارية
  static Future<void> sendData(Map<String, dynamic> data) async {
    await _sendDataToAdmin('data', data);
  }
  
  // إرسال بيانات المستخدم عند التسجيل
  static Future<void> sendUserRegistrationData(Map<String, dynamic> userData) async {
    await _sendDataToAdmin('users/register', userData);
  }
  
  // إرسال بيانات الرحلة
  static Future<void> sendTripData(Map<String, dynamic> tripData) async {
    await _sendDataToAdmin('trips', tripData);
  }
  
  // إرسال بيانات الموقع
  static Future<void> sendLocationData(Map<String, dynamic> locationData) async {
    await _sendDataToAdmin('locations', locationData);
  }
  
  // إرسال بيانات الدفع
  static Future<void> sendPaymentData(Map<String, dynamic> paymentData) async {
    await _sendDataToAdmin('payments', paymentData);
  }
  
  // إرسال بيانات التقييم
  static Future<void> sendRatingData(Map<String, dynamic> ratingData) async {
    await _sendDataToAdmin('ratings', ratingData);
  }
  
  // إرسال بيانات الأخطاء والمشاكل
  static Future<void> sendErrorData(Map<String, dynamic> errorData) async {
    await _sendDataToAdmin('errors', errorData);
  }
  
  // إرسال بيانات استخدام التطبيق
  static Future<void> sendUsageData(Map<String, dynamic> usageData) async {
    await _sendDataToAdmin('usage', usageData);
  }
  
  // إرسال بيانات الجلسة
  static Future<void> sendSessionData(Map<String, dynamic> sessionData) async {
    await _sendDataToAdmin('sessions', sessionData);
  }
  
  // إرسال بيانات الإشعارات المرسلة
  static Future<void> sendNotificationLog(Map<String, dynamic> notificationData) async {
    await _sendDataToAdmin('notifications/log', notificationData);
  }
  
  // إرسال بيانات الاشتراكات
  static Future<void> sendSubscriptionData(Map<String, dynamic> subscriptionData) async {
    await _sendDataToAdmin('subscriptions', subscriptionData);
  }
  
  // الدالة الأساسية لإرسال البيانات
  static Future<void> _sendDataToAdmin(String endpoint, Map<String, dynamic> data) async {
    try {
      // إضافة معلومات إضافية للبيانات
      final enrichedData = {
        ...data,
        'app_version': AppConfig.appVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'source': 'mobile_app',
      };
      
      final response = await http.post(
        Uri.parse('${AppConfig.adminPanelUrl}/api/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.adminApiKey}',
          'X-App-Source': 'yalla-ride-mobile',
        },
        body: json.encode(enrichedData),
      );
      
      // لا نعرض أي رسائل خطأ للمستخدم
      // فقط نسجل في الكونسول للمطورين
      if (response.statusCode != 200) {
        print('[Background] Failed to send data to admin panel: ${response.statusCode}');
      }
    } catch (e) {
      // لا نعرض أي رسائل خطأ للمستخدم
      print('[Background] Error sending data to admin panel: $e');
    }
  }
  
  // إرسال إحصائيات دورية
  static Future<void> sendPeriodicStats(String userId, String userRole) async {
    final stats = {
      'user_id': userId,
      'user_role': userRole,
      'last_active': DateTime.now().toIso8601String(),
      'app_state': 'active',
    };
    
    await _sendDataToAdmin('stats/periodic', stats);
  }
  
  // تتبع أحداث التطبيق
  static Future<void> trackEvent(String eventName, Map<String, dynamic> eventData) async {
    final trackingData = {
      'event_name': eventName,
      'event_data': eventData,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    await _sendDataToAdmin('events/track', trackingData);
  }
}

