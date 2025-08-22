import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppController extends GetxController {
  // Theme mode (light/dark)
  final RxBool isDarkMode = true.obs;
  
  // Current tab index for bottom navigation
  final RxInt currentTabIndex = 0.obs;
  
  // App language
  final RxString currentLanguage = 'en'.obs;
  
  // App version
  final String appVersion = '1.0.0';
  
  // App name
  final String appName = 'Habitual';
  
  // SharedPreferences instance
  late SharedPreferences _prefs;
  
  @override
  void onInit() async {
    super.onInit();
    await _initPrefs();
    _loadSettings();
  }
  
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  void _loadSettings() {
    // Load theme mode
    isDarkMode.value = _prefs.getBool('isDarkMode') ?? true;
    
    // Load language
    currentLanguage.value = _prefs.getString('language') ?? 'en';
  }
  
  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    isDarkMode.toggle();
    await _prefs.setBool('isDarkMode', isDarkMode.value);
    
    // Update app theme
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
  
  // Change app language
  Future<void> changeLanguage(String languageCode) async {
    currentLanguage.value = languageCode;
    await _prefs.setString('language', languageCode);
    
    // Update app locale
    Get.updateLocale(Locale(languageCode));
  }
  
  // Change current tab
  void changeTab(int index) {
    currentTabIndex.value = index;
  }
  
  // Get current theme data
  ThemeData get currentTheme {
    return isDarkMode.value ? _darkTheme : _lightTheme;
  }
  
  // Light theme
  static final ThemeData _lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: Colors.teal,
      secondary: Colors.tealAccent,
      surface: Colors.white,
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black87),
      titleTextStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
  
  // Dark theme
  static final ThemeData _darkTheme = ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: Colors.teal,
      secondary: Colors.tealAccent,
      surface: Color(0xFF2D3748),
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1A1D1A),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: ThemeData.dark().cardTheme.copyWith(
      color: const Color(0xFF2D3748),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
