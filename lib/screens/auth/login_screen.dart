import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/theme_config.dart';

/// شاشة تسجيل الدخول الموحدة (Unified Login Screen)
/// تسمح للمستخدمين الحاليين (ركاب وسائقين) بتسجيل الدخول
/// بعد التحقق من صحة بيانات الدخول، يتم قراءة دور المستخدم من قاعدة البيانات
/// وتوجيهه إلى الشاشة الرئيسية المناسبة (للراكب أو للسائق)
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // دالة تسجيل الدخول
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // هنا سيتم إضافة منطق تسجيل الدخول باستخدام Supabase
      // وقراءة دور المستخدم وتوجيهه للشاشة المناسبة
      
      // محاكاة تأخير لعملية تسجيل الدخول
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isLoading = false;
      });
      
      // للاختبار فقط: توجيه المستخدم إلى الشاشة الرئيسية للراكب
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/passenger_home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: AppBar(
        title: const Text('تسجيل الدخول'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(ThemeConfig.spacingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: ThemeConfig.spacingLarge),
                  // شعار التطبيق
                  Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: ThemeConfig.spacingLarge),
                  // عنوان الشاشة
                  Text(
                    'مرحباً بعودتك!',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeXLarge,
                      fontWeight: ThemeConfig.fontWeightBold,
                      color: ThemeConfig.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ThemeConfig.spacingMedium),
                  // نص وصفي
                  Text(
                    'يرجى إدخال بيانات تسجيل الدخول الخاصة بك',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeRegular,
                      fontWeight: ThemeConfig.fontWeightRegular,
                      color: ThemeConfig.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ThemeConfig.spacingXLarge),
                  // حقل رقم الهاتف
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف',
                      hintText: 'أدخل رقم هاتفك',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رقم الهاتف';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: ThemeConfig.spacingMedium),
                  // حقل كلمة المرور
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      hintText: 'أدخل كلمة المرور',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: ThemeConfig.spacingMedium),
                  // رابط نسيت كلمة المرور
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot_password');
                      },
                      child: Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(
                          fontSize: ThemeConfig.fontSizeRegular,
                          fontWeight: ThemeConfig.fontWeightMedium,
                          color: ThemeConfig.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: ThemeConfig.spacingLarge),
                  // زر تسجيل الدخول
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConfig.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: ThemeConfig.spacingXLarge),
                  // رابط إنشاء حساب جديد
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ليس لديك حساب؟',
                        style: TextStyle(
                          fontSize: ThemeConfig.fontSizeRegular,
                          fontWeight: ThemeConfig.fontWeightRegular,
                          color: ThemeConfig.textSecondaryColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/welcome');
                        },
                        child: Text(
                          'إنشاء حساب جديد',
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
        ),
      ),
    );
  }
}
