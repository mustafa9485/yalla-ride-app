import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/theme_config.dart';

/// شاشة الخطوة الأولى من تسجيل حساب السائق: المعلومات الأساسية
/// تتضمن حقول الاسم الكامل، رقم الهاتف، البريد الإلكتروني، وكلمة المرور
class DriverSignupStep1Screen extends StatefulWidget {
  const DriverSignupStep1Screen({Key? key}) : super(key: key);

  @override
  State<DriverSignupStep1Screen> createState() => _DriverSignupStep1ScreenState();
}

class _DriverSignupStep1ScreenState extends State<DriverSignupStep1Screen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
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

  // دالة الانتقال إلى الخطوة التالية
  void _goToNextStep() {
    if (_formKey.currentState!.validate()) {
      // تخزين البيانات في حالة التطبيق أو تمريرها للخطوة التالية
      final driverData = {
        'fullName': _fullNameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      };
      
      // الانتقال إلى الخطوة التالية مع تمرير البيانات
      Navigator.pushNamed(
        context, 
        '/driver_signup_step2',
        arguments: driverData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConfig.backgroundColor,
      appBar: AppBar(
        title: const Text('إنشاء حساب سائق'),
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
                  // مؤشر الخطوات
                  _buildStepIndicator(1),
                  const SizedBox(height: ThemeConfig.spacingLarge),
                  
                  // عنوان الخطوة
                  Text(
                    'الخطوة 1: المعلومات الأساسية',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeLarge,
                      fontWeight: ThemeConfig.fontWeightBold,
                      color: ThemeConfig.primaryColor,
                    ),
                  ),
                  const SizedBox(height: ThemeConfig.spacingMedium),
                  
                  // نص وصفي
                  Text(
                    'يرجى إدخال معلوماتك الشخصية',
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
                  
                  // حقل البريد الإلكتروني
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      hintText: 'أدخل بريدك الإلكتروني',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'يرجى إدخال بريد إلكتروني صحيح';
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
                  const SizedBox(height: ThemeConfig.spacingXXLarge),
                  
                  // زر الانتقال للخطوة التالية
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _goToNextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeConfig.accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
                        ),
                      ),
                      child: const Text(
                        'التالي: معلومات المركبة',
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
                            color: ThemeConfig.accentColor,
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
  
  // دالة بناء مؤشر الخطوات
  Widget _buildStepIndicator(int currentStep) {
    return Row(
      children: [
        _buildStepCircle(1, currentStep >= 1),
        _buildStepLine(),
        _buildStepCircle(2, currentStep >= 2),
        _buildStepLine(),
        _buildStepCircle(3, currentStep >= 3),
        _buildStepLine(),
        _buildStepCircle(4, currentStep >= 4),
      ],
    );
  }
  
  // دالة بناء دائرة الخطوة
  Widget _buildStepCircle(int step, bool isActive) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isActive ? ThemeConfig.accentColor : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          step.toString(),
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
  
  // دالة بناء خط الخطوة
  Widget _buildStepLine() {
    return Expanded(
      child: Container(
        height: 2,
        color: Colors.grey.shade300,
      ),
    );
  }
}
