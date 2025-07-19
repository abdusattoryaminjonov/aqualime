import 'package:aqualime/controllers/buttons_navbar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class ButtonsNavigationBar extends StatefulWidget {
  const ButtonsNavigationBar({super.key});

  @override
  State<ButtonsNavigationBar> createState() => _ButtonsNavigationBarState();
}

class _ButtonsNavigationBarState extends State<ButtonsNavigationBar> {
  final controller = Get.find<ButtonsNavigationBarController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Obx(
            () => NavigationBarTheme(
              data: NavigationBarThemeData(
                indicatorColor: Colors.blue.shade50,
                labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
                      (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600);
                    }
                    return const TextStyle(color: Colors.grey);
                  },
                ),
                iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
                      (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return const IconThemeData(color: Colors.blue);
                    }
                    return const IconThemeData(color: Colors.grey);
                  },
                ),
              ),
              child: NavigationBar(
                height: 70,
                elevation: 1,
                backgroundColor: Colors.white,
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: (index) => controller.selectedIndex.value = index,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Iconsax.home, size: 26),
                    selectedIcon: Icon(Iconsax.home, size: 28),
                    label: "Home",
                  ),
                  NavigationDestination(
                    icon: Icon(Iconsax.map, size: 30),
                    selectedIcon: Icon(Iconsax.map, size: 32),
                    label: "Map",
                  ),
                  NavigationDestination(
                    icon: Icon(Iconsax.user, size: 26),
                    selectedIcon: Icon(Iconsax.user, size: 28),
                    label: "Account",
                  ),
                ],
              ),
            )
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}
