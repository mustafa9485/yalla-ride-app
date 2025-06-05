import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/theme_config.dart';

/// شاشة الخطوة الثانية من تسجيل حساب السائق: معلومات المركبة
/// تتضمن حقول نوع السيارة، الموديل، رقم اللوحة
class DriverSignupStep2Screen extends StatefulWidget {
  const DriverSignupStep2Screen({Key? key}) : super(key: key);

  @override
  State<DriverSignupStep2Screen> createState() => _DriverSignupStep2ScreenState();
}

class _DriverSignupStep2ScreenState extends State<DriverSignupStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleModelController = TextEditingController();
  final _plateNumberController = TextEditingController();
  String _selectedVehicleType = 'economy'; // القيمة الافتراضية

  @override
  void dispose() {
    _vehicleModelController.dispose();
    _plateNumberController.dispose();
    super.dispose();
  }

  // دالة الانتقال إلى الخطوة التالية
  void _goToNextStep() {
    if (_formKey.currentState!.validate()) {
      // استرجاع البيانات من الخطوة السابقة
      final Map<String, dynamic> driverData = 
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      
      // إضافة بيانات المركبة
      driverData['vehicleType'] = _selectedVehicleType;
      driverData['vehicleModel'] = _vehicleModelController.text;
      driverData['plateNumber'] = _plateNumberController.text;
      
      // الانتقال إلى الخطوة التالية مع تمرير البيانات
      Navigator.pushNamed(
        context, 
        '/driver_signup_step3',
        arguments: driverData,
      );
    }
  }

  // دالة الرجوع إلى الخطوة السابقة
  void _goToPreviousStep() {
    Navigator.pop(context);
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
                  _buildStepIndicator(2),
                  const SizedBox(height: ThemeConfig.spacingLarge),
                  
                  // عنوان الخطوة
                  Text(
                    'الخطوة 2: معلومات المركبة',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeLarge,
                      fontWeight: ThemeConfig.fontWeightBold,
                      color: ThemeConfig.primaryColor,
                    ),
                  ),
                  const SizedBox(height: ThemeConfig.spacingMedium),
                  
                  // نص وصفي
                  Text(
                    'يرجى إدخال معلومات مركبتك',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeRegular,
                      fontWeight: ThemeConfig.fontWeightRegular,
                      color: ThemeConfig.textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: ThemeConfig.spacingXLarge),
                  
                  // اختيار نوع السيارة
                  Text(
                    'نوع السيارة',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeMedium,
                      fontWeight: ThemeConfig.fontWeightMedium,
                      color: ThemeConfig.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: ThemeConfig.spacingSmall),
                  
                  // خيارات نوع السيارة
                  Row(
                    children: [
                      Expanded(
                        child: _buildVehicleTypeOption(
                          title: 'اقتصادي',
                          value: 'economy',
                          icon: Icons.directions_car,
                        ),
                      ),
                      const SizedBox(width: ThemeConfig.spacingMedium),
                      Expanded(
                        child: _buildVehicleTypeOption(
                          title: 'مريح',
                          value: 'comfort',
                          icon: Icons.airline_seat_recline_normal,
                        ),
                      ),
                      const SizedBox(width: ThemeConfig.spacingMedium),
                      Expanded(
                        child: _buildVehicleTypeOption(
                          title: 'فاخر',
                          value: 'luxury',
                          icon: Icons.star,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: ThemeConfig.spacingLarge),
                  
                  // حقل موديل السيارة
                  TextFormField(
                    controller: _vehicleModelController,
                    decoration: const InputDecoration(
                      labelText: 'موديل السيارة',
                      hintText: 'مثال: تويوتا كامري 2020',
                      prefixIcon: Icon(Icons.car_repair),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال موديل السيارة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: ThemeConfig.spacingMedium),
                  
                  // حقل رقم اللوحة
                  TextFormField(
                    controller: _plateNumberController,
                    decoration: const InputDecoration(
                      labelText: 'رقم اللوحة',
                      hintText: 'أدخل رقم لوحة السيارة',
                      prefixIcon: Icon(Icons.confirmation_number),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال رقم اللوحة';
                      }
                      return null;
                    },
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
                              'التالي: المستندات',
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
      ),
    );
  }
  
  // دالة بناء خيار نوع السيارة
  Widget _buildVehicleTypeOption({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedVehicleType == value;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedVehicleType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(ThemeConfig.spacingMedium),
        decoration: BoxDecoration(
          color: isSelected ? ThemeConfig.accentColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(ThemeConfig.borderRadiusRegular),
          border: Border.all(
            color: isSelected ? ThemeConfig.accentColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? ThemeConfig.accentColor : Colors.grey,
              size: 28,
            ),
            const SizedBox(height: ThemeConfig.spacingSmall),
            Text(
              title,
              style: TextStyle(
                fontSize: ThemeConfig.fontSizeSmall,
                fontWeight: isSelected ? ThemeConfig.fontWeightSemiBold : ThemeConfig.fontWeightRegular,
                color: isSelected ? ThemeConfig.accentColor : ThemeConfig.textSecondaryColor,
              ),
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
