import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yalla_ride_app/config/app_config.dart';
import 'package:yalla_ride_app/config/theme_config.dart';
import 'package:yalla_ride_app/screens/auth/driver_signup/step1_basic_info.dart';
import 'package:yalla_ride_app/screens/auth/driver_signup/step2_vehicle_info.dart';
import 'package:yalla_ride_app/screens/auth/driver_signup/step3_documents.dart';
import 'package:yalla_ride_app/screens/auth/driver_signup/step4_review.dart';
import 'package:yalla_ride_app/screens/auth/login_screen.dart';
import 'package:yalla_ride_app/screens/auth/passenger_signup_screen.dart';
import 'package:yalla_ride_app/screens/common/splash_screen.dart';
import 'package:yalla_ride_app/screens/common/welcome_screen.dart';
import 'package:yalla_ride_app/screens/driver/driver_home_screen.dart';
import 'package:yalla_ride_app/screens/passenger/passenger_home_screen.dart';
import 'package:yalla_ride_app/screens/passenger/passenger_ride_request_screen.dart';

void main() async {
  // تأكد من تهيئة Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // تحميل متغيرات البيئة
    await dotenv.load(fileName: ".env");
    
    // تهيئة Supabase
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    
    print('تم تهيئة التطبيق بنجاح');
  } catch (e) {
    print('خطأ في تهيئة التطبيق: $e');
  }
  
  runApp(const YallaRideApp());
}

class YallaRideApp extends StatelessWidget {
  const YallaRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'يلا رايد',
      theme: ThemeConfig.lightTheme,
      darkTheme: ThemeConfig.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      
      // الشاشة الأولى
      home: const SplashScreen(),
      
      // تعريف المسارات
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/passenger_signup': (context) => const PassengerSignupScreen(),
        '/driver_signup_step1': (context) => const DriverSignupStep1(),
        '/driver_signup_step2': (context) => const DriverSignupStep2(),
        '/driver_signup_step3': (context) => const DriverSignupStep3(),
        '/driver_signup_step4': (context) => const DriverSignupStep4(),
        '/passenger_home': (context) => const PassengerHomeScreen(),
        '/driver_home': (context) => const DriverHomeScreen(),
        '/ride_request': (context) => const PassengerRideRequestScreen(),
      },
      
      // معالج المسارات غير المعرفة
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        );
      },
    );
  }
}

