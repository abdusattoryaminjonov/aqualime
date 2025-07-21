import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../models/employees.dart';
import '../login/login_page.dart';
import 'button_navigation_bar.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  double _opacity = 0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _opacity = 1;
        _scale = 1;
      });
    });

    _checkUser();
  }

  void _checkUser() async {
    await Future.delayed(Duration(seconds: 3));

    final employeeBox = await Hive.openBox<Employee>('employees');

    if (employeeBox.isEmpty) {
      Get.offAll(() => LoginPage());
    } else {
      Get.offAll(() => ButtonsNavigationBar());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(seconds: 2),
          child: AnimatedScale(
            scale: _scale,
            duration: Duration(seconds: 2),
            curve: Curves.easeInOut,
            child: Image.asset(
              'assets/images/aqualimew.png',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
