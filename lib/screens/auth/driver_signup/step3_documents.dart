import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/theme_config.dart';

/// شاشة الخطوة الثالثة من تسجيل حساب السائق: رفع المستندات
/// تتضمن رفع صورة الهوية، رخصة القيادة، استمارة السيارة، وصورة شخصية
class DriverSignupStep3Screen extends StatefulWidget {
  const DriverSignupStep3Screen({Key? key}) : super(key: key);

  @override
  State<DriverSignupStep3Screen> createState() => _DriverSignupStep3ScreenState();
}

class _DriverSignupStep3ScreenState extends State<DriverSignupStep3Screen> {
  bool _idUploaded = false;
  bool _licenseUploaded = false;
  bool _registrationUploaded = false;
  bool _profilePhotoUploaded = false;

  // دالة الانتقال إلى الخطوة التالية
  void _goToNextStep() {
    // التحقق من رفع جميع المستندات المطلوبة
    if (_idUploaded && _licenseUploaded && _registrationUploaded && _profilePhotoUploaded) {
      // استرجاع البيانات من الخطوات السابقة
      final Map<String, dynamic> driverData = 
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      
      // إضافة حالة رفع المستندات
      driverData['documentsUploaded'] = true;
      
      // الانتقال إلى الخطوة التالية مع تمرير البيانات
      Navigator.pushNamed(
        context, 
        '/driver_signup_step4',
        arguments: driverData,
      );
    } else {
      // عرض رسالة خطأ إذا لم يتم رفع جميع المستندات
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى رفع جميع المستندات المطلوبة'),
          backgroundColor: ThemeConfig.errorColor,
        ),
      );
    }
  }

  // دالة الرجوع إلى الخطوة السابقة
  void _goToPreviousStep() {
    Navigator.pop(context);
  }

  // دالة محاكاة رفع المستند
  void _simulateUpload(String documentType) {
    // عرض مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري رفع المستند...'),
          ],
        ),
      ),
    );

    // محاكاة تأخير لعملية الرفع
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // إغلاق مؤشر التحميل
      
      setState(() {
        switch (documentType) {
          case 'id':
            _idUploaded = true;
            break;
          case 'license':
            _licenseUploaded = true;
            break;
          case 'registration':
            _registrationUploaded = true;
            break;
          case 'photo':
            _profilePhotoUploaded = true;
            break;
        }
      });
      
      // عرض رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفع المستند بنجاح'),
          backgroundColor: ThemeConfig.successColor,
        ),
      );
    });
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // مؤشر الخطوات
                _buildStepIndicator(3),
                const SizedBox(height: ThemeConfig.spacingLarge),
                
                // عنوان الخطوة
                Text(
                  'الخطوة 3: المستندات المطلوبة',
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSizeLarge,
                    fontWeight: ThemeConfig.fontWeightBold,
                    color: ThemeConfig.primaryColor,
                  ),
                ),
                const SizedBox(height: ThemeConfig.spacingMedium),
                
                // نص وصفي
                Text(
                  'يرجى رفع المستندات التالية للتحقق من هويتك',
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSizeRegular,
                    fontWeight: ThemeConfig.fontWeightRegular,
                    color: ThemeConfig.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: ThemeConfig.spacingXLarge),
                
                // رفع صورة الهوية
                _buildDocumentUploadCard(
                  title: 'صورة الهوية الشخصية',
                  description: 'صورة واضحة للوجهين',
                  icon: Icons.credit_card,
                  isUploaded: _idUploaded,
                  onTap: () => _simulateUpload('id'),
                ),
                const SizedBox(height: ThemeConfig.spacingMedium),
                
                // رفع رخصة القيادة
                _buildDocumentUploadCard(
                  title: 'رخصة القيادة',
                  description: 'صورة واضحة للوجهين',
                  icon: Icons.drive_eta,
                  isUploaded: _licenseUploaded,
                  onTap: () => _simulateUpload('license'),
                ),
                const SizedBox(height: ThemeConfig.spacingMedium),
                
                // رفع استمارة السيارة
                _buildDocumentUploadCard(
                  title: 'استمارة السيارة',
                  description: 'صورة واضحة وسارية المفعول',
                  icon: Icons.description,
                  isUploaded: _registrationUploaded,
                  onTap: () => _simulateUpload('registration'),
                ),
                const SizedBox(height: ThemeConfig.spacingMedium),
                
                // رفع صورة شخصية
                _buildDocumentUploadCard(
                  title: 'صورة شخصية',
                  description: 'صورة واضحة للوجه',
                  icon: Icons.person,
                  isUploaded: _profilePhotoUploaded,
                  onTap: () => _simulateUpload('photo'),
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
                          onPressed: _goToPreviousStep,
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
                    // زر الانتقال للخطوة التالية
                    Expanded(
                      child: SizedBox(
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
                            'التالي: المراجعة',
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
  
  // دالة بناء بطاقة رفع المستند
  Widget _buildDocumentUploadCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isUploaded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isUploaded ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusMedium),
          border: Border.all(
            color: isUploaded ? ThemeConfig.successColor : Colors.grey.shade300,
            width: isUploaded ? 2 : 1,
          ),
          boxShadow: ThemeConfig.lightShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isUploaded 
                    ? ThemeConfig.successColor.withOpacity(0.1) 
                    : ThemeConfig.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusCircular),
              ),
              child: Icon(
                isUploaded ? Icons.check : icon,
                size: 24,
                color: isUploaded ? ThemeConfig.successColor : ThemeConfig.accentColor,
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
                      fontSize: ThemeConfig.fontSizeMedium,
                      fontWeight: ThemeConfig.fontWeightSemiBold,
                      color: ThemeConfig.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: ThemeConfig.spacingXSmall),
                  Text(
                    isUploaded ? 'تم الرفع بنجاح' : description,
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeSmall,
                      fontWeight: ThemeConfig.fontWeightRegular,
                      color: isUploaded 
                          ? ThemeConfig.successColor 
                          : ThemeConfig.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isUploaded ? Icons.check_circle : Icons.upload,
              size: 24,
              color: isUploaded ? ThemeConfig.successColor : ThemeConfig.accentColor,
            ),
          ],
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
