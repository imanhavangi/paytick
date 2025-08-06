import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'model/payment.dart';
import 'controller/payment_controller.dart';
import 'ui/payments_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone
  tz.initializeTimeZones();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(PaymentFrequencyAdapter());
  Hive.registerAdapter(PaymentAdapter());
  
  runApp(const PaytickApp());
}

class PaytickApp extends StatelessWidget {
  const PaytickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Paytick',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PaymentsPage(),
      initialBinding: PaytickBinding(),
    );
  }
}

class PaytickBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(PaymentController());
  }
}
