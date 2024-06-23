import 'dart:typed_data';

import 'package:cake_coffee/firebase_options.dart';
import 'package:cake_coffee/models/khanh/add_products.dart';
import 'package:cake_coffee/views/khanh/khanh.dart';
import 'package:cake_coffee/views/khanh/management_account_screen.dart';
import 'package:cake_coffee/views/khanh/management_ingredient_screen.dart';
import 'package:cake_coffee/views/khanh/management_product.dart';
import 'package:cake_coffee/views/khanh/management_screen.dart';
import 'package:cake_coffee/views/khanh/management_table.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
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
      initialRoute: "/management",
      routes: {"/management": (context) => const Management_Screen()},
    );
  }
}
