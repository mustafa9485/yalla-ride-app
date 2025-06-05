import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/theme_config.dart';

/// شاشة الخطوة الرابعة من تسجيل حساب السائق: المراجعة والتأكيد
/// تعرض ملخص جميع البيانات التي تم إدخالها في الخطوات السابقة
/// وتسمح للمستخدم بتأكيد التسجيل
class DriverSignupStep4Screen extends StatefulWidget {
  const DriverSignupStep4Screen({Key? key}) : super(key: key);

  @override
  State<DriverSignupStep4Screen> createState() => _DriverSignupStep4ScreenState();
}

class _DriverSignupStep4ScreenState extends State<DriverSignupStep4Screen> {
  bool _isLoading = false;
  bool _termsAccepted = false;

  // دالة تأكيد التسجيل
  void _confirmSignup() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى الموافقة على الشروط والأحكام'),
          backgroundColor: ThemeConfig.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // استرجاع البيانات من الخطوات السابقة
    final Map<String, dynamic> driverData = 
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    
    // هنا سيتم إضافة منطق إنشاء حساب السائق باستخدام Supabase
    // وتخزين بيانات السائق مع تحديد role كـ "driver"
    
    // محاكاة تأخير لعملية إنشاء الحساب
    await Future.delayed(const Duration(seconds: 3));
    
    setState(() {
      _isLoading = false;
    });
    
    // عرض رسالة نجاح
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('تم إنشاء الحساب بنجاح'),
          content: const Text(
            'تم إرسال طلب التسجيل بنجاح. سيتم مراجعة بياناتك ومستنداتك من قبل الإدارة وسيتم إشعارك عند الموافقة على حسابك.',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/login', 
                  (route) => false,
                );
              },
              child: const Text('موافق'),
            ),
          ],
        ),
      );
    }
  }

  // دالة الرجوع إلى الخطوة السابقة
  void _goToPreviousStep() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // استرجاع البيانات من الخطوات السابقة
    final Map<String, dynamic> driverData = 
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // مؤشر الخطوات
                _buildStepIndicator(4),
                const SizedBox(height: ThemeConfig.spacingLarge),
                
                // عنوان الخطوة
                Text(
                  'الخطوة 4: المراجعة والتأكيد',
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSizeLarge,
                    fontWeight: ThemeConfig.fontWeightBold,
                    color: ThemeConfig.primaryColor,
                  ),
                ),
                const SizedBox(height: ThemeConfig.spacingMedium),
                
                // نص وصفي
                Text(
                  'يرجى مراجعة بياناتك والموافقة على الشروط والأحكام',
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSizeRegular,
                    fontWeight: ThemeConfig.fontWeightRegular,
                    color: ThemeConfig.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: ThemeConfig.spacingXLarge),
                
                // بطاقة ملخص البيانات الشخصية
                _buildSummaryCard(
                  title: 'المعلومات الشخصية',
                  icon: Icons.person,
                  items: [
                    {'label': 'الاسم الكامل', 'value': driverData['fullName']},
                    {'label': 'رقم الهاتف', 'value': driverData['phone']},
                    {'label': 'البريد الإلكتروني', 'value': driverData['email']},
                  ],
                ),
                const SizedBox(height: ThemeConfig.spacingMedium),
                
                // بطاقة ملخص معلومات المركبة
                _buildSummaryCard(
                  title: 'معلومات المركبة',
                  icon: Icons.drive_eta,
                  items: [
                    {'label': 'نوع السيارة', 'value': _getVehicleTypeArabic(driverData['vehicleType'])},
                    {'label': 'موديل السيارة', 'value': driverData['vehicleModel']},
                    {'label': 'رقم اللوحة', 'value': driverData['plateNumber']},
                  ],
                ),
                const SizedBox(height: ThemeConfig.spacingMedium),
                
                // بطاقة ملخص المستندات
                _buildSummaryCard(
                  title: 'المستندات',
                  icon: Icons.description,
                  items: [
                    {'label': 'صورة الهوية', 'value': 'تم الرفع ✓'},
                    {'label': 'رخصة القيادة', 'value': 'تم الرفع ✓'},
                    {'label': 'استمارة السيارة', 'value': 'تم الرفع ✓'},
                    {'label': 'صورة شخصية', 'value': 'تم الرفع ✓'},
                  ],
                ),
                const SizedBox(height: ThemeConfig.spacingXLarge),
                
                // الموافقة على الشروط والأحكام
                Row(
                  children: [
                    Checkbox(
                      value: _termsAccepted,
                      activeColor: ThemeConfig.accentColor,
                      onChanged: (value) {
                        setState(() {
                          _termsAccepted = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _termsAccepted = !_termsAccepted;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: ThemeConfig.fontSizeRegular,
                              color: ThemeConfig.textSecondaryColor,
                            ),
                            children: [
                              const TextSpan(
                                text: 'أوافق على ',
                              ),
                              TextSpan(
                                text: 'الشروط والأحكام',
                                style: TextStyle(
                                  color: ThemeConfig.accentColor,
                                  fontWeight: ThemeConfig.fontWeightSemiBold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              const TextSpan(
                                text: ' وسياسة الخصوصية',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ThemeConfig.spacingXXLarge),
                
                // أزرار التنقل بين الخطوات
                Row(
                  children: [
                    // زر الرجوع للخطوة السابقة
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _goToPreviousStep,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: ThemeConfig.accentColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
                            ),
                          ),
                          child: Text(
                            'السابق',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: ThemeConfig.fontWeightMedium,
                              color: ThemeConfig.accentColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: ThemeConfig.spacingMedium),
                    // زر تأكيد التسجيل
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _confirmSignup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeConfig.accentColor,
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
                                  'تأكيد التسجيل',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
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
    );
  }
  
  // دالة تحويل نوع السيارة إلى العربية
  String _getVehicleTypeArabic(String type) {
    switch (type) {
      case 'economy':
        return 'اقتصادي';
      case 'comfort':
        return 'مريح';
      case 'luxury':
        return 'فاخر';
      default:
        return type;
    }
  }
  
  // دالة بناء بطاقة ملخص البيانات
  Widget _buildSummaryCard({
    required String title,
    required IconData icon,
    required List<Map<String, String>> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: ThemeConfig.lightShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان البطاقة
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: ThemeConfig.accentColor,
              ),
              const SizedBox(width: ThemeConfig.spacingSmall),
              Text(
                title,
                style: TextStyle(
                  fontSize: ThemeConfig.fontSizeMedium,
                  fontWeight: ThemeConfig.fontWeightSemiBold,
                  color: ThemeConfig.textPrimaryColor,
                ),
              ),
            ],
          ),
          const Divider(height: ThemeConfig.spacingLarge),
          // عناصر البطاقة
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: ThemeConfig.spacingSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['label'] ?? '',
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSizeRegular,
                    fontWeight: ThemeConfig.fontWeightRegular,
                    color: ThemeConfig.textSecondaryColor,
                  ),
                ),
                Text(
                  item['value'] ?? '',
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSizeRegular,
                    fontWeight: ThemeConfig.fontWeightMedium,
                    color: ThemeConfig.textPrimaryColor,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
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
