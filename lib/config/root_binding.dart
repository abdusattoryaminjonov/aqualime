import 'package:aqualime/controllers/buttons_navbar_controller.dart';
import 'package:get/get.dart';

class RootBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ButtonsNavigationBarController(), fenix: true);
  }
}