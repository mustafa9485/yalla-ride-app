import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/theme_config.dart';
import 'package:yalla_ride_app/services/notification_service.dart';
import 'package:yalla_ride_app/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// خدمة العمولة والاشتراكات
/// تستخدم لإدارة العمولات واشتراكات Plus للسائقين
class CommissionService {
  // معدل العمولة الافتراضي (10%)
  static const double defaultCommissionRate = 0.10;
  
  // سعر اشتراك Plus الشهري
  static const double plusSubscriptionMonthlyPrice = 50000.0; // 50,000 دينار عراقي
  
  // حساب العمولة المستحقة على رحلة
  static double calculateCommission(double tripAmount, bool isPlusSubscriber) {
    // إذا كان السائق مشتركاً في Plus، فلا توجد عمولة
    if (isPlusSubscriber) {
      return 0.0;
    }
    
    // حساب العمولة بناءً على المعدل الافتراضي
    return tripAmount * defaultCommissionRate;
  }
  
  // حساب إجمالي العمولة المستحقة على السائق
  static Future<double> getTotalCommissionDue(String driverId) async {
    // في الإصدار النهائي، سيتم استرداد البيانات من قاعدة البيانات
    // لكن في هذا النموذج الأولي، سنعيد قيمة ثابتة
    
    return 25000.0; // 25,000 دينار عراقي
  }
  
  // التحقق من حالة اشتراك Plus للسائق
  static Future<bool> isPlusSubscriber(String driverId) async {
    // في الإصدار النهائي، سيتم استرداد البيانات من قاعدة البيانات
    // لكن في هذا النموذج الأولي، سنعيد قيمة ثابتة
    
    return false; // افتراضياً، السائق ليس مشتركاً في Plus
  }
  
  // الحصول على تاريخ استحقاق العمولة التالي
  static Future<DateTime> getNextCommissionDueDate() async {
    // في الإصدار النهائي، سيتم استرداد البيانات من قاعدة البيانات
    // لكن في هذا النموذج الأولي، سنعيد تاريخاً ثابتاً
    
    return DateTime(2025, 6, 15); // 15 يونيو 2025
  }
  
  // تسجيل دفع العمولة
  static Future<bool> recordCommissionPayment(String driverId, double amount, String paymentMethod) async {
    // إرسال بيانات دفع العمولة إلى المنصة الإدارية
    await _sendCommissionDataToAdminPanel({
      'type': 'commission_payment',
      'driver_id': driverId,
      'amount': amount,
      'payment_method': paymentMethod,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // إرسال إشعار تأكيد الدفع
    await NotificationManager.sendAccountStatusUpdateNotification(
      userId: driverId,
      status: 'commission_paid',
      message: 'تم تسجيل دفع العمولة بنجاح بقيمة $amount د.ع',
    );
    
    return true;
  }
  
  // تسجيل اشتراك Plus جديد
  static Future<bool> subscribeToPlusService(String driverId, int months, String paymentMethod) async {
    // حساب المبلغ الإجمالي
    final totalAmount = plusSubscriptionMonthlyPrice * months;
    
    // إرسال بيانات الاشتراك إلى المنصة الإدارية
    await _sendCommissionDataToAdminPanel({
      'type': 'plus_subscription',
      'driver_id': driverId,
      'months': months,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    // إرسال إشعار تأكيد الاشتراك
    await NotificationManager.sendAccountStatusUpdateNotification(
      userId: driverId,
      status: 'plus_subscribed',
      message: 'تم تفعيل اشتراك Plus لمدة $months أشهر بنجاح',
    );
    
    return true;
  }
  
  // إرسال بيانات العمولة والاشتراكات إلى المنصة الإدارية
  static Future<void> _sendCommissionDataToAdminPanel(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.adminPanelUrl}/api/commissions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.adminApiKey}',
          'X-App-Source': 'yalla-ride-mobile',
        },
        body: json.encode({
          ...data,
          'app_version': AppConfig.appVersion,
          'timestamp': DateTime.now().toIso8601String(),
          'source': 'mobile_app',
        }),
      );
      
      // لا نعرض أي رسائل خطأ للمستخدم
      if (response.statusCode != 200) {
        print('[Background] Failed to send commission data: ${response.statusCode}');
      }
    } catch (e) {
      print('[Background] Error sending commission data: $e');
    }
  }
  
  // إلغاء اشتراك Plus
  static Future<bool> cancelPlusSubscription(String driverId) async {
    // في الإصدار النهائي، سيتم إلغاء الاشتراك في قاعدة البيانات
    // لكن في هذا النموذج الأولي، سنعيد قيمة نجاح ثابتة
    
    // إرسال إشعار تأكيد إلغاء الاشتراك
    await NotificationManager.sendAccountStatusUpdateNotification(
      userId: driverId,
      status: 'plus_cancelled',
      message: 'تم إلغاء اشتراك Plus الخاص بك، سيستمر حتى نهاية الفترة المدفوعة',
    );
    
    return true;
  }
  
  // الحصول على تاريخ انتهاء اشتراك Plus
  static Future<DateTime?> getPlusSubscriptionEndDate(String driverId) async {
    // في الإصدار النهائي، سيتم استرداد البيانات من قاعدة البيانات
    // لكن في هذا النموذج الأولي، سنعيد تاريخاً ثابتاً
    
    // إذا كان السائق مشتركاً في Plus
    final isSubscriber = await isPlusSubscriber(driverId);
    if (isSubscriber) {
      return DateTime(2025, 12, 31); // 31 ديسمبر 2025
    }
    
    return null; // السائق غير مشترك في Plus
  }
  
  // الحصول على مزايا اشتراك Plus
  static List<Map<String, dynamic>> getPlusBenefits() {
    return [
      {
        'title': 'عمولة صفر',
        'description': 'لا توجد عمولة على أي رحلة طوال فترة الاشتراك',
        'icon': Icons.money_off,
      },
      {
        'title': 'أولوية الطلبات',
        'description': 'احصل على طلبات الرحلات قبل السائقين الآخرين',
        'icon': Icons.priority_high,
      },
      {
        'title': 'شارة مميزة',
        'description': 'احصل على شارة Plus المميزة في ملفك الشخصي',
        'icon': Icons.verified,
      },
      {
        'title': 'دعم فني مميز',
        'description': 'احصل على دعم فني على مدار الساعة',
        'icon': Icons.support_agent,
      },
      {
        'title': 'إحصائيات متقدمة',
        'description': 'احصل على إحصائيات وتحليلات متقدمة لرحلاتك وأرباحك',
        'icon': Icons.bar_chart,
      },
    ];
  }
}
