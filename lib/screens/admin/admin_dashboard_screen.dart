import 'package:flutter/material.dart';
import 'package:yalla_ride_app/config/theme_config.dart';

/// شاشة لوحة تحكم الإدارة
/// تعرض إحصائيات النظام وتوفر وصولاً إلى وظائف الإدارة المختلفة
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  
  // إحصائيات النظام
  final Map<String, dynamic> _stats = {
    'total_users': 1250,
    'active_users': 980,
    'total_drivers': 320,
    'active_drivers': 280,
    'pending_drivers': 15,
    'total_rides': 5680,
    'today_rides': 124,
    'total_revenue': 28400000,
    'today_revenue': 620000,
  };
  
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }
  
  // تحميل بيانات لوحة التحكم
  Future<void> _loadDashboardData() async {
    // محاكاة تأخير لتحميل البيانات
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم الإدارة'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // تحديث البيانات
              setState(() {
                _isLoading = true;
              });
              _loadDashboardData();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      drawer: _buildAdminDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _buildSelectedScreen(),
    );
  }
  
  // بناء القائمة الجانبية للإدارة
  Widget _buildAdminDrawer() {
    return Drawer(
      child: Column(
        children: [
          // رأس القائمة
          DrawerHeader(
            decoration: BoxDecoration(
              color: ThemeConfig.primaryColor,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                    size: 50,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'لوحة تحكم يلا رايد',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ThemeConfig.fontSizeLarge,
                      fontWeight: ThemeConfig.fontWeightBold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // عناصر القائمة
          _buildDrawerItem(
            icon: Icons.dashboard,
            title: 'الرئيسية',
            index: 0,
          ),
          _buildDrawerItem(
            icon: Icons.people,
            title: 'إدارة المستخدمين',
            index: 1,
          ),
          _buildDrawerItem(
            icon: Icons.drive_eta,
            title: 'إدارة السائقين',
            index: 2,
          ),
          _buildDrawerItem(
            icon: Icons.approval,
            title: 'طلبات الموافقة',
            index: 3,
            badge: _stats['pending_drivers'],
          ),
          _buildDrawerItem(
            icon: Icons.route,
            title: 'إدارة الرحلات',
            index: 4,
          ),
          _buildDrawerItem(
            icon: Icons.payments,
            title: 'إدارة المدفوعات',
            index: 5,
          ),
          _buildDrawerItem(
            icon: Icons.bar_chart,
            title: 'التقارير والإحصائيات',
            index: 6,
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'إعدادات النظام',
            index: 7,
          ),
          
          const Spacer(),
          
          // زر تسجيل الخروج
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('تسجيل الخروج'),
            onTap: () {
              // تسجيل الخروج
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/welcome',
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
  
  // بناء عنصر القائمة الجانبية
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
    int? badge,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: _selectedIndex == index ? ThemeConfig.primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: _selectedIndex == index ? ThemeConfig.primaryColor : null,
          fontWeight: _selectedIndex == index ? ThemeConfig.fontWeightSemiBold : null,
        ),
      ),
      trailing: badge != null && badge > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            )
          : null,
      selected: _selectedIndex == index,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context);
      },
    );
  }
  
  // بناء الشاشة المحددة
  Widget _buildSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardScreen();
      case 1:
        return _buildUsersManagementScreen();
      case 2:
        return _buildDriversManagementScreen();
      case 3:
        return _buildApprovalRequestsScreen();
      case 4:
        return _buildRidesManagementScreen();
      case 5:
        return _buildPaymentsManagementScreen();
      case 6:
        return _buildReportsScreen();
      case 7:
        return _buildSystemSettingsScreen();
      default:
        return _buildDashboardScreen();
    }
  }
  
  // بناء شاشة لوحة التحكم الرئيسية
  Widget _buildDashboardScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان الشاشة
          Text(
            'نظرة عامة',
            style: TextStyle(
              fontSize: ThemeConfig.fontSizeLarge,
              fontWeight: ThemeConfig.fontWeightBold,
              color: ThemeConfig.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 20),
          
          // إحصائيات سريعة
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'المستخدمين النشطين',
                  value: _stats['active_users'].toString(),
                  total: _stats['total_users'].toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'السائقين النشطين',
                  value: _stats['active_drivers'].toString(),
                  total: _stats['total_drivers'].toString(),
                  icon: Icons.drive_eta,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'رحلات اليوم',
                  value: _stats['today_rides'].toString(),
                  total: _stats['total_rides'].toString(),
                  icon: Icons.route,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'إيرادات اليوم',
                  value: '${(_stats['today_revenue'] / 1000).toStringAsFixed(0)} ألف د.ع',
                  total: '${(_stats['total_revenue'] / 1000000).toStringAsFixed(1)} مليون د.ع',
                  icon: Icons.payments,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // طلبات الموافقة المعلقة
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'طلبات الموافقة المعلقة',
                        style: TextStyle(
                          fontSize: ThemeConfig.fontSizeMedium,
                          fontWeight: ThemeConfig.fontWeightSemiBold,
                          color: ThemeConfig.textPrimaryColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 3;
                          });
                        },
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _stats['pending_drivers'] > 0
                      ? ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _stats['pending_drivers'] > 5 ? 5 : _stats['pending_drivers'],
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            return _buildPendingDriverItem(index);
                          },
                        )
                      : const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('لا توجد طلبات معلقة'),
                          ),
                        ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // الرحلات الأخيرة
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الرحلات الأخيرة',
                        style: TextStyle(
                          fontSize: ThemeConfig.fontSizeMedium,
                          fontWeight: ThemeConfig.fontWeightSemiBold,
                          color: ThemeConfig.textPrimaryColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedIndex = 4;
                          });
                        },
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      return _buildRecentRideItem(index);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // بناء بطاقة إحصائية
  Widget _buildStatCard({
    required String title,
    required String value,
    required String total,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ThemeConfig.fontSizeRegular,
                    color: ThemeConfig.textSecondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: ThemeConfig.fontSizeLarge,
                fontWeight: ThemeConfig.fontWeightBold,
                color: ThemeConfig.textPrimaryColor,
              ),
            ),
            Text(
              'من أصل $total',
              style: TextStyle(
                fontSize: ThemeConfig.fontSizeSmall,
                color: ThemeConfig.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // بناء عنصر سائق معلق
  Widget _buildPendingDriverItem(int index) {
    // بيانات وهمية للسائقين المعلقين
    final driverNames = [
      'محمد علي',
      'أحمد حسين',
      'علي محمود',
      'حسن كريم',
      'عمر فاروق',
    ];
    
    final carModels = [
      'تويوتا كامري 2023',
      'هوندا أكورد 2022',
      'كيا سيراتو 2023',
      'هيونداي سوناتا 2021',
      'نيسان التيما 2022',
    ];
    
    final registrationDates = [
      '2025/06/01',
      '2025/06/02',
      '2025/06/02',
      '2025/06/03',
      '2025/06/04',
    ];
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: ThemeConfig.primaryColor.withOpacity(0.1),
        child: Text(
          driverNames[index][0],
          style: TextStyle(
            color: ThemeConfig.primaryColor,
            fontWeight: ThemeConfig.fontWeightBold,
          ),
        ),
      ),
      title: Text(driverNames[index]),
      subtitle: Text(carModels[index]),
      trailing: Text(
        registrationDates[index],
        style: TextStyle(
          fontSize: ThemeConfig.fontSizeSmall,
          color: ThemeConfig.textSecondaryColor,
        ),
      ),
      onTap: () {
        // عرض تفاصيل السائق المعلق
      },
    );
  }
  
  // بناء عنصر رحلة حديثة
  Widget _buildRecentRideItem(int index) {
    // بيانات وهمية للرحلات الحديثة
    final passengerNames = [
      'أحمد محمد',
      'سارة علي',
      'محمود حسن',
      'فاطمة كريم',
      'عمر خالد',
    ];
    
    final driverNames = [
      'محمد علي',
      'أحمد حسين',
      'علي محمود',
      'حسن كريم',
      'عمر فاروق',
    ];
    
    final routes = [
      'حي القادسية → شارع الجمهورية',
      'شارع فلسطين → حي الأندلس',
      'حي الخضراء → المنصور',
      'الكرادة → باب المعظم',
      'الأعظمية → الكاظمية',
    ];
    
    final amounts = [
      '5,000',
      '7,500',
      '4,000',
      '8,000',
      '6,500',
    ];
    
    final times = [
      '10:15 ص',
      '11:30 ص',
      '12:45 م',
      '01:20 م',
      '02:05 م',
    ];
    
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(passengerNames[index]),
          ),
          const Icon(
            Icons.arrow_forward,
            size: 16,
            color: Colors.grey,
          ),
          Expanded(
            child: Text(
              driverNames[index],
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
      subtitle: Text(routes[index]),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${amounts[index]} د.ع',
            style: TextStyle(
              color: ThemeConfig.accentColor,
              fontWeight: ThemeConfig.fontWeightSemiBold,
            ),
          ),
          Text(
            times[index],
            style: TextStyle(
              fontSize: ThemeConfig.fontSizeXSmall,
              color: ThemeConfig.textSecondaryColor,
            ),
          ),
        ],
      ),
      onTap: () {
        // عرض تفاصيل الرحلة
      },
    );
  }
  
  // بناء شاشة إدارة المستخدمين
  Widget _buildUsersManagementScreen() {
    return Center(
      child: Text(
        'إدارة المستخدمين',
        style: TextStyle(
          fontSize: ThemeConfig.fontSizeLarge,
          fontWeight: ThemeConfig.fontWeightBold,
        ),
      ),
    );
  }
  
  // بناء شاشة إدارة السائقين
  Widget _buildDriversManagementScreen() {
    return Center(
      child: Text(
        'إدارة السائقين',
        style: TextStyle(
          fontSize: ThemeConfig.fontSizeLarge,
          fontWeight: ThemeConfig.fontWeightBold,
        ),
      ),
    );
  }
  
  // بناء شاشة طلبات الموافقة
  Widget _buildApprovalRequestsScreen() {
    return Center(
      child: Text(
        'طلبات الموافقة',
        style: TextStyle(
          fontSize: ThemeConfig.fontSizeLarge,
          fontWeight: ThemeConfig.fontWeightBold,
        ),
      ),
    );
  }
  
  // بناء شاشة إدارة الرحلات
  Widget _buildRidesManagementScreen() {
    return Center(
      child: Text(
        'إدارة الرحلات',
        style: TextStyle(
          fontSize: ThemeConfig.fontSizeLarge,
          fontWeight: ThemeConfig.fontWeightBold,
        ),
      ),
    );
  }
  
  // بناء شاشة إدارة المدفوعات
  Widget _buildPaymentsManagementScreen() {
    return Center(
      child: Text(
        'إدارة المدفوعات',
        style: TextStyle(
          fontSize: ThemeConfig.fontSizeLarge,
          fontWeight: ThemeConfig.fontWeightBold,
        ),
      ),
    );
  }
  
  // بناء شاشة التقارير والإحصائيات
  Widget _buildReportsScreen() {
    return Center(
      child: Text(
        'التقارير والإحصائيات',
        style: TextStyle(
          fontSize: ThemeConfig.fontSizeLarge,
          fontWeight: ThemeConfig.fontWeightBold,
        ),
      ),
    );
  }
  
  // بناء شاشة إعدادات النظام
  Widget _buildSystemSettingsScreen() {
    return Center(
      child: Text(
        'إعدادات النظام',
        style: TextStyle(
          fontSize: ThemeConfig.fontSizeLarge,
          fontWeight: ThemeConfig.fontWeightBold,
        ),
      ),
    );
  }
}
