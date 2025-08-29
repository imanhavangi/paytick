import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'model/payment.dart';
import 'model/payment_history.dart';
import 'model/payment_category.dart';
import 'controller/payment_controller.dart';
import 'controller/navigation_controller.dart';
import 'controller/theme_controller.dart';
import 'ui/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(PaymentFrequencyAdapter());
  Hive.registerAdapter(PaymentAdapter());
  Hive.registerAdapter(PaymentHistoryAdapter());
  Hive.registerAdapter(PaymentCategoryAdapter());

  runApp(const PaytickApp());
}

class PaytickApp extends StatelessWidget {
  const PaytickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PayTick',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MainNavigation(),
      initialBinding: PaytickBinding(),
    );
  }
}

class PaytickBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PaymentController());
    Get.put(NavigationController());
    Get.put(ThemeController());
  }
}
