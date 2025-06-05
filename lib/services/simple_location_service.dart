import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/app_config.dart';
import 'package:yalla_ride_app/services/background_admin_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

/// خدمة الموقع المبسطة
/// تستخدم محاكاة للموقع بدلاً من GPS الحقيقي لتجنب مشاكل المكتبات
class SimpleLocationService {
  static const String _tag = 'SimpleLocationService';
  
  // إحداثيات بغداد كنقطة مرجعية
  static const double _baghdadLat = 33.3152;
  static const double _baghdadLng = 44.3661;
  
  // متغيرات لمحاكاة الموقع
  static double _currentLat = _baghdadLat;
  static double _currentLng = _baghdadLng;
  static bool _isLocationEnabled = true;
  
  // الحصول على الموقع الحالي (محاكاة)
  static Future<Map<String, double>?> getCurrentLocation() async {
    try {
      if (!_isLocationEnabled) {
        debugPrint('$_tag: خدمة الموقع معطلة');
        return null;
      }
      
      // محاكاة تغيير طفيف في الموقع
      Random random = Random();
      double latOffset = (random.nextDouble() - 0.5) * 0.01; // تغيير ±0.005 درجة
      double lngOffset = (random.nextDouble() - 0.5) * 0.01;
      
      _currentLat = _baghdadLat + latOffset;
      _currentLng = _baghdadLng + lngOffset;
      
      Map<String, double> location = {
        'latitude': _currentLat,
        'longitude': _currentLng,
        'accuracy': 10.0,
      };
      
      // إرسال بيانات الموقع للمنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'location_update',
        'latitude': _currentLat,
        'longitude': _currentLng,
        'accuracy': 10.0,
        'timestamp': DateTime.now().toIso8601String(),
        'source': 'simulated',
      });
      
      debugPrint('$_tag: الموقع المحاكي: $_currentLat, $_currentLng');
      return location;
    } catch (e) {
      debugPrint('$_tag: خطأ في الحصول على الموقع: $e');
      return null;
    }
  }
  
  // حساب المسافة بين نقطتين (بالمتر)
  static double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    const double earthRadius = 6371000; // نصف قطر الأرض بالمتر
    
    double lat1Rad = startLatitude * (pi / 180);
    double lat2Rad = endLatitude * (pi / 180);
    double deltaLatRad = (endLatitude - startLatitude) * (pi / 180);
    double deltaLngRad = (endLongitude - startLongitude) * (pi / 180);
    
    double a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLngRad / 2) * sin(deltaLngRad / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  // تتبع الموقع المباشر (محاكاة)
  static Stream<Map<String, double>> trackLocation() async* {
    while (_isLocationEnabled) {
      Map<String, double>? location = await getCurrentLocation();
      if (location != null) {
        yield location;
      }
      await Future.delayed(const Duration(seconds: 5)); // تحديث كل 5 ثواني
    }
  }
  
  // الحصول على عنوان من الإحداثيات (مبسط)
  static Future<String> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // محاكاة عناوين بغداد
      List<String> areas = [
        'الكرادة',
        'الجادرية',
        'المنصور',
        'الكاظمية',
        'الأعظمية',
        'الدورة',
        'الشعلة',
        'حي الجامعة',
        'الزعفرانية',
        'المدينة'
      ];
      
      Random random = Random();
      String area = areas[random.nextInt(areas.length)];
      
      return '$area، بغداد، العراق';
    } catch (e) {
      debugPrint('$_tag: خطأ في الحصول على العنوان: $e');
      return 'بغداد، العراق';
    }
  }
  
  // حساب تكلفة الرحلة بناءً على المسافة
  static double calculateFare({
    required double distanceInMeters,
    required bool isWithinCity,
  }) {
    double distanceInKm = distanceInMeters / 1000;
    double baseFare = isWithinCity ? 2000.0 : 3000.0; // دينار عراقي
    double perKmRate = isWithinCity ? 500.0 : 750.0; // دينار عراقي لكل كيلومتر
    
    double totalFare = baseFare + (distanceInKm * perKmRate);
    
    // إرسال بيانات حساب التكلفة للمنصة الإدارية
    BackgroundAdminService.sendData({
      'type': 'fare_calculation',
      'distance_km': distanceInKm,
      'is_within_city': isWithinCity,
      'base_fare': baseFare,
      'per_km_rate': perKmRate,
      'total_fare': totalFare,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    return totalFare;
  }
  
  // التحقق من وجود الموقع داخل المدينة
  static bool isLocationWithinCity({
    required double latitude,
    required double longitude,
  }) {
    const double cityRadius = 50000; // 50 كيلومتر
    
    double distance = calculateDistance(
      startLatitude: latitude,
      startLongitude: longitude,
      endLatitude: _baghdadLat,
      endLongitude: _baghdadLng,
    );
    
    return distance <= cityRadius;
  }
  
  // بدء تتبع رحلة
  static Future<void> startTripTracking({
    required String tripId,
    required String driverId,
    required String passengerId,
  }) async {
    try {
      // إرسال بداية تتبع الرحلة للمنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'trip_tracking_started',
        'trip_id': tripId,
        'driver_id': driverId,
        'passenger_id': passengerId,
        'start_location': {
          'latitude': _currentLat,
          'longitude': _currentLng,
        },
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: بدء تتبع الرحلة: $tripId');
    } catch (e) {
      debugPrint('$_tag: خطأ في بدء تتبع الرحلة: $e');
    }
  }
  
  // إنهاء تتبع رحلة
  static Future<void> endTripTracking({
    required String tripId,
    required double totalDistance,
    required Duration tripDuration,
  }) async {
    try {
      // إرسال نهاية تتبع الرحلة للمنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'trip_tracking_ended',
        'trip_id': tripId,
        'end_location': {
          'latitude': _currentLat,
          'longitude': _currentLng,
        },
        'total_distance': totalDistance,
        'trip_duration_minutes': tripDuration.inMinutes,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      debugPrint('$_tag: انتهاء تتبع الرحلة: $tripId');
    } catch (e) {
      debugPrint('$_tag: خطأ في إنهاء تتبع الرحلة: $e');
    }
  }
  
  // تبديل حالة خدمة الموقع
  static void toggleLocationService(bool enabled) {
    _isLocationEnabled = enabled;
    debugPrint('$_tag: خدمة الموقع ${enabled ? "مفعلة" : "معطلة"}');
  }
  
  // الحصول على حالة خدمة الموقع
  static bool isLocationServiceEnabled() {
    return _isLocationEnabled;
  }
  
  // محاكاة رحلة من نقطة إلى أخرى
  static Future<List<Map<String, double>>> simulateTrip({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    int steps = 10,
  }) async {
    List<Map<String, double>> tripPoints = [];
    
    for (int i = 0; i <= steps; i++) {
      double progress = i / steps;
      double currentLat = startLat + (endLat - startLat) * progress;
      double currentLng = startLng + (endLng - startLng) * progress;
      
      tripPoints.add({
        'latitude': currentLat,
        'longitude': currentLng,
        'accuracy': 10.0,
        'progress': progress,
      });
      
      // إرسال نقطة الرحلة للمنصة الإدارية
      await BackgroundAdminService.sendData({
        'type': 'trip_point',
        'latitude': currentLat,
        'longitude': currentLng,
        'progress': progress,
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      await Future.delayed(const Duration(seconds: 2)); // توقف قصير بين النقاط
    }
    
    return tripPoints;
  }
}

