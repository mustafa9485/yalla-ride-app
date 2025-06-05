import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/theme_config.dart';

/// شاشة البداية (Splash Screen)
/// تظهر عند بدء تشغيل التطبيق وتعرض شعار التطبيق لبضع ثوانٍ
/// ثم تنتقل تلقائياً إلى شاشة الترحيب أو الشاشة الرئيسية حسب حالة تسجيل الدخول
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // الانتقال إلى شاشة الترحيب بعد 3 ثوانٍ
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // شعار التطبيق
            Image.asset(
              'assets/images/logo.png',
              width: 200,
              height: 200,
            ),
            const SizedBox(height: ThemeConfig.spacingLarge),
            // اسم التطبيق
            Text(
              'يلا رايد',
              style: TextStyle(
                fontSize: 32,
                fontWeight: ThemeConfig.fontWeightBold,
                color: ThemeConfig.primaryColor,
              ),
            ),
            const SizedBox(height: ThemeConfig.spacingMedium),
            // شعار التطبيق
            Text(
              'خدمة تاكسي موثوقة في الفلوجة',
              style: TextStyle(
                fontSize: ThemeConfig.fontSizeMedium,
                fontWeight: ThemeConfig.fontWeightRegular,
                color: ThemeConfig.textSecondaryColor,
              ),
            ),
            const SizedBox(height: ThemeConfig.spacingXXLarge),
            // مؤشر التحميل
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ThemeConfig.accentColor),
            ),
          ],
        ),
      ),
    );
  }
}
