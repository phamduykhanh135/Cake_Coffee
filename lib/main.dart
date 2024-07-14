import 'package:cake_coffee/firebase_options.dart';
import 'package:cake_coffee/views/customner_screen.dart';
import 'package:cake_coffee/views/gop.dart';
import 'package:cake_coffee/views/gop2.dart';
import 'package:cake_coffee/views/in_place_screen.dart';
import 'package:cake_coffee/views/khanh/management_account_screen.dart';
import 'package:cake_coffee/views/khanh/management_product.dart';
import 'package:cake_coffee/views/khanh/management_screen.dart';
import 'package:cake_coffee/views/khanh/management_table.dart';
import 'package:cake_coffee/views/khanh/revenue_statistics_screen.dart';
import 'package:cake_coffee/views/khanh/statistical_material_screen.dart';
import 'package:cake_coffee/views/khanh/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: "/login",
      routes: {
        "/login": (context) => const LoginScreen(),
        "/demo": (context) => const ThongKe2(),
      },
    );
  }
}
