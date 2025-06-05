import 'package:flutter_dotenv/flutter_dotenv.dart';

/// تكوين التطبيق الرئيسي
/// يحتوي على جميع المتغيرات البيئية والإعدادات العامة للتطبيق
class AppConfig {
  // مفاتيح Supabase
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get supabaseServiceRoleKey => dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

  // مفتاح Mapbox
  static String get mapboxAccessToken => dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

  // مفتاح OneSignal
  static String get oneSignalAppId => dotenv.env['ONESIGNAL_APP_ID'] ?? '';

  // مفتاح Resend
  static String get resendApiKey => dotenv.env['RESEND_API_KEY'] ?? '';

  // رابط المنصة الإدارية
  static String get adminPanelUrl => dotenv.env['ADMIN_PANEL_URL'] ?? 'https://lwqmlpnv.manus.space';
  
  // مفتاح API للمنصة الإدارية
  static String get adminPlatformApiKey => dotenv.env['ADMIN_API_KEY'] ?? 'yalla-ride-admin-2025';

  // إعدادات عامة للتطبيق
  static const String appName = 'يلا رايد';
  static const String appVersion = '1.0.0';
  static const bool isProduction = false;
  static const String defaultLanguage = 'ar';
  static const String supportEmail = 'support@yallaride.com';
  
  // إعدادات الخريطة
  static const double defaultLatitude = 33.3482; // بغداد
  static const double defaultLongitude = 44.3776; // بغداد
  static const double defaultZoom = 12.0;
  
  // إعدادات العمولة
  static const double commissionRateInCity = 500.0; // دينار عراقي
  static const double commissionRateBetweenCities = 1000.0; // دينار عراقي
  static const double plusSubscriptionFee = 25000.0; // دينار عراقي شهرياً
  
  // إعدادات زين كاش
  static const String zainCashMerchantNumber = "07801234567";
  static const String zainCashMerchantName = "يلا رايد";
  
  // حدود الدفع
  static const double minPaymentAmount = 1000.0; // دينار عراقي
  static const double maxPaymentAmount = 1000000.0; // دينار عراقي
  
  // إعدادات الإشعارات
  static const bool enablePushNotifications = true;
  static const bool enableEmailNotifications = true;
  static const bool enableSMSNotifications = true;
  
  // إعدادات الأمان
  static const int sessionTimeoutMinutes = 60;
  static const int maxLoginAttempts = 5;
  static const int otpExpiryMinutes = 5;
  
  // URLs مهمة
  static const String privacyPolicyUrl = 'https://yallaride.com/privacy';
  static const String termsOfServiceUrl = 'https://yallaride.com/terms';
  static const String helpCenterUrl = 'https://yallaride.com/help';
}

