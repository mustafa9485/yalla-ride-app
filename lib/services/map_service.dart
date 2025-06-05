import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/app_config.dart';
import 'package:yalla_ride_app/services/background_admin_service.dart';
import 'package:yalla_ride_app/services/simple_location_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// خدمة الخرائط والموقع المبسطة
/// تستخدم SimpleLocationService بدلاً من Mapbox لتجنب مشاكل التكوين
class MapService {
  static const String _tag = 'MapService';
  
  // الحصول على الموقع الحالي
  static Future<Map<String, double>?> getCurrentLocation() async {
    return await SimpleLocationService.getCurrentLocation();
  }
  
  // حساب المسافة بين نقطتين
  static double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return SimpleLocationService.calculateDistance(
      startLatitude: startLatitude,
      startLongitude: startLongitude,
      endLatitude: endLatitude,
      endLongitude: endLongitude,
    );
  }
  
  // تتبع الموقع المباشر
  static Stream<Map<String, double>> trackLocation() {
    return SimpleLocationService.trackLocation();
  }
  
  // الحصول على عنوان من الإحداثيات
  static Future<String> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    return await SimpleLocationService.getAddressFromCoordinates(
      latitude: latitude,
      longitude: longitude,
    );
  }
  
  // حساب تكلفة الرحلة بناءً على المسافة
  static double calculateFare({
    required double distanceInMeters,
    required bool isWithinCity,
  }) {
    return SimpleLocationService.calculateFare(
      distanceInMeters: distanceInMeters,
      isWithinCity: isWithinCity,
    );
  }
  
  // التحقق من وجود الموقع داخل المدينة
  static bool isLocationWithinCity({
    required double latitude,
    required double longitude,
  }) {
    return SimpleLocationService.isLocationWithinCity(
      latitude: latitude,
      longitude: longitude,
    );
  }
  
  // بدء تتبع رحلة
  static Future<void> startTripTracking({
    required String tripId,
    required String driverId,
    required String passengerId,
  }) async {
    return await SimpleLocationService.startTripTracking(
      tripId: tripId,
      driverId: driverId,
      passengerId: passengerId,
    );
  }
  
  // إنهاء تتبع رحلة
  static Future<void> endTripTracking({
    required String tripId,
    required double totalDistance,
    required Duration tripDuration,
  }) async {
    return await SimpleLocationService.endTripTracking(
      tripId: tripId,
      totalDistance: totalDistance,
      tripDuration: tripDuration,
    );
  }
}

