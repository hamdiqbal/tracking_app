import 'package:get/get.dart';
import '../../logic/controllers/app_controller.dart';
import '../../logic/controllers/habit_controller.dart';
import '../../data/services/firebase_service.dart';
import '../../logic/controllers/auth_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize controllers
    if (!Get.isRegistered<AppController>()) {
      Get.lazyPut<AppController>(() => AppController(), fenix: true);
    }

    // Initialize services
    if (!Get.isRegistered<FirebaseService>()) {
      Get.lazyPut<FirebaseService>(() => FirebaseService(), fenix: true);
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    }
    
    // Initialize controllers that depend on repositories
    if (!Get.isRegistered<HabitController>()) {
      Get.lazyPut<HabitController>(
        () => HabitController(),
        fenix: true,
      );
    }
    
    // Note: Add more bindings here as needed
  }
}
