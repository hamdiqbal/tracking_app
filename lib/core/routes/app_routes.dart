import 'package:get/get.dart';
import '../../presentation/pages/splash/splash_page.dart';
import '../../presentation/pages/habits/habits_page.dart';
import '../../presentation/pages/habits/add_habit_page.dart';
import '../../presentation/pages/calendar/calendar_page.dart';
import '../../presentation/pages/settings/settings_page.dart';
import '../../presentation/pages/auth/sign_in_page.dart';
import '../../presentation/pages/auth/sign_up_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String addHabit = '/add-habit';
  static const String calendar = '/calendar';
  static const String settings = '/settings';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  
  static final routes = [
    GetPage(
      name: splash,
      page: () => SplashPage(),
    ),
    GetPage(
      name: home,
      page: () => HabitsPage(),
    ),
    GetPage(
      name: signIn,
      page: () => SignInPage(),
    ),
    GetPage(
      name: signUp,
      page: () => SignUpPage(),
    ),
    GetPage(
      name: addHabit,
      page: () => AddHabitPage(),
    ),
    GetPage(
      name: calendar,
      page: () => CalendarPage(),
    ),
    GetPage(
      name: settings,
      page: () => SettingsPage(),
    ),
  ];
}
