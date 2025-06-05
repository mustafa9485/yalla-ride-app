import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/app_config.dart';
import 'package:yalla_ride_app/services/background_admin_service.dart';
import 'package:yalla_ride_app/services/simple_notification_service.dart';
import 'package:yalla_ride_app/services/simple_data_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// خدمة الدفع عبر زين كاش
/// تستخدم لإدارة عمليات الدفع في التطبيق
class ZainCashPaymentService {
  // رابط API زين كاش
  static const String apiUrl = 'https://api.zaincash.iq/transaction/init';
  
  // رابط إعادة التوجيه بعد الدفع
  static const String redirectUrl = 'https://yallaride.app/payment/callback';
  
  // حالات الدفع
  static const String STATUS_PENDING = 'pending';
  static const String STATUS_COMPLETED = 'completed';
  static const String STATUS_FAILED = 'failed';
  static const String STATUS_CANCELLED = 'cancelled';
  
  // بدء عملية دفع جديدة
  static Future<Map<String, dynamic>> initiatePayment({
    required String userId,
    required String userRole,
    required double amount,
    required String paymentType,
    required String paymentDescription,
    String? referenceId,
  }) async {
    try {
      // في الإصدار النهائي، سيتم إرسال طلب إلى API زين كاش
      // لكن في هذا النموذج الأولي، سنعيد بيانات وهمية
      
      // إنشاء معرف فريد للمعاملة
      final transactionId = 'ZC${DateTime.now().millisecondsSinceEpoch}';
      
      // إنشاء رابط الدفع
      final paymentUrl = 'https://secure.zaincash.iq/pay?id=$transactionId';
      
      // تسجيل المعاملة في قاعدة البيانات
      await _recordTransaction(
        transactionId: transactionId,
        userId: userId,
        userRole: userRole,
        amount: amount,
        paymentType: paymentType,
        status: STATUS_PENDING,
        referenceId: referenceId,
      );
      
      return {
        'success': true,
        'transaction_id': transactionId,
        'payment_url': paymentUrl,
        'amount': amount,
        'currency': 'IQD',
        'status': STATUS_PENDING,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'فشل في بدء عملية الدفع: $e',
      };
    }
  }
  
  // التحقق من حالة الدفع
  static Future<Map<String, dynamic>> checkPaymentStatus(String transactionId) async {
    try {
      // في الإصدار النهائي، سيتم الاستعلام من API زين كاش
      // لكن في هذا النموذج الأولي، سنعيد حالة وهمية
      
      return {
        'success': true,
        'transaction_id': transactionId,
        'status': STATUS_COMPLETED,
        'amount': 25000.0,
        'currency': 'IQD',
        'payment_date': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'فشل في التحقق من حالة الدفع: $e',
      };
    }
  }
  
  // تسجيل معاملة جديدة في قاعدة البيانات
  static Future<void> _recordTransaction({
    required String transactionId,
    required String userId,
    required String userRole,
    required double amount,
    required String paymentType,
    required String status,
    String? referenceId,
  }) async {
    try {
      // إرسال البيانات إلى المنصة الإدارية
      await _sendDataToAdminPlatform({
        'type': 'payment_transaction',
        'transaction_id': transactionId,
        'user_id': userId,
        'user_role': userRole,
        'amount': amount,
        'payment_type': paymentType,
        'status': status,
        'reference_id': referenceId,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      print('تم تسجيل المعاملة: $transactionId');
    } catch (e) {
      print('خطأ في تسجيل المعاملة: $e');
    }
  }
  
  // تحديث حالة المعاملة في قاعدة البيانات
  static Future<void> _updateTransactionStatus({
    required String transactionId,
    required String status,
    String? failureReason,
  }) async {
    try {
      // إرسال البيانات إلى المنصة الإدارية
      await _sendDataToAdminPlatform({
        'type': 'payment_status_update',
        'transaction_id': transactionId,
        'status': status,
        'failure_reason': failureReason,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      print('تم تحديث حالة المعاملة: $transactionId إلى $status');
    } catch (e) {
      print('خطأ في تحديث حالة المعاملة: $e');
    }
  }
  
  // إرسال البيانات إلى المنصة الإدارية
  static Future<void> _sendDataToAdminPlatform(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('https://lwqmlpnv.manus.space/api/data'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.adminPlatformApiKey}',
        },
        body: json.encode(data),
      );
      
      if (response.statusCode == 200) {
        print('تم إرسال البيانات بنجاح إلى المنصة الإدارية');
      } else {
        print('فشل في إرسال البيانات: ${response.statusCode}');
      }
    } catch (e) {
      print('خطأ في إرسال البيانات: $e');
      // في حالة فشل الإرسال، يمكن حفظ البيانات محلياً وإعادة المحاولة لاحقاً
    }
  }
  
  // معالجة نتيجة الدفع
  static Future<void> handlePaymentCallback({
    required String transactionId,
    required String status,
    String? failureReason,
  }) async {
    try {
      // تحديث حالة المعاملة
      await _updateTransactionStatus(
        transactionId: transactionId,
        status: status,
        failureReason: failureReason,
      );
      
      // إرسال إشعار للمستخدم
      if (status == STATUS_COMPLETED) {
        await SimpleNotificationService.notifyPayment(
          userId: userId,
          amount: amount.toString(),
          status: 'success',
          transactionId: transactionId,
        );
      } else if (status == STATUS_FAILED) {
        await SimpleNotificationService.notifyPayment(
          userId: userId,
          amount: amount.toString(),
          status: 'failed',
          transactionId: transactionId,
        );
      }
    } catch (e) {
      print('خطأ في معالجة نتيجة الدفع: $e');
    }
  }
  
  // الحصول على تاريخ المعاملات للمستخدم
  static Future<List<Map<String, dynamic>>> getUserTransactions(String userId) async {
    try {
      // في الإصدار النهائي، سيتم الاستعلام من قاعدة البيانات
      // لكن في هذا النموذج الأولي، سنعيد قائمة وهمية
      
      return [
        {
          'transaction_id': 'ZC1234567890',
          'amount': 25000.0,
          'currency': 'IQD',
          'status': STATUS_COMPLETED,
          'payment_type': 'commission',
          'payment_date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'transaction_id': 'ZC1234567891',
          'amount': 50000.0,
          'currency': 'IQD',
          'status': STATUS_COMPLETED,
          'payment_type': 'plus_subscription',
          'payment_date': DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
        },
      ];
    } catch (e) {
      print('خطأ في الحصول على تاريخ المعاملات: $e');
      return [];
    }
  }
  
  // حساب رسوم الدفع
  static double calculatePaymentFees(double amount) {
    // رسوم زين كاش عادة 1% من المبلغ مع حد أدنى وأقصى
    const double feePercentage = 0.01; // 1%
    const double minFee = 250.0; // 250 دينار
    const double maxFee = 5000.0; // 5000 دينار
    
    double fee = amount * feePercentage;
    
    if (fee < minFee) {
      fee = minFee;
    } else if (fee > maxFee) {
      fee = maxFee;
    }
    
    return fee;
  }
  
  // التحقق من صحة المبلغ
  static bool isValidAmount(double amount) {
    const double minAmount = 1000.0; // 1000 دينار
    const double maxAmount = 1000000.0; // مليون دينار
    
    return amount >= minAmount && amount <= maxAmount;
  }
  
  // تنسيق المبلغ للعرض
  static String formatAmount(double amount) {
    return '${amount.toStringAsFixed(0)} د.ع';
  }
}

