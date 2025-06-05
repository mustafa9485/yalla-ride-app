import 'package:flutter/material.dart';
import 'package:yalla_ride_app/services/user_activity_tracker.dart';

/// مراقب التنقل الخفي
/// يتتبع تغييرات الشاشات دون علم المستخدم
class NavigationObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    
    if (route is PageRoute) {
      final routeName = route.settings.name ?? 'unknown';
      UserActivityTracker.trackScreenChange(routeName);
    }
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    
    if (previousRoute is PageRoute) {
      final routeName = previousRoute.settings.name ?? 'unknown';
      UserActivityTracker.trackScreenChange(routeName);
    }
  }
  
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    
    if (newRoute is PageRoute) {
      final routeName = newRoute.settings.name ?? 'unknown';
      UserActivityTracker.trackScreenChange(routeName);
    }
  }
}

/// خدمة التتبع الشامل
/// تدمج جميع خدمات التتبع في مكان واحد
class ComprehensiveTracker {
  static final NavigationObserver _navigationObserver = NavigationObserver();
  
  // الحصول على مراقب التنقل
  static NavigationObserver get navigationObserver => _navigationObserver;
  
  // بدء التتبع الشامل
  static void startComprehensiveTracking(String userId, String userRole) {
    // بدء تتبع النشاط
    UserActivityTracker.startTracking(userId, userRole);
    
    // بدء تتبع الموقع
    LocationTracker.startLocationTracking(userId);
    
    // تتبع بداية استخدام التطبيق
    UserActivityTracker.trackEvent('app_start');
  }
  
  // إيقاف التتبع الشامل
  static void stopComprehensiveTracking() {
    // تتبع إغلاق التطبيق
    UserActivityTracker.trackEvent('app_close');
    
    // إيقاف تتبع النشاط
    UserActivityTracker.stopTracking();
    
    // إيقاف تتبع الموقع
    LocationTracker.stopLocationTracking();
  }
  
  // تتبع تسجيل الدخول
  static void trackLogin(String userId, String userRole, String loginMethod) {
    UserActivityTracker.trackEvent('login', data: {
      'user_id': userId,
      'user_role': userRole,
      'login_method': loginMethod,
    });
    
    // بدء التتبع الشامل بعد تسجيل الدخول
    startComprehensiveTracking(userId, userRole);
  }
  
  // تتبع تسجيل الخروج
  static void trackLogout(String userId, String userRole) {
    UserActivityTracker.trackEvent('logout', data: {
      'user_id': userId,
      'user_role': userRole,
    });
    
    // إيقاف التتبع الشامل بعد تسجيل الخروج
    stopComprehensiveTracking();
  }
  
  // تتبع تسجيل مستخدم جديد
  static void trackRegistration(String userId, String userRole, Map<String, dynamic> userData) {
    UserActivityTracker.trackEvent('registration', data: {
      'user_id': userId,
      'user_role': userRole,
      'user_data': userData,
    });
  }
}

