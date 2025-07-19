import 'package:aqualime/pages/home/home_page.dart';
import 'package:aqualime/pages/map/map_page.dart';
import 'package:aqualime/pages/profile/profile_page.dart';
import 'package:get/get.dart';

class ButtonsNavigationBarController extends GetxController{
  final Rx<int> selectedIndex = 0.obs;

  final screens = [HomePage(),MapPage(),ProfilePage()];
}