import 'package:aqualime/config/root_binding.dart';
import 'package:aqualime/pages/home/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import 'config/init_hive.dart';
import 'models/employees.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initHive();
  Hive.registerAdapter(EmployeeAdapter());
  await Hive.openBox<Employee>('employees');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: RootBinding(),
      title: 'AquaLime',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: SplashPage(),
    );
  }
}