import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../logic/controllers/auth_controller.dart';
import '../../../core/constants/colors.dart';
import '../../../core/routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Route based on auth state (tolerate missing Firebase on iOS)
    try {
      final auth = Get.find<AuthController>();
      auth.authStateChanges.listen((user) {
        if (!mounted) return;
        if (user == null) {
          Get.offAllNamed(AppRoutes.signIn);
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
      });
    } catch (_) {
      // If Firebase/Auth isn't ready, move to Sign In so the app doesn't stall
      Future.microtask(() => Get.offAllNamed(AppRoutes.signIn));
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.splashBackground1,
              AppColors.splashBackground2,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.splashBackground2,
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFFD4C4B0),
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.splashBackground1,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Text(
                'Habitual',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Build better habits and achieve your goals with our easy-to-use habit tracker.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF718096),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
