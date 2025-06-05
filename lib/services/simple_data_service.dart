import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yalla_ride_app/services/background_admin_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// خدمة قاعدة البيانات المبسطة
/// تستخدم SharedPreferences و HTTP بدلاً من Supabase لتجنب مشاكل التكوين
class SimpleDataService {
  static const String _tag = 'SimpleDataService';
  
  // مفاتيح التخزين المحلي
  static const String _usersKey = 'users_data';
  static const String _tripsKey = 'trips_data';
  static const String _paymentsKey = 'payments_data';
  static const String _driversKey = 'drivers_data';
  static const String _passengersKey = 'passengers_data';
  
  // الحصول على SharedPreferences
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }
  
  // حفظ بيانات المستخدم
  static Future<bool> saveUser(Map<String, dynamic> userData) async {
    try {
      SharedPreferences prefs = await _getPrefs();
      List<String> users = prefs.getStringList(_usersKey) ?? [];
      
      // البحث عن المستخدم الموجود
      int existingIndex = -1;
      for (int i = 0; i < users.length; i++) {
        Map<String, dynamic> user = jsonDecode(users[i]);
        if (user['id'] == userData['id']) {
          existingIndex = i;
          break;
        }
      }
      
      String userJson = jsonEncode(userData);
      
      if (existingIndex != -1) {
        users[existingIndex] = userJson; // تحديث المستخدم الموجود
      } else {
        users.add(userJson); // إضافة مستخدم جديد
      }
      
      bool success = await prefs.setStringList(_usersKey, users);
      
      if (success) {
        // إرسال بيانات المستخدم للمنصة الإدارية
        await BackgroundAdminService.sendData({
          'type': 'user_saved',
          'user_data': userData,
          'timestamp': DateTime.now().toIso8601String(),
        });
        
        debugPrint('$_tag: تم حفظ بيانات المستخدم: ${userData['id']}');
      }
      
      return success;
    } catch (e) {
      debugPrint('$_tag: خطأ في حفظ بيانات المستخدم: $e');
      return false;
    }
  }
  
  // الحصول على بيانات المستخدم
  static Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      SharedPreferences prefs = await _getPrefs();
      List<String> users = prefs.getStringList(_usersKey) ?? [];
      
      for (String userJson in users) {
        Map<String, dynamic> user = jsonDecode(userJson);
        if (user['id'] == userId) {
          return user;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('$_tag: خطأ في الحصول على بيانات المستخدم: $e');
      return null;
    }
  }
  
  // حفظ بيانات الرحلة
  static Future<bool> saveTrip(Map<String, dynamic> tripData) async {
    try {
      SharedPreferences prefs = await _getPrefs();
      List<String> trips = prefs.getStringList(_tripsKey) ?? [];
      
      tripData['timestamp'] = DateTime.now().toIso8601String();
      String tripJson = jsonEncode(tripData);
      trips.add(tripJson);
      
      bool success = await prefs.setStringList(_tripsKey, trips);
      
      if (success) {
        // إرسال بيانات الرحلة للمنصة الإدارية
        await BackgroundAdminService.sendData({
          'type': 'trip_saved',
          'trip_data': tripData,
          'timestamp': DateTime.now().toIso8601String(),
        });
        
        debugPrint('$_tag: تم حفظ بيانات الرحلة: ${tripData['id']}');
      }
      
      return success;
    } catch (e) {
      debugPrint('$_tag: خطأ في حفظ بيانات الرحلة: $e');
      return false;
    }
  }
  
  // الحصول على جميع الرحلات
  static Future<List<Map<String, dynamic>>> getAllTrips() async {
    try {
      SharedPreferences prefs = await _getPrefs();
      List<String> trips = prefs.getStringList(_tripsKey) ?? [];
      
      List<Map<String, dynamic>> tripsList = [];
      for (String tripJson in trips) {
        tripsList.add(jsonDecode(tripJson));
      }
      
      return tripsList;
    } catch (e) {
      debugPrint('$_tag: خطأ في الحصول على الرحلات: $e');
      return [];
    }
  }
  
  // الحصول على رحلات مستخدم معين
  static Future<List<Map<String, dynamic>>> getUserTrips(String userId) async {
    try {
      List<Map<String, dynamic>> allTrips = await getAllTrips();
      return allTrips.where((trip) => 
          trip['driver_id'] == userId || trip['passenger_id'] == userId).toList();
    } catch (e) {
      debugPrint('$_tag: خطأ في الحصول على رحلات المستخدم: $e');
      return [];
    }
  }
  
  // حفظ بيانات الدفع
  static Future<bool> savePayment(Map<String, dynamic> paymentData) async {
    try {
      SharedPreferences prefs = await _getPrefs();
      List<String> payments = prefs.getStringList(_paymentsKey) ?? [];
      
      paymentData['timestamp'] = DateTime.now().toIso8601String();
      String paymentJson = jsonEncode(paymentData);
      payments.add(paymentJson);
      
      bool success = await prefs.setStringList(_paymentsKey, payments);
      
      if (success) {
        // إرسال بيانات الدفع للمنصة الإدارية
        await BackgroundAdminService.sendData({
          'type': 'payment_saved',
          'payment_data': paymentData,
          'timestamp': DateTime.now().toIso8601String(),
        });
        
        debugPrint('$_tag: تم حفظ بيانات الدفع: ${paymentData['transaction_id']}');
      }
      
      return success;
    } catch (e) {
      debugPrint('$_tag: خطأ في حفظ بيانات الدفع: $e');
      return false;
    }
  }
  
  // الحصول على جميع المدفوعات
  static Future<List<Map<String, dynamic>>> getAllPayments() async {
    try {
      SharedPreferences prefs = await _getPrefs();
      List<String> payments = prefs.getStringList(_paymentsKey) ?? [];
      
      List<Map<String, dynamic>> paymentsList = [];
      for (String paymentJson in payments) {
        paymentsList.add(jsonDecode(paymentJson));
      }
      
      return paymentsList;
    } catch (e) {
      debugPrint('$_tag: خطأ في الحصول على المدفوعات: $e');
      return [];
    }
  }
  
  // حفظ بيانات السائق
  static Future<bool> saveDriver(Map<String, dynamic> driverData) async {
    try {
      SharedPreferences prefs = await _getPrefs();
      List<String> drivers = prefs.getStringList(_driversKey) ?? [];
      
      // البحث عن السائق الموجود
      int existingIndex = -1;
      for (int i = 0; i < drivers.length; i++) {
        Map<String, dynamic> driver = jsonDecode(drivers[i]);
        if (driver['id'] == driverData['id']) {
          existingIndex = i;
          break;
        }
      }
      
      driverData['last_updated'] = DateTime.now().toIso8601String();
      String driverJson = jsonEncode(driverData);
      
      if (existingIndex != -1) {
        drivers[existingIndex] = driverJson;
      } else {
        drivers.add(driverJson);
      }
      
      bool success = await prefs.setStringList(_driversKey, drivers);
      
      if (success) {
        // إرسال بيانات السائق للمنصة الإدارية
        await BackgroundAdminService.sendData({
          'type': 'driver_saved',
          'driver_data': driverData,
          'timestamp': DateTime.now().toIso8601String(),
        });
        
        debugPrint('$_tag: تم حفظ بيانات السائق: ${driverData['id']}');
      }
      
      return success;
    } catch (e) {
      debugPrint('$_tag: خطأ في حفظ بيانات السائق: $e');
      return false;
    }
  }
  
  // الحصول على جميع السائقين
  static Future<List<Map<String, dynamic>>> getAllDrivers() async {
    try {
      SharedPreferences prefs = await _getPrefs();
      List<String> drivers = prefs.getStringList(_driversKey) ?? [];
      
      List<Map<String, dynamic>> driversList = [];
      for (String driverJson in drivers) {
        driversList.add(jsonDecode(driverJson));
      }
      
      return driversList;
    } catch (e) {
      debugPrint('$_tag: خطأ في الحصول على السائقين: $e');
      return [];
    }
  }
  
  // الحصول على السائقين المتاحين
  static Future<List<Map<String, dynamic>>> getAvailableDrivers() async {
    try {
      List<Map<String, dynamic>> allDrivers = await getAllDrivers();
      return allDrivers.where((driver) => 
          driver['status'] == 'available' || driver['status'] == 'online').toList();
    } catch (e) {
      debugPrint('$_tag: خطأ في الحصول على السائقين المتاحين: $e');
      return [];
    }
  }
  
  // إحصائيات البيانات
  static Future<Map<String, int>> getDataStats() async {
    try {
      List<Map<String, dynamic>> users = [];
      List<Map<String, dynamic>> trips = await getAllTrips();
      List<Map<String, dynamic>> payments = await getAllPayments();
      List<Map<String, dynamic>> drivers = await getAllDrivers();
      
      // حساب المستخدمين من الرحلات
      Set<String> uniqueUsers = {};
      for (var trip in trips) {
        if (trip['driver_id'] != null) uniqueUsers.add(trip['driver_id']);
        if (trip['passenger_id'] != null) uniqueUsers.add(trip['passenger_id']);
      }
      
      Map<String, int> stats = {
        'total_users': uniqueUsers.length,
        'total_trips': trips.length,
        'total_payments': payments.length,
        'total_drivers': drivers.length,
        'available_drivers': drivers.where((d) => 
            d['status'] == 'available' || d['status'] == 'online').length,
        'completed_trips': trips.where((t) => t['status'] == 'completed').length,
        'successful_payments': payments.where((p) => p['status'] == 'success').length,
      };
      
      // إرسال الإحصائيات للمنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'data_stats',
        'stats': stats,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      return stats;
    } catch (e) {
      debugPrint('$_tag: خطأ في الحصول على إحصائيات البيانات: $e');
      return {};
    }
  }
  
  // مسح جميع البيانات
  static Future<bool> clearAllData() async {
    try {
      SharedPreferences prefs = await _getPrefs();
      
      await prefs.remove(_usersKey);
      await prefs.remove(_tripsKey);
      await prefs.remove(_paymentsKey);
      await prefs.remove(_driversKey);
      await prefs.remove(_passengersKey);
      
      // إرسال إشعار مسح البيانات للمنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'data_cleared',
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: تم مسح جميع البيانات');
      return true;
    } catch (e) {
      debugPrint('$_tag: خطأ في مسح البيانات: $e');
      return false;
    }
  }
  
  // إنشاء بيانات تجريبية للاختبار
  static Future<void> createSampleData() async {
    // إنشاء سائقين تجريبيين
    await saveDriver({
      'id': 'driver_001',
      'name': 'أحمد محمد',
      'phone': '07901234567',
      'vehicle_type': 'سيدان',
      'vehicle_model': 'تويوتا كامري 2020',
      'license_plate': 'بغداد 12345',
      'status': 'available',
      'rating': 4.8,
      'total_trips': 150,
    });
    
    await saveDriver({
      'id': 'driver_002',
      'name': 'علي حسن',
      'phone': '07801234567',
      'vehicle_type': 'SUV',
      'vehicle_model': 'هونداي توسان 2021',
      'license_plate': 'بغداد 67890',
      'status': 'online',
      'rating': 4.6,
      'total_trips': 89,
    });
    
    // إنشاء رحلات تجريبية
    await saveTrip({
      'id': 'trip_001',
      'driver_id': 'driver_001',
      'passenger_id': 'passenger_001',
      'pickup_location': 'الكرادة',
      'destination': 'المنصور',
      'status': 'completed',
      'fare': 5000,
      'distance': 8.5,
      'duration': 25,
    });
    
    // إنشاء مدفوعات تجريبية
    await savePayment({
      'transaction_id': 'txn_001',
      'trip_id': 'trip_001',
      'amount': 5000,
      'method': 'zaincash',
      'status': 'success',
      'user_id': 'passenger_001',
    });
    
    debugPrint('$_tag: تم إنشاء البيانات التجريبية');
  }
}

