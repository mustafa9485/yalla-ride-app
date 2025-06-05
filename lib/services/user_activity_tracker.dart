import 'package:flutter/material.dart';
import 'package:yalla_ride_app/services/background_admin_service.dart';
import 'dart:async';

/// خدمة تتبع أنشطة المستخدم بشكل خفي
/// تعمل في الخلفية دون علم المستخدم
class UserActivityTracker {
  static Timer? _periodicTimer;
  static String? _currentUserId;
  static String? _currentUserRole;
  static DateTime? _sessionStartTime;
  
  // بدء تتبع النشاط
  static void startTracking(String userId, String userRole) {
    _currentUserId = userId;
    _currentUserRole = userRole;
    _sessionStartTime = DateTime.now();
    
    // إرسال بداية الجلسة
    _sendSessionStart();
    
    // بدء الإرسال الدوري للإحصائيات
    _startPeriodicReporting();
  }
  
  // إيقاف تتبع النشاط
  static void stopTracking() {
    _periodicTimer?.cancel();
    
    // إرسال نهاية الجلسة
    _sendSessionEnd();
    
    _currentUserId = null;
    _currentUserRole = null;
    _sessionStartTime = null;
  }
  
  // تتبع حدث معين
  static void trackEvent(String eventName, {Map<String, dynamic>? data}) {
    if (_currentUserId == null) return;
    
    final eventData = {
      'user_id': _currentUserId,
      'user_role': _currentUserRole,
      'event_name': eventName,
      'event_data': data ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    BackgroundAdminService.trackEvent(eventName, eventData);
  }
  
  // تتبع تغيير الشاشة
  static void trackScreenChange(String screenName) {
    trackEvent('screen_change', data: {'screen_name': screenName});
  }
  
  // تتبع طلب رحلة
  static void trackRideRequest(Map<String, dynamic> rideData) {
    trackEvent('ride_request', data: rideData);
  }
  
  // تتبع قبول رحلة
  static void trackRideAccept(Map<String, dynamic> rideData) {
    trackEvent('ride_accept', data: rideData);
  }
  
  // تتبع إكمال رحلة
  static void trackRideComplete(Map<String, dynamic> rideData) {
    trackEvent('ride_complete', data: rideData);
  }
  
  // تتبع عملية دفع
  static void trackPayment(Map<String, dynamic> paymentData) {
    trackEvent('payment', data: paymentData);
  }
  
  // تتبع تقييم
  static void trackRating(Map<String, dynamic> ratingData) {
    trackEvent('rating', data: ratingData);
  }
  
  // تتبع خطأ في التطبيق
  static void trackError(String errorType, String errorMessage, {Map<String, dynamic>? context}) {
    trackEvent('app_error', data: {
      'error_type': errorType,
      'error_message': errorMessage,
      'context': context ?? {},
    });
  }
  
  // إرسال بداية الجلسة
  static void _sendSessionStart() {
    if (_currentUserId == null) return;
    
    final sessionData = {
      'user_id': _currentUserId,
      'user_role': _currentUserRole,
      'session_start': _sessionStartTime?.toIso8601String(),
      'action': 'session_start',
    };
    
    BackgroundAdminService.sendSessionData(sessionData);
  }
  
  // إرسال نهاية الجلسة
  static void _sendSessionEnd() {
    if (_currentUserId == null || _sessionStartTime == null) return;
    
    final sessionDuration = DateTime.now().difference(_sessionStartTime!).inSeconds;
    
    final sessionData = {
      'user_id': _currentUserId,
      'user_role': _currentUserRole,
      'session_start': _sessionStartTime?.toIso8601String(),
      'session_end': DateTime.now().toIso8601String(),
      'session_duration': sessionDuration,
      'action': 'session_end',
    };
    
    BackgroundAdminService.sendSessionData(sessionData);
  }
  
  // بدء الإرسال الدوري للإحصائيات
  static void _startPeriodicReporting() {
    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_currentUserId != null && _currentUserRole != null) {
        BackgroundAdminService.sendPeriodicStats(_currentUserId!, _currentUserRole!);
      }
    });
  }
}

/// خدمة تتبع الموقع بشكل خفي
class LocationTracker {
  static Timer? _locationTimer;
  static String? _currentUserId;
  
  // بدء تتبع الموقع
  static void startLocationTracking(String userId) {
    _currentUserId = userId;
    
    // إرسال الموقع كل 30 ثانية
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _sendCurrentLocation();
    });
  }
  
  // إيقاف تتبع الموقع
  static void stopLocationTracking() {
    _locationTimer?.cancel();
    _currentUserId = null;
  }
  
  // إرسال الموقع الحالي
  static void _sendCurrentLocation() {
    if (_currentUserId == null) return;
    
    // في التطبيق الحقيقي، سيتم الحصول على الموقع الفعلي
    final locationData = {
      'user_id': _currentUserId,
      'latitude': 33.3482, // موقع وهمي - الفلوجة
      'longitude': 43.7743,
      'accuracy': 10.0,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    BackgroundAdminService.sendLocationData(locationData);
  }
  
  // إرسال موقع محدد
  static void sendLocation(double latitude, double longitude, {double? accuracy}) {
    if (_currentUserId == null) return;
    
    final locationData = {
      'user_id': _currentUserId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy ?? 10.0,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    BackgroundAdminService.sendLocationData(locationData);
  }
}

