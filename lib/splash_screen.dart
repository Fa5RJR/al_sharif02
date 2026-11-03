import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'onBoarding/onBoarding_first.dart';
import 'colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 3000, // المدة 3 ثواني
      splashIconSize: double.infinity, // حجم الايكون (اللوجو)
      backgroundColor: Colors.transparent, // لون الخلفية
      nextScreen: const OnboardingOne(), // الصفحة اللي تفتح بعد السبلاش
      splashTransition: SplashTransition.fadeTransition, // شكل الترانزيشن (فيد Fade)
      splash: Container(
        width: double.infinity, //العرض
        height: double.infinity, //الطول
        decoration: const BoxDecoration( //ديكوريشن الكونتينر
          gradient: LinearGradient(//تدرج الالوان
            colors: [AppColors.navy, AppColors.turquoise], //الالوان
            begin: Alignment.topCenter, //اللون اللي بيبدأ
            end: Alignment.bottomCenter, //اللون اللي من تحت
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -120,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),

            // نص دايرة تحت شمال
            Positioned(
              bottom: -120,
              left: -120,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
            ),

            // اللوجو (دخل جوه الـ Stack)
            Center(
              child: Image.asset('assets/images/logo.png', width: 550), //الصورة
            ),
          ],
        ),
      ),
    );
  }
}