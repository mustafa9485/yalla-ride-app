import 'package:flutter/material.dart';

/// تكوين السمة (الألوان، الخطوط) للتطبيق
class ThemeConfig {
  // الألوان الرئيسية
  static const Color primaryColor = Color(0xFF5D4B9C); // بنفسجي/رمادي داكن
  static const Color accentColor = Color(0xFFF7941D); // برتقالي
  static const Color goldColor = Color(0xFFFFD700); // ذهبي
  static const Color greenColor = Color(0xFF4CAF50); // أخضر
  
  // ألوان الخلفية
  static const Color backgroundColor = Colors.white; // خلفية بيضاء كما طلب المستخدم
  static const Color cardColor = Color(0xFFF5F5F5); // رمادي فاتح للبطاقات
  
  // ألوان النصوص
  static const Color textPrimaryColor = Color(0xFF333333); // نص أساسي داكن
  static const Color textSecondaryColor = Color(0xFF666666); // نص ثانوي
  static const Color textLightColor = Color(0xFF999999); // نص خفيف
  
  // ألوان الحالة
  static const Color successColor = Color(0xFF4CAF50); // نجاح
  static const Color errorColor = Color(0xFFE53935); // خطأ
  static const Color warningColor = Color(0xFFFFC107); // تحذير
  static const Color infoColor = Color(0xFF2196F3); // معلومات
  
  // ألوان الأزرار
  static const Color buttonPrimaryColor = Color(0xFF5D4B9C); // زر أساسي
  static const Color buttonSecondaryColor = Color(0xFFF7941D); // زر ثانوي
  static const Color buttonDisabledColor = Color(0xFFCCCCCC); // زر معطل
  
  // ألوان الحدود
  static const Color borderColor = Color(0xFFE0E0E0); // حدود
  static const Color dividerColor = Color(0xFFEEEEEE); // فاصل
  
  // ألوان الظلال
  static const Color shadowColor = Color(0x1A000000); // ظل
  
  // الخطوط
  static const String fontFamily = 'Cairo'; // خط عربي مناسب
  
  // أحجام الخطوط
  static const double fontSizeXSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeRegular = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;
  
  // أوزان الخطوط
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;
  
  // الحواف
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusRegular = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 24.0;
  static const double borderRadiusCircular = 100.0;
  
  // المسافات
  static const double spacingXXSmall = 2.0;
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingRegular = 12.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
  static const double spacingXXLarge = 48.0;
  
  // الظلال
  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: shadowColor.withOpacity(0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: shadowColor.withOpacity(0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> get heavyShadow => [
    BoxShadow(
      color: shadowColor.withOpacity(0.2),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
  
  // إنشاء سمة التطبيق
  static ThemeData get lightTheme => ThemeData(
    primaryColor: primaryColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      background: backgroundColor,
      surface: backgroundColor,
      error: errorColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: fontFamily,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: fontSizeXXLarge,
        fontWeight: fontWeightBold,
        color: textPrimaryColor,
      ),
      displayMedium: TextStyle(
        fontSize: fontSizeXLarge,
        fontWeight: fontWeightBold,
        color: textPrimaryColor,
      ),
      displaySmall: TextStyle(
        fontSize: fontSizeLarge,
        fontWeight: fontWeightSemiBold,
        color: textPrimaryColor,
      ),
      headlineMedium: TextStyle(
        fontSize: fontSizeMedium,
        fontWeight: fontWeightSemiBold,
        color: textPrimaryColor,
      ),
      bodyLarge: TextStyle(
        fontSize: fontSizeRegular,
        fontWeight: fontWeightRegular,
        color: textPrimaryColor,
      ),
      bodyMedium: TextStyle(
        fontSize: fontSizeRegular,
        fontWeight: fontWeightRegular,
        color: textSecondaryColor,
      ),
      bodySmall: TextStyle(
        fontSize: fontSizeSmall,
        fontWeight: fontWeightRegular,
        color: textLightColor,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonPrimaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: fontWeightMedium,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLarge,
          vertical: spacingRegular,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusRegular),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: buttonPrimaryColor,
        side: const BorderSide(color: buttonPrimaryColor),
        textStyle: const TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: fontWeightMedium,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLarge,
          vertical: spacingRegular,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusRegular),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: buttonPrimaryColor,
        textStyle: const TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: fontWeightMedium,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMedium,
          vertical: spacingSmall,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(spacingMedium),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
        borderSide: const BorderSide(color: primaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
        borderSide: const BorderSide(color: errorColor),
      ),
      hintStyle: const TextStyle(
        fontSize: fontSizeRegular,
        fontWeight: fontWeightRegular,
        color: textLightColor,
      ),
      labelStyle: const TextStyle(
        fontSize: fontSizeRegular,
        fontWeight: fontWeightMedium,
        color: textSecondaryColor,
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadiusRegular),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textPrimaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: fontSizeLarge,
        fontWeight: fontWeightSemiBold,
        color: textPrimaryColor,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: textLightColor,
      selectedLabelStyle: TextStyle(
        fontSize: fontSizeSmall,
        fontWeight: fontWeightMedium,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: fontSizeSmall,
        fontWeight: fontWeightRegular,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: spacingMedium,
    ),
  );
}
