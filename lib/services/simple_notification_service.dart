import 'package:flutter/material.dart';
import 'package:yalla_ride_app/services/background_admin_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// خدمة الإشعارات المبسطة
/// تستخدم إشعارات محلية بدلاً من OneSignal لتجنب مشاكل التكوين
class SimpleNotificationService {
  static const String _tag = 'SimpleNotificationService';
  
  // قائمة الإشعارات المحلية
  static List<Map<String, dynamic>> _notifications = [];
  
  // إرسال إشعار محلي
  static Future<void> sendLocalNotification({
    required String title,
    required String message,
    String? userId,
    Map<String, dynamic>? data,
  }) async {
    try {
      Map<String, dynamic> notification = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'message': message,
        'user_id': userId,
        'data': data ?? {},
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      };
      
      _notifications.insert(0, notification);
      
      // إرسال بيانات الإشعار للمنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'notification_sent',
        'notification': notification,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: تم إرسال إشعار: $title');
    } catch (e) {
      debugPrint('$_tag: خطأ في إرسال الإشعار: $e');
    }
  }
  
  // إرسال إشعار للسائق
  static Future<void> notifyDriver({
    required String driverId,
    required String title,
    required String message,
    Map<String, dynamic>? tripData,
  }) async {
    await sendLocalNotification(
      title: title,
      message: message,
      userId: driverId,
      data: {
        'type': 'driver_notification',
        'trip_data': tripData,
      },
    );
  }
  
  // إرسال إشعار للراكب
  static Future<void> notifyPassenger({
    required String passengerId,
    required String title,
    required String message,
    Map<String, dynamic>? tripData,
  }) async {
    await sendLocalNotification(
      title: title,
      message: message,
      userId: passengerId,
      data: {
        'type': 'passenger_notification',
        'trip_data': tripData,
      },
    );
  }
  
  // إرسال إشعار دفع
  static Future<void> notifyPayment({
    required String userId,
    required String amount,
    required String status,
    required String transactionId,
  }) async {
    String title = status == 'success' ? 'تم الدفع بنجاح' : 'فشل في الدفع';
    String message = status == 'success' 
        ? 'تم دفع $amount د.ع بنجاح. رقم المعاملة: $transactionId'
        : 'فشل في دفع $amount د.ع. يرجى المحاولة مرة أخرى.';
    
    await sendLocalNotification(
      title: title,
      message: message,
      userId: userId,
      data: {
        'type': 'payment_notification',
        'amount': amount,
        'status': status,
        'transaction_id': transactionId,
      },
    );
  }
  
  // إرسال إشعار رحلة
  static Future<void> notifyTrip({
    required String userId,
    required String tripStatus,
    required String tripId,
    Map<String, dynamic>? additionalData,
  }) async {
    String title = '';
    String message = '';
    
    switch (tripStatus) {
      case 'requested':
        title = 'طلب رحلة جديد';
        message = 'تم استلام طلب رحلة جديد';
        break;
      case 'accepted':
        title = 'تم قبول الرحلة';
        message = 'تم قبول طلب الرحلة من قبل السائق';
        break;
      case 'started':
        title = 'بدأت الرحلة';
        message = 'بدأ السائق الرحلة';
        break;
      case 'completed':
        title = 'انتهت الرحلة';
        message = 'تم إنهاء الرحلة بنجاح';
        break;
      case 'cancelled':
        title = 'تم إلغاء الرحلة';
        message = 'تم إلغاء الرحلة';
        break;
      default:
        title = 'تحديث الرحلة';
        message = 'تم تحديث حالة الرحلة';
    }
    
    await sendLocalNotification(
      title: title,
      message: message,
      userId: userId,
      data: {
        'type': 'trip_notification',
        'trip_status': tripStatus,
        'trip_id': tripId,
        'additional_data': additionalData,
      },
    );
  }
  
  // الحصول على جميع الإشعارات
  static List<Map<String, dynamic>> getAllNotifications() {
    return List.from(_notifications);
  }
  
  // الحصول على إشعارات مستخدم معين
  static List<Map<String, dynamic>> getUserNotifications(String userId) {
    return _notifications.where((notification) => 
        notification['user_id'] == userId).toList();
  }
  
  // الحصول على الإشعارات غير المقروءة
  static List<Map<String, dynamic>> getUnreadNotifications([String? userId]) {
    var notifications = userId != null 
        ? getUserNotifications(userId)
        : _notifications;
    
    return notifications.where((notification) => 
        notification['read'] == false).toList();
  }
  
  // تمييز إشعار كمقروء
  static Future<void> markAsRead(String notificationId) async {
    try {
      int index = _notifications.indexWhere((notification) => 
          notification['id'] == notificationId);
      
      if (index != -1) {
        _notifications[index]['read'] = true;
        
        // إرسال بيانات قراءة الإشعار للمنصة الإدارية
        await BackgroundAdminService.sendData({
          'type': 'notification_read',
          'notification_id': notificationId,
          'timestamp': DateTime.now().toIso8601String(),
        });
        
        debugPrint('$_tag: تم تمييز الإشعار كمقروء: $notificationId');
      }
    } catch (e) {
      debugPrint('$_tag: خطأ في تمييز الإشعار كمقروء: $e');
    }
  }
  
  // تمييز جميع الإشعارات كمقروءة
  static Future<void> markAllAsRead([String? userId]) async {
    try {
      for (var notification in _notifications) {
        if (userId == null || notification['user_id'] == userId) {
          notification['read'] = true;
        }
      }
      
      // إرسال بيانات قراءة جميع الإشعارات للمنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'all_notifications_read',
        'user_id': userId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: تم تمييز جميع الإشعارات كمقروءة');
    } catch (e) {
      debugPrint('$_tag: خطأ في تمييز جميع الإشعارات كمقروءة: $e');
    }
  }
  
  // حذف إشعار
  static Future<void> deleteNotification(String notificationId) async {
    try {
      _notifications.removeWhere((notification) => 
          notification['id'] == notificationId);
      
      // إرسال بيانات حذف الإشعار للمنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'notification_deleted',
        'notification_id': notificationId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: تم حذف الإشعار: $notificationId');
    } catch (e) {
      debugPrint('$_tag: خطأ في حذف الإشعار: $e');
    }
  }
  
  // مسح جميع الإشعارات
  static Future<void> clearAllNotifications([String? userId]) async {
    try {
      if (userId != null) {
        _notifications.removeWhere((notification) => 
            notification['user_id'] == userId);
      } else {
        _notifications.clear();
      }
      
      // إرسال بيانات مسح الإشعارات للمنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'notifications_cleared',
        'user_id': userId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: تم مسح الإشعارات');
    } catch (e) {
      debugPrint('$_tag: خطأ في مسح الإشعارات: $e');
    }
  }
  
  // إحصائيات الإشعارات
  static Future<Map<String, int>> getNotificationStats([String? userId]) async {
    try {
      var notifications = userId != null 
          ? getUserNotifications(userId)
          : _notifications;
      
      Map<String, int> stats = {
        'total': notifications.length,
        'unread': notifications.where((n) => n['read'] == false).length,
        'read': notifications.where((n) => n['read'] == true).length,
        'driver_notifications': notifications.where((n) => 
            n['data']['type'] == 'driver_notification').length,
        'passenger_notifications': notifications.where((n) => 
            n['data']['type'] == 'passenger_notification').length,
        'payment_notifications': notifications.where((n) => 
            n['data']['type'] == 'payment_notification').length,
        'trip_notifications': notifications.where((n) => 
            n['data']['type'] == 'trip_notification').length,
      };
      
      // إرسال إحصائيات الإشعارات للمنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'notification_stats',
        'user_id': userId,
        'stats': stats,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      return stats;
    } catch (e) {
      debugPrint('$_tag: خطأ في الحصول على إحصائيات الإشعارات: $e');
      return {};
    }
  }
  
  // محاكاة إشعارات تلقائية للاختبار
  static Future<void> simulateNotifications() async {
    await Future.delayed(const Duration(seconds: 2));
    
    await notifyTrip(
      userId: 'driver_001',
      tripStatus: 'requested',
      tripId: 'trip_${DateTime.now().millisecondsSinceEpoch}',
    );
    
    await Future.delayed(const Duration(seconds: 3));
    
    await notifyPayment(
      userId: 'passenger_001',
      amount: '5000',
      status: 'success',
      transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
    );
  }
}

