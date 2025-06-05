import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/app_config.dart';
import 'package:yalla_ride_app/services/background_admin_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// خدمة الإشعارات
/// تستخدم لإرسال وإدارة الإشعارات في التطبيق
class NotificationService {
  static const String _tag = 'NotificationService';
  
  // أنواع الإشعارات
  static const String TYPE_RIDE_REQUEST = 'ride_request';
  static const String TYPE_RIDE_ACCEPTED = 'ride_accepted';
  static const String TYPE_RIDE_STARTED = 'ride_started';
  static const String TYPE_RIDE_COMPLETED = 'ride_completed';
  static const String TYPE_PAYMENT_SUCCESS = 'payment_success';
  static const String TYPE_PAYMENT_FAILED = 'payment_failed';
  static const String TYPE_COMMISSION_DUE = 'commission_due';
  static const String TYPE_PLUS_SUBSCRIPTION = 'plus_subscription';
  static const String TYPE_GENERAL = 'general';

  // تهيئة خدمة الإشعارات
  static Future<void> initialize() async {
    try {
      // في الإصدار النهائي، سيتم تهيئة OneSignal هنا
      debugPrint('$_tag: تم تهيئة خدمة الإشعارات');
    } catch (e) {
      debugPrint('$_tag: خطأ في تهيئة خدمة الإشعارات: $e');
    }
  }

  // تسجيل المستخدم للإشعارات
  static Future<void> registerUser({
    required String userId,
    required String userRole,
    Map<String, String>? additionalData,
  }) async {
    try {
      // إرسال بيانات التسجيل إلى المنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'notification_registration',
        'user_id': userId,
        'user_role': userRole,
        'device_info': additionalData ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: تم تسجيل المستخدم للإشعارات: $userId');
    } catch (e) {
      debugPrint('$_tag: خطأ في تسجيل المستخدم للإشعارات: $e');
    }
  }

  // إرسال إشعار إلى مستخدم محدد
  static Future<void> sendNotificationToUser({
    required String userId,
    required String notificationType,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // إرسال الإشعار إلى المنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'notification_sent',
        'target_user_id': userId,
        'notification_type': notificationType,
        'title': title,
        'body': body,
        'data': data ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: تم إرسال إشعار إلى المستخدم: $userId');
    } catch (e) {
      debugPrint('$_tag: خطأ في إرسال الإشعار: $e');
    }
  }

  // إرسال إشعار إلى مجموعة من المستخدمين
  static Future<void> sendNotificationToGroup({
    required List<String> userIds,
    required String notificationType,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // إرسال الإشعار إلى المنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'group_notification_sent',
        'target_user_ids': userIds,
        'notification_type': notificationType,
        'title': title,
        'body': body,
        'data': data ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: تم إرسال إشعار إلى ${userIds.length} مستخدم');
    } catch (e) {
      debugPrint('$_tag: خطأ في إرسال الإشعار الجماعي: $e');
    }
  }

  // إرسال إشعار للإدارة
  static Future<void> notifyAdmins({
    required String title,
    required String message,
    Map<String, dynamic>? data,
  }) async {
    try {
      // إرسال الإشعار إلى المنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'admin_notification',
        'title': title,
        'message': message,
        'data': data ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: تم إرسال إشعار للإدارة');
    } catch (e) {
      debugPrint('$_tag: خطأ في إرسال إشعار للإدارة: $e');
    }
  }

  // إرسال إشعار طلب رحلة جديد
  static Future<void> sendRideRequestNotification({
    required String driverId,
    required String passengerId,
    required String pickupLocation,
    required String destination,
    required double estimatedFare,
  }) async {
    await sendNotificationToUser(
      userId: driverId,
      notificationType: TYPE_RIDE_REQUEST,
      title: 'طلب رحلة جديد',
      body: 'لديك طلب رحلة جديد من $pickupLocation إلى $destination',
      data: {
        'passenger_id': passengerId,
        'pickup_location': pickupLocation,
        'destination': destination,
        'estimated_fare': estimatedFare,
      },
    );
  }

  // إرسال إشعار قبول الرحلة
  static Future<void> sendRideAcceptedNotification({
    required String passengerId,
    required String driverId,
    required String driverName,
    required String vehicleInfo,
  }) async {
    await sendNotificationToUser(
      userId: passengerId,
      notificationType: TYPE_RIDE_ACCEPTED,
      title: 'تم قبول طلب الرحلة',
      body: 'السائق $driverName في الطريق إليك',
      data: {
        'driver_id': driverId,
        'driver_name': driverName,
        'vehicle_info': vehicleInfo,
      },
    );
  }

  // إرسال إشعار بدء الرحلة
  static Future<void> sendRideStartedNotification({
    required String passengerId,
    required String driverId,
  }) async {
    await sendNotificationToUser(
      userId: passengerId,
      notificationType: TYPE_RIDE_STARTED,
      title: 'بدأت الرحلة',
      body: 'بدأت رحلتك الآن، نتمنى لك رحلة آمنة',
      data: {
        'driver_id': driverId,
      },
    );
  }

  // إرسال إشعار انتهاء الرحلة
  static Future<void> sendRideCompletedNotification({
    required String passengerId,
    required String driverId,
    required double totalFare,
  }) async {
    await sendNotificationToUser(
      userId: passengerId,
      notificationType: TYPE_RIDE_COMPLETED,
      title: 'انتهت الرحلة',
      body: 'وصلت إلى وجهتك بأمان. إجمالي التكلفة: ${totalFare.toStringAsFixed(0)} د.ع',
      data: {
        'driver_id': driverId,
        'total_fare': totalFare,
      },
    );
  }

  // إرسال إشعار نجاح الدفع
  static Future<void> sendPaymentSuccessNotification({
    required String userId,
    required double amount,
    required String transactionId,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      notificationType: TYPE_PAYMENT_SUCCESS,
      title: 'تم الدفع بنجاح',
      body: 'تمت عملية الدفع بنجاح. المبلغ: ${amount.toStringAsFixed(0)} د.ع',
      data: {
        'amount': amount,
        'transaction_id': transactionId,
      },
    );
  }

  // إرسال إشعار فشل الدفع
  static Future<void> sendPaymentFailedNotification({
    required String userId,
    required double amount,
    required String reason,
  }) async {
    await sendNotificationToUser(
      userId: userId,
      notificationType: TYPE_PAYMENT_FAILED,
      title: 'فشل في الدفع',
      body: 'فشلت عملية الدفع. يرجى المحاولة مرة أخرى.',
      data: {
        'amount': amount,
        'failure_reason': reason,
      },
    );
  }

  // إرسال إشعار استحقاق العمولة
  static Future<void> sendCommissionDueNotification({
    required String driverId,
    required double amount,
    required DateTime dueDate,
  }) async {
    await sendNotificationToUser(
      userId: driverId,
      notificationType: TYPE_COMMISSION_DUE,
      title: 'استحقاق عمولة',
      body: 'لديك عمولة مستحقة بقيمة ${amount.toStringAsFixed(0)} د.ع',
      data: {
        'amount': amount,
        'due_date': dueDate.toIso8601String(),
      },
    );
  }

  // إرسال إشعار اشتراك Plus
  static Future<void> sendPlusSubscriptionNotification({
    required String driverId,
    required String message,
    required bool isRenewal,
  }) async {
    await sendNotificationToUser(
      userId: driverId,
      notificationType: TYPE_PLUS_SUBSCRIPTION,
      title: isRenewal ? 'تجديد اشتراك Plus' : 'اشتراك Plus',
      body: message,
      data: {
        'is_renewal': isRenewal,
      },
    );
  }

  // الحصول على إعدادات الإشعارات للمستخدم
  static Future<Map<String, bool>> getUserNotificationSettings(String userId) async {
    try {
      // في الإصدار النهائي، سيتم الاستعلام من قاعدة البيانات
      return {
        'push_notifications': true,
        'email_notifications': true,
        'sms_notifications': false,
        'ride_notifications': true,
        'payment_notifications': true,
        'promotional_notifications': false,
      };
    } catch (e) {
      debugPrint('$_tag: خطأ في الحصول على إعدادات الإشعارات: $e');
      return {};
    }
  }

  // تحديث إعدادات الإشعارات للمستخدم
  static Future<void> updateUserNotificationSettings({
    required String userId,
    required Map<String, bool> settings,
  }) async {
    try {
      // إرسال الإعدادات إلى المنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'notification_settings_update',
        'user_id': userId,
        'settings': settings,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: تم تحديث إعدادات الإشعارات للمستخدم: $userId');
    } catch (e) {
      debugPrint('$_tag: خطأ في تحديث إعدادات الإشعارات: $e');
    }
  }
}

