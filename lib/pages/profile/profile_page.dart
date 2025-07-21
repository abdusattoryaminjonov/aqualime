import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/employees.dart';
import '../login/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;

  Employee? employee;



  @override
  void initState() {
    super.initState();
    loadEmployee();
  }

  Future<void> loadEmployee() async {
    final employeeBox = Hive.box<Employee>('employees');
    if (employeeBox.isNotEmpty) {
      setState(() {
        employee = employeeBox.values.first;
      });
    }
  }

  void logOut(BuildContext context) async {
    await Hive.box<Employee>('employees').clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Diqqat!"),
        content: Text("Siz tizimdan chiqmoqchimisiz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Bekor qilish"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              logOut(context);
            },
            child: Text("Ha"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final userName = employee?.name ?? "Foydalanuvchi";


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 35),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/profile.png'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade100,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  userName,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 35),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _profileButton("Zakaz : ${employee?.zakaz.toString()}", () {
                        // Maxsulot uchun funksiyani yozing
                      }),
                      _profileButtonQ("Summa : ${employee!.naqd + employee!.karta} ",employee!.qarz, () {
                        // Tarix uchun funksiyani yozing
                      }),
                      _profileButton("Sozlamalar", () {
                        // Sozlamalar uchun funksiyani yozing
                      }),
                      _profileButton("Chiqish", () {
                        showLogoutDialog(context);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.black12),
        ],
      ),
    );
  }

  Widget _profileButton(String text, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(color: Colors.blue, fontSize: 16),
        ),
      ),
    );
  }

  Widget _profileButtonQ(String text, int qarz , VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
            qarz > 0 ? Text(
              "+ $qarz",
              style: TextStyle(color: Colors.red, fontSize: 16),
            ) : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
