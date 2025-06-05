import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/theme_config.dart';

/// شاشة الترحيب واختيار الدور (Welcome/Role Selection Screen)
/// تظهر بعد شاشة البداية وتسمح للمستخدم باختيار دوره (راكب أو سائق)
/// أو تسجيل الدخول إذا كان لديه حساب بالفعل
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: ThemeConfig.spacingXLarge),
              // شعار التطبيق
              Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: ThemeConfig.spacingLarge),
              // عنوان الترحيب
              Text(
                'أهلاً بك في يلا رايد',
                style: TextStyle(
                  fontSize: ThemeConfig.fontSizeXXLarge,
                  fontWeight: ThemeConfig.fontWeightBold,
                  color: ThemeConfig.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThemeConfig.spacingMedium),
              // نص وصفي
              Text(
                'خدمة تاكسي موثوقة في الفلوجة ومحافظة الأنبار',
                style: TextStyle(
                  fontSize: ThemeConfig.fontSizeMedium,
                  fontWeight: ThemeConfig.fontWeightRegular,
                  color: ThemeConfig.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThemeConfig.spacingXXLarge),
              // سؤال اختيار الدور
              Text(
                'كيف تريد استخدام التطبيق؟',
                style: TextStyle(
                  fontSize: ThemeConfig.fontSizeLarge,
                  fontWeight: ThemeConfig.fontWeightSemiBold,
                  color: ThemeConfig.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ThemeConfig.spacingLarge),
              // زر اختيار دور الراكب
              _buildRoleButton(
                context: context,
                title: 'أنا راكب',
                subtitle: 'أريد طلب رحلة',
                icon: Icons.person,
                color: ThemeConfig.primaryColor,
                onTap: () {
                  Navigator.pushNamed(context, '/passenger_signup');
                },
              ),
              const SizedBox(height: ThemeConfig.spacingMedium),
              // زر اختيار دور السائق
              _buildRoleButton(
                context: context,
                title: 'أنا سائق',
                subtitle: 'أريد تقديم خدمة التوصيل',
                icon: Icons.drive_eta,
                color: ThemeConfig.accentColor,
                onTap: () {
                  Navigator.pushNamed(context, '/driver_signup');
                },
              ),
              const Spacer(),
              // رابط تسجيل الدخول للمستخدمين الحاليين
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لديك حساب بالفعل؟',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeRegular,
                      fontWeight: ThemeConfig.fontWeightRegular,
                      color: ThemeConfig.textSecondaryColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: ThemeConfig.fontSizeRegular,
                        fontWeight: ThemeConfig.fontWeightSemiBold,
                        color: ThemeConfig.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة لبناء زر اختيار الدور
  Widget _buildRoleButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(ThemeConfig.spacingLarge),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: ThemeConfig.lightShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusCircular),
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(width: ThemeConfig.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeLarge,
                      fontWeight: ThemeConfig.fontWeightSemiBold,
                      color: ThemeConfig.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: ThemeConfig.spacingXSmall),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeRegular,
                      fontWeight: ThemeConfig.fontWeightRegular,
                      color: ThemeConfig.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
