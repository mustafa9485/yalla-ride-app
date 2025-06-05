import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/theme_config.dart';

/// شاشة إنشاء حساب الراكب (Passenger Signup Screen)
/// تسمح للمستخدم بإنشاء حساب جديد كراكب
/// تتضمن حقول الاسم الكامل، رقم الهاتف، البريد الإلكتروني (اختياري)، وكلمة المرور
class PassengerSignupScreen extends StatefulWidget {
  const PassengerSignupScreen({Key? key}) : super(key: key);

  @override
  State<PassengerSignupScreen> createState() => _PassengerSignupScreenState();
}

class _PassengerSignupScreenState extends State<PassengerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // دالة إنشاء حساب الراكب
  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // هنا سيتم إضافة منطق إنشاء حساب الراكب باستخدام Supabase
      // وتخزين بيانات الراكب مع تحديد role كـ "passenger"
      
      // محاكاة تأخير لعملية إنشاء الحساب
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
        title: const Text('إنشاء حساب راكب'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(ThemeConfig.spacingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان الشاشة
                  Text(
                    'أهلاً بك في يلا رايد!',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeXLarge,
                      fontWeight: ThemeConfig.fontWeightBold,
                      color: ThemeConfig.primaryColor,
                    ),
                  ),
                  const SizedBox(height: ThemeConfig.spacingMedium),
                  // نص وصفي
                  Text(
                    'يرجى إدخال بياناتك لإنشاء حساب راكب جديد',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeRegular,
                      fontWeight: ThemeConfig.fontWeightRegular,
                      color: ThemeConfig.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: ThemeConfig.spacingXLarge),
                  // حقل الاسم الكامل
                  TextFormField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الكامل',
                      hintText: 'أدخل اسمك الكامل',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال الاسم الكامل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: ThemeConfig.spacingMedium),
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
                  // حقل البريد الإلكتروني (اختياري)
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني (اختياري)',
                      hintText: 'أدخل بريدك الإلكتروني',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        // التحقق من صحة البريد الإلكتروني إذا تم إدخاله
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'يرجى إدخال بريد إلكتروني صحيح';
                        }
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
                      if (value.length < 6) {
                        return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: ThemeConfig.spacingMedium),
                  // حقل تأكيد كلمة المرور
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة المرور',
                      hintText: 'أعد إدخال كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى تأكيد كلمة المرور';
                      }
                      if (value != _passwordController.text) {
                        return 'كلمات المرور غير متطابقة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: ThemeConfig.spacingXLarge),
                  // زر إنشاء الحساب
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
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
                              'إنشاء حساب',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: ThemeConfig.spacingLarge),
                  // رابط تسجيل الدخول
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
                          Navigator.pushReplacementNamed(context, '/login');
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
        ),
      ),
    );
  }
}
