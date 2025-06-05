import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/theme_config.dart';

/// الشاشة الرئيسية للسائق
/// تعرض الخريطة، وطلبات الرحلات، والإحصائيات، والأرباح
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({Key? key}) : super(key: key);

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const DriverMapScreen(),
    const DriverTripsScreen(),
    const DriverEarningsScreen(),
    const DriverProfileScreen(),
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
        selectedItemColor: ThemeConfig.accentColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'الرحلات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'الأرباح',
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

/// شاشة الخريطة للسائق
class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({Key? key}) : super(key: key);

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  bool _isOnline = false;
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
          
          // زر تبديل الحالة (متصل/غير متصل)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isOnline ? 'متصل' : 'غير متصل',
                      style: TextStyle(
                        fontSize: ThemeConfig.fontSizeMedium,
                        fontWeight: ThemeConfig.fontWeightSemiBold,
                        color: _isOnline ? ThemeConfig.successColor : ThemeConfig.errorColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: _isOnline,
                      activeColor: ThemeConfig.successColor,
                      onChanged: (value) {
                        setState(() {
                          _isOnline = value;
                        });
                      },
                    ),
                  ],
                ),
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
                color: ThemeConfig.accentColor,
              ),
            ),
          ),
          
          // البطاقة السفلية للإحصائيات والطلبات
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
              
              // إحصائيات اليوم
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إحصائيات اليوم',
                      style: TextStyle(
                        fontSize: ThemeConfig.fontSizeLarge,
                        fontWeight: ThemeConfig.fontWeightBold,
                        color: ThemeConfig.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // بطاقات الإحصائيات
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'الرحلات',
                            value: '3',
                            icon: Icons.directions_car,
                            color: ThemeConfig.accentColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            title: 'الأرباح',
                            value: '15,000 د.ع',
                            icon: Icons.account_balance_wallet,
                            color: ThemeConfig.successColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildStatCard(
                            title: 'التقييم',
                            value: '4.8',
                            icon: Icons.star,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // طلبات الرحلات القريبة
                    Text(
                      'طلبات الرحلات القريبة',
                      style: TextStyle(
                        fontSize: ThemeConfig.fontSizeMedium,
                        fontWeight: ThemeConfig.fontWeightSemiBold,
                        color: ThemeConfig.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // قائمة الطلبات
                    _isOnline
                        ? _buildRideRequestItem()
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'قم بتغيير حالتك إلى "متصل" لاستقبال طلبات الرحلات',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: ThemeConfig.fontSizeRegular,
                                  color: ThemeConfig.textSecondaryColor,
                                ),
                              ),
                            ),
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

  // دالة بناء بطاقة الإحصائيات
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: ThemeConfig.fontSizeMedium,
              fontWeight: ThemeConfig.fontWeightBold,
              color: ThemeConfig.textPrimaryColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: ThemeConfig.fontSizeSmall,
              color: ThemeConfig.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // دالة بناء عنصر طلب الرحلة
  Widget _buildRideRequestItem() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/driver_ride_request_details');
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            // المسافة والسعر
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: ThemeConfig.accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '2.5 كم',
                      style: TextStyle(
                        fontSize: ThemeConfig.fontSizeSmall,
                        fontWeight: ThemeConfig.fontWeightMedium,
                        color: ThemeConfig.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  '5,000 د.ع',
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSizeMedium,
                    fontWeight: ThemeConfig.fontWeightBold,
                    color: ThemeConfig.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
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
                    'حي القادسية، الفلوجة',
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
                    'شارع الجمهورية، الفلوجة',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeRegular,
                      color: ThemeConfig.textPrimaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            
            // أزرار القبول والرفض
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // رفض الطلب
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ThemeConfig.errorColor,
                      side: BorderSide(color: ThemeConfig.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('رفض'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // قبول الطلب
                      Navigator.pushNamed(context, '/driver_ride_request_details');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemeConfig.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('قبول'),
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

/// شاشة الرحلات للسائق
class DriverTripsScreen extends StatelessWidget {
  const DriverTripsScreen({Key? key}) : super(key: key);

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
              labelColor: ThemeConfig.accentColor,
              unselectedLabelColor: ThemeConfig.textSecondaryColor,
              indicatorColor: ThemeConfig.accentColor,
              tabs: const [
                Tab(text: 'اليوم'),
                Tab(text: 'السابقة'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // قائمة رحلات اليوم
                  _buildTodayTripsList(),
                  
                  // قائمة الرحلات السابقة
                  _buildPastTripsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة بناء قائمة رحلات اليوم
  Widget _buildTodayTripsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return _buildTripItem(
          time: '${10 + index}:00 ص',
          from: 'حي القادسية، الفلوجة',
          to: 'شارع الجمهورية، الفلوجة',
          price: '${(index + 1) * 5000} د.ع',
          status: index == 0 ? 'جارية' : 'مكتملة',
          statusColor: index == 0 ? ThemeConfig.infoColor : ThemeConfig.successColor,
        );
      },
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
          price: '${(index + 1) * 5000} د.ع',
          status: 'مكتملة',
          statusColor: ThemeConfig.successColor,
        );
      },
    );
  }

  // دالة بناء عنصر الرحلة
  Widget _buildTripItem({
    String? date,
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
                  date != null ? '$date - $time' : time,
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
                  'الأرباح: $price',
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSizeMedium,
                    fontWeight: ThemeConfig.fontWeightSemiBold,
                    color: ThemeConfig.successColor,
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
                      color: ThemeConfig.accentColor,
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

/// شاشة الأرباح للسائق
class DriverEarningsScreen extends StatelessWidget {
  const DriverEarningsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأرباح'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة الأرباح الإجمالية
            _buildEarningsSummaryCard(),
            const SizedBox(height: 24),
            
            // بطاقة العمولة
            _buildCommissionCard(),
            const SizedBox(height: 24),
            
            // تفاصيل الأرباح
            Text(
              'تفاصيل الأرباح',
              style: TextStyle(
                fontSize: ThemeConfig.fontSizeLarge,
                fontWeight: ThemeConfig.fontWeightBold,
                color: ThemeConfig.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // بطاقات الفترات الزمنية
            _buildPeriodCard(
              title: 'اليوم',
              earnings: '15,000',
              trips: '3',
              commission: '1,500',
            ),
            const SizedBox(height: 12),
            _buildPeriodCard(
              title: 'هذا الأسبوع',
              earnings: '75,000',
              trips: '15',
              commission: '7,500',
            ),
            const SizedBox(height: 12),
            _buildPeriodCard(
              title: 'هذا الشهر',
              earnings: '300,000',
              trips: '60',
              commission: '30,000',
            ),
          ],
        ),
      ),
    );
  }

  // دالة بناء بطاقة ملخص الأرباح
  Widget _buildEarningsSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeConfig.accentColor,
            ThemeConfig.accentColor.withOpacity(0.8),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: ThemeConfig.accentColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إجمالي الأرباح',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '300,000 د.ع',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEarningsStat(
                title: 'الرحلات',
                value: '60',
                icon: Icons.directions_car,
              ),
              _buildEarningsStat(
                title: 'العمولة',
                value: '30,000 د.ع',
                icon: Icons.account_balance,
              ),
              _buildEarningsStat(
                title: 'الصافي',
                value: '270,000 د.ع',
                icon: Icons.account_balance_wallet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // دالة بناء إحصائية الأرباح
  Widget _buildEarningsStat({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  // دالة بناء بطاقة العمولة
  Widget _buildCommissionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'العمولة المستحقة',
                style: TextStyle(
                  fontSize: ThemeConfig.fontSizeMedium,
                  fontWeight: ThemeConfig.fontWeightBold,
                  color: ThemeConfig.textPrimaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: ThemeConfig.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'مستحقة',
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSizeXSmall,
                    fontWeight: ThemeConfig.fontWeightMedium,
                    color: ThemeConfig.warningColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '25,000 د.ع',
            style: TextStyle(
              fontSize: 24,
              fontWeight: ThemeConfig.fontWeightBold,
              color: ThemeConfig.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'يجب دفع العمولة قبل 15 يونيو 2025',
            style: TextStyle(
              fontSize: ThemeConfig.fontSizeSmall,
              color: ThemeConfig.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // الانتقال إلى صفحة دفع العمولة
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConfig.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('دفع العمولة'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // الانتقال إلى صفحة اشتراك Plus
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: ThemeConfig.goldColor,
                side: BorderSide(color: ThemeConfig.goldColor),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('اشترك في Plus واحصل على عمولة صفر'),
            ),
          ),
        ],
      ),
    );
  }

  // دالة بناء بطاقة الفترة الزمنية
  Widget _buildPeriodCard({
    required String title,
    required String earnings,
    required String trips,
    required String commission,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPeriodStat(
                title: 'الأرباح',
                value: '$earnings د.ع',
                color: ThemeConfig.successColor,
              ),
              _buildPeriodStat(
                title: 'الرحلات',
                value: trips,
                color: ThemeConfig.accentColor,
              ),
              _buildPeriodStat(
                title: 'العمولة',
                value: '$commission د.ع',
                color: ThemeConfig.warningColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // دالة بناء إحصائية الفترة
  Widget _buildPeriodStat({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: ThemeConfig.fontSizeMedium,
            fontWeight: ThemeConfig.fontWeightBold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: ThemeConfig.fontSizeSmall,
            color: ThemeConfig.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}

/// شاشة الملف الشخصي للسائق
class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({Key? key}) : super(key: key);

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
                  'route': '/driver_edit_profile',
                },
                {
                  'icon': Icons.directions_car,
                  'title': 'معلومات المركبة',
                  'route': '/driver_vehicle_info',
                },
                {
                  'icon': Icons.description,
                  'title': 'المستندات',
                  'route': '/driver_documents',
                },
                {
                  'icon': Icons.account_balance_wallet,
                  'title': 'طرق الدفع',
                  'route': '/driver_payment_methods',
                },
              ],
            ),
            const SizedBox(height: 16),
            
            _buildMenuSection(
              title: 'الاشتراك',
              items: [
                {
                  'icon': Icons.star,
                  'title': 'اشتراك Plus',
                  'route': '/driver_plus_subscription',
                  'badge': 'احصل على عمولة صفر',
                },
                {
                  'icon': Icons.account_balance,
                  'title': 'دفع العمولة',
                  'route': '/driver_commission_payment',
                  'badge': 'مستحقة',
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
                  'icon': Icons.star_rate,
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
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: ThemeConfig.accentColor.withOpacity(0.1),
              child: Text(
                'مع',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: ThemeConfig.fontWeightBold,
                  color: ThemeConfig.accentColor,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ThemeConfig.successColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // اسم المستخدم
        Text(
          'محمد علي',
          style: TextStyle(
            fontSize: ThemeConfig.fontSizeLarge,
            fontWeight: ThemeConfig.fontWeightBold,
            color: ThemeConfig.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        
        // رقم الهاتف
        Text(
          '+964 7809876543',
          style: TextStyle(
            fontSize: ThemeConfig.fontSizeRegular,
            color: ThemeConfig.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 16),
        
        // التقييم والحالة
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: ThemeConfig.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: ThemeConfig.successColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'نشط',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeSmall,
                      fontWeight: ThemeConfig.fontWeightMedium,
                      color: ThemeConfig.successColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.amber,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '4.8',
                    style: TextStyle(
                      fontSize: ThemeConfig.fontSizeSmall,
                      fontWeight: ThemeConfig.fontWeightMedium,
                      color: Colors.amber,
                    ),
                  ),
                ],
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
                  color: ThemeConfig.accentColor,
                ),
                title: Text(item['title'] as String),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.containsKey('badge'))
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeConfig.goldColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          item['badge'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: ThemeConfig.fontWeightMedium,
                            color: ThemeConfig.goldColor,
                          ),
                        ),
                      ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                  ],
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
