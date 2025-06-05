import 'package:flutter/material.dart';
import 'package:yalla_ride_app/services/background_admin_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// خدمة QR Code مبسطة
/// تستخدم مكتبة qr_flutter فقط لتجنب مشاكل qr_code_scanner
class SimpleQRService {
  static const String _tag = 'SimpleQRService';
  
  // إنشاء QR Code للدفع
  static String generatePaymentQR({
    required String amount,
    required String tripId,
    required String driverId,
    required String passengerId,
  }) {
    try {
      // إنشاء بيانات QR للدفع
      Map<String, dynamic> qrData = {
        'type': 'payment',
        'amount': amount,
        'trip_id': tripId,
        'driver_id': driverId,
        'passenger_id': passengerId,
        'timestamp': DateTime.now().toIso8601String(),
        'currency': 'IQD',
      };
      
      String qrString = jsonEncode(qrData);
      
      // إرسال بيانات إنشاء QR للمنصة الإدارية
      BackgroundAdminService.sendData({
        'type': 'qr_code_generated',
        'qr_type': 'payment',
        'qr_data': qrData,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: تم إنشاء QR للدفع: $tripId');
      return qrString;
    } catch (e) {
      debugPrint('$_tag: خطأ في إنشاء QR: $e');
      return '';
    }
  }
  
  // إنشاء QR Code لمعلومات السائق
  static String generateDriverQR({
    required String driverId,
    required String driverName,
    required String vehicleInfo,
    required String phoneNumber,
  }) {
    try {
      Map<String, dynamic> qrData = {
        'type': 'driver_info',
        'driver_id': driverId,
        'driver_name': driverName,
        'vehicle_info': vehicleInfo,
        'phone_number': phoneNumber,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      String qrString = jsonEncode(qrData);
      
      // إرسال بيانات إنشاء QR للمنصة الإدارية
      BackgroundAdminService.sendData({
        'type': 'qr_code_generated',
        'qr_type': 'driver_info',
        'qr_data': qrData,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: تم إنشاء QR لمعلومات السائق: $driverId');
      return qrString;
    } catch (e) {
      debugPrint('$_tag: خطأ في إنشاء QR للسائق: $e');
      return '';
    }
  }
  
  // إنشاء QR Code لمشاركة الرحلة
  static String generateTripShareQR({
    required String tripId,
    required String pickupLocation,
    required String destination,
    required String estimatedTime,
  }) {
    try {
      Map<String, dynamic> qrData = {
        'type': 'trip_share',
        'trip_id': tripId,
        'pickup_location': pickupLocation,
        'destination': destination,
        'estimated_time': estimatedTime,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      String qrString = jsonEncode(qrData);
      
      // إرسال بيانات إنشاء QR للمنصة الإدارية
      BackgroundAdminService.sendData({
        'type': 'qr_code_generated',
        'qr_type': 'trip_share',
        'qr_data': qrData,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: تم إنشاء QR لمشاركة الرحلة: $tripId');
      return qrString;
    } catch (e) {
      debugPrint('$_tag: خطأ في إنشاء QR للمشاركة: $e');
      return '';
    }
  }
  
  // محاكاة قراءة QR Code (بدلاً من الكاميرا)
  static Future<Map<String, dynamic>?> simulateQRScan(String qrData) async {
    try {
      Map<String, dynamic> parsedData = jsonDecode(qrData);
      
      // إرسال بيانات قراءة QR للمنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'qr_code_scanned',
        'scanned_data': parsedData,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: تم قراءة QR: ${parsedData['type']}');
      return parsedData;
    } catch (e) {
      debugPrint('$_tag: خطأ في قراءة QR: $e');
      return null;
    }
  }
  
  // التحقق من صحة QR Code للدفع
  static bool validatePaymentQR(Map<String, dynamic> qrData) {
    try {
      bool isValid = qrData.containsKey('type') &&
          qrData['type'] == 'payment' &&
          qrData.containsKey('amount') &&
          qrData.containsKey('trip_id') &&
          qrData.containsKey('driver_id') &&
          qrData.containsKey('passenger_id');
      
      // إرسال نتيجة التحقق للمنصة الإدارية
      BackgroundAdminService.sendData({
        'type': 'qr_validation',
        'qr_type': 'payment',
        'is_valid': isValid,
        'qr_data': qrData,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      return isValid;
    } catch (e) {
      debugPrint('$_tag: خطأ في التحقق من QR: $e');
      return false;
    }
  }
  
  // معالجة QR Code للدفع
  static Future<bool> processPaymentQR({
    required Map<String, dynamic> qrData,
    required String paymentMethod,
  }) async {
    try {
      if (!validatePaymentQR(qrData)) {
        return false;
      }
      
      // محاكاة معالجة الدفع
      await Future.delayed(const Duration(seconds: 2));
      
      // إرسال بيانات معالجة الدفع للمنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'payment_processed',
        'qr_data': qrData,
        'payment_method': paymentMethod,
        'status': 'success',
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: تم معالجة الدفع بنجاح: ${qrData['trip_id']}');
      return true;
    } catch (e) {
      debugPrint('$_tag: خطأ في معالجة الدفع: $e');
      
      // إرسال بيانات فشل الدفع للمنصة الإدارية
      BackgroundAdminService.sendData({
        'type': 'payment_processed',
        'qr_data': qrData,
        'payment_method': paymentMethod,
        'status': 'failed',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      return false;
    }
  }
  
  // إنشاء QR Code لزين كاش
  static String generateZainCashQR({
    required String amount,
    required String merchantId,
    required String transactionId,
  }) {
    try {
      Map<String, dynamic> qrData = {
        'type': 'zaincash_payment',
        'amount': amount,
        'merchant_id': merchantId,
        'transaction_id': transactionId,
        'currency': 'IQD',
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      String qrString = jsonEncode(qrData);
      
      // إرسال بيانات إنشاء QR لزين كاش للمنصة الإدارية
      BackgroundAdminService.sendData({
        'type': 'zaincash_qr_generated',
        'qr_data': qrData,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: تم إنشاء QR لزين كاش: $transactionId');
      return qrString;
    } catch (e) {
      debugPrint('$_tag: خطأ في إنشاء QR لزين كاش: $e');
      return '';
    }
  }
  
  // إحصائيات استخدام QR Code
  static Future<Map<String, int>> getQRUsageStats() async {
    try {
      // محاكاة إحصائيات الاستخدام
      Map<String, int> stats = {
        'payment_qr_generated': 150,
        'driver_info_qr_generated': 45,
        'trip_share_qr_generated': 89,
        'zaincash_qr_generated': 120,
        'successful_scans': 380,
        'failed_scans': 24,
      };
      
      // إرسال الإحصائيات للمنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'qr_usage_stats',
        'stats': stats,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      return stats;
    } catch (e) {
      debugPrint('$_tag: خطأ في الحصول على إحصائيات QR: $e');
      return {};
    }
  }
}

