import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/theme_config.dart';

/// الشاشة الرئيسية للراكب
/// تعرض الخريطة، وخيارات طلب الرحلة، والرحلات السابقة
class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({Key? key}) : super(key: key);

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const PassengerMapScreen(),
    const PassengerTripsScreen(),
    const PassengerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: ThemeConfig.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'رحلاتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}

/// شاشة الخريطة للراكب
class PassengerMapScreen extends StatefulWidget {
  const PassengerMapScreen({Key? key}) : super(key: key);

  @override
  State<PassengerMapScreen> createState() => _PassengerMapScreenState();
}

class _PassengerMapScreenState extends State<PassengerMapScreen> {
  bool _isBottomSheetExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخريطة (ستتم إضافة Mapbox لاحقاً)
          Container(
            color: Colors.grey[200],
            child: const Center(
              child: Text(
                'هنا ستظهر الخريطة',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          
          // زر الموقع الحالي
          Positioned(
            bottom: _isBottomSheetExpanded ? 320 : 220,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'locationButton',
              backgroundColor: Colors.white,
              mini: true,
              onPressed: () {
                // تحديث الموقع الحالي
              },
              child: Icon(
                Icons.my_location,
                color: ThemeConfig.primaryColor,
              ),
            ),
          ),
          
          // البطاقة السفلية لطلب الرحلة
          _buildBottomSheet(),
        ],
      ),
    );
  }

  // دالة بناء البطاقة السفلية
  Widget _buildBottomSheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! < -10) {
            setState(() {
              _isBottomSheetExpanded = true;
            });
          } else if (details.primaryDelta! > 10) {
            setState(() {
              _isBottomSheetExpanded = false;
            });
          }
        },
        child: Container(
          height: _isBottomSheetExpanded ? 350 : 250,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // مؤشر السحب
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              
              // عنوان البطاقة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'إلى أين تريد الذهاب؟',
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSizeLarge,
                    fontWeight: ThemeConfig.fontWeightBold,
                    color: ThemeConfig.textPrimaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // حقل البحث عن الوجهة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/passenger_destination_search');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: ThemeConfig.primaryColor,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'ابحث عن وجهتك',
                          style: TextStyle(
                            fontSize: ThemeConfig.fontSizeRegular,
                            color: ThemeConfig.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // الوجهات المحفوظة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الوجهات المحفوظة',
                      style: TextStyle(
                        fontSize: ThemeConfig.fontSizeMedium,
                        fontWeight: ThemeConfig.fontWeightSemiBold,
                        color: ThemeConfig.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildSavedLocationItem(
                      icon: Icons.home,
                      title: 'المنزل',
                      address: 'حي القادسية، الفلوجة',
                    ),
                    const Divider(),
                    _buildSavedLocationItem(
                      icon: Icons.work,
                      title: 'العمل',
                      address: 'شارع الجمهورية، الفلوجة',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة بناء عنصر الوجهة المحفوظة
  Widget _buildSavedLocationItem({
    required IconData icon,
    required String title,
    required String address,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/passenger_ride_request');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ThemeConfig.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: ThemeConfig.primaryColor,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeRegular,
                      fontWeight: ThemeConfig.fontWeightMedium,
                      color: ThemeConfig.textPrimaryColor,
                    ),
                  ),
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeSmall,
                      color: ThemeConfig.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: ThemeConfig.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// شاشة الرحلات للراكب
class PassengerTripsScreen extends StatelessWidget {
  const PassengerTripsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رحلاتي'),
        centerTitle: true,
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              labelColor: ThemeConfig.primaryColor,
              unselectedLabelColor: ThemeConfig.textSecondaryColor,
              indicatorColor: ThemeConfig.primaryColor,
              tabs: const [
                Tab(text: 'الرحلات السابقة'),
                Tab(text: 'الرحلات المجدولة'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // قائمة الرحلات السابقة
                  _buildPastTripsList(),
                  
                  // قائمة الرحلات المجدولة
                  _buildScheduledTripsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة بناء قائمة الرحلات السابقة
  Widget _buildPastTripsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildTripItem(
          date: '${index + 1} يونيو 2025',
          time: '${10 + index}:00 ص',
          from: 'حي القادسية، الفلوجة',
          to: 'شارع الجمهورية، الفلوجة',
          price: '${(index + 1) * 1000} د.ع',
          status: 'مكتملة',
          statusColor: ThemeConfig.successColor,
        );
      },
    );
  }

  // دالة بناء قائمة الرحلات المجدولة
  Widget _buildScheduledTripsList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد رحلات مجدولة',
            style: TextStyle(
              fontSize: ThemeConfig.fontSizeMedium,
              fontWeight: ThemeConfig.fontWeightMedium,
              color: ThemeConfig.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // دالة بناء عنصر الرحلة
  Widget _buildTripItem({
    required String date,
    required String time,
    required String from,
    required String to,
    required String price,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // التاريخ والوقت والحالة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$date - $time',
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSizeSmall,
                    color: ThemeConfig.textSecondaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeXSmall,
                      fontWeight: ThemeConfig.fontWeightMedium,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // نقطة الانطلاق
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: ThemeConfig.primaryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    from,
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeRegular,
                      color: ThemeConfig.textPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Container(
                width: 1,
                height: 20,
                color: Colors.grey[300],
              ),
            ),
            
            // نقطة الوصول
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: ThemeConfig.accentColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    to,
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeRegular,
                      color: ThemeConfig.textPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // السعر وزر التفاصيل
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'السعر: $price',
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSizeMedium,
                    fontWeight: ThemeConfig.fontWeightSemiBold,
                    color: ThemeConfig.textPrimaryColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // الانتقال إلى صفحة تفاصيل الرحلة
                  },
                  child: Text(
                    'التفاصيل',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeRegular,
                      fontWeight: ThemeConfig.fontWeightMedium,
                      color: ThemeConfig.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// شاشة الملف الشخصي للراكب
class PassengerProfileScreen extends StatelessWidget {
  const PassengerProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حسابي'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // الانتقال إلى صفحة الإعدادات
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // معلومات الملف الشخصي
            _buildProfileHeader(),
            const SizedBox(height: 24),
            
            // قائمة الخيارات
            _buildMenuSection(
              title: 'الحساب',
              items: [
                {
                  'icon': Icons.person,
                  'title': 'المعلومات الشخصية',
                  'route': '/passenger_edit_profile',
                },
                {
                  'icon': Icons.location_on,
                  'title': 'العناوين المحفوظة',
                  'route': '/passenger_saved_locations',
                },
                {
                  'icon': Icons.payment,
                  'title': 'طرق الدفع',
                  'route': '/passenger_payment_methods',
                },
              ],
            ),
            const SizedBox(height: 16),
            
            _buildMenuSection(
              title: 'الدعم',
              items: [
                {
                  'icon': Icons.help,
                  'title': 'المساعدة',
                  'route': '/help_center',
                },
                {
                  'icon': Icons.info,
                  'title': 'عن التطبيق',
                  'route': '/about_app',
                },
                {
                  'icon': Icons.star,
                  'title': 'تقييم التطبيق',
                  'route': null,
                },
              ],
            ),
            const SizedBox(height: 24),
            
            // زر تسجيل الخروج
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // تسجيل الخروج
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('تسجيل الخروج'),
                      content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('إلغاء'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/welcome',
                              (route) => false,
                            );
                          },
                          child: const Text('تسجيل الخروج'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة بناء رأس الملف الشخصي
  Widget _buildProfileHeader() {
    return Column(
      children: [
        // صورة المستخدم
        CircleAvatar(
          radius: 50,
          backgroundColor: ThemeConfig.primaryColor.withOpacity(0.1),
          child: Text(
            'أح',
            style: TextStyle(
              fontSize: 30,
              fontWeight: ThemeConfig.fontWeightBold,
              color: ThemeConfig.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // اسم المستخدم
        Text(
          'أحمد محمد',
          style: TextStyle(
            fontSize: ThemeConfig.fontSizeLarge,
            fontWeight: ThemeConfig.fontWeightBold,
            color: ThemeConfig.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        
        // رقم الهاتف
        Text(
          '+964 7801234567',
          style: TextStyle(
            fontSize: ThemeConfig.fontSizeRegular,
            color: ThemeConfig.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 16),
        
        // التقييم
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.star,
              color: Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              '4.8',
              style: TextStyle(
                fontSize: ThemeConfig.fontSizeRegular,
                fontWeight: ThemeConfig.fontWeightMedium,
                color: ThemeConfig.textPrimaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // دالة بناء قسم القائمة
  Widget _buildMenuSection({
    required String title,
    required List<Map<String, dynamic>> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: ThemeConfig.fontSizeMedium,
              fontWeight: ThemeConfig.fontWeightSemiBold,
              color: ThemeConfig.textPrimaryColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Icon(
                  item['icon'] as IconData,
                  color: ThemeConfig.primaryColor,
                ),
                title: Text(item['title'] as String),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
                onTap: () {
                  if (item['route'] != null) {
                    Navigator.pushNamed(context, item['route'] as String);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
